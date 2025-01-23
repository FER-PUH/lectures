-- Part 1: The Problem - Handling State Manually
-- Let's start with a simple function that reverses a list and counts how many times
-- it's been called:
{-# LANGUAGE InstanceSigs #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use newtype instead of data" #-}
{-# HLINT ignore "Use const" #-}

reverseListWithCount :: Int -> [a] -> (Int, [a])
reverseListWithCount timesCalled list = (timesCalled + 1, reverse list)

-- That seems fine! But what if we want to reverse THREE lists and keep track of
-- the total number of reversals? Let's try it:

-- Exercise 1: Implement a function that reverses three lists while keeping track
-- of the total count. Do this by manually threading the state through.
reverseThreeListsWithCount :: Int -> ([a], [a], [a]) -> (Int, [a])
reverseThreeListsWithCount timesCalled (list1, list2, list3) =
  let (timesCalled1, result1) = reverseListWithCount timesCalled list1
      (timesCalled2, result2) = reverseListWithCount timesCalled1 list2
      (timesCalled3, result3) = reverseListWithCount timesCalled2 list3
   in (timesCalled3, result1 ++ result2 ++ result3)

{-
After you implement this, you'll notice it's quite tedious:
1. We have to manually pass the state (timesCalled) between operations
2. We have to manually extract and recombine results at each step
3. The code is getting messy with lots of pattern matching
4. This would get even worse with more operations!

Let's try to make this better...
-}

-- Part 2: Introducing State
-- We'll create a type that handles state transformations for us:

data State s a = State
  { runState :: s -> (s, a)
  }

-- Now we can create a stateful version of our reverse function:

-- State $ \timesCalled -> (timesCalled + 1, reverse list)

reverseListWithCountState :: [a] -> State Int [a]
reverseListWithCountState list = State $ \timesCalled -> (timesCalled + 1, reverse list)

-- Exercise 2: Try to implement reverseThreeListsWithCount using State.
-- Warning: This will still be annoying without helper functions!
reverseThreeListsWithCountState :: ([a], [a], [a]) -> State Int [a]
reverseThreeListsWithCountState (list1, list2, list3) = State $ \timesCalled ->
  let (timesCalled1, result1) = runState (reverseListWithCountState list1) timesCalled
      (timesCalled2, result2) = runState (reverseListWithCountState list2) timesCalled1
      (timesCalled3, result3) = runState (reverseListWithCountState list3) timesCalled2
   in (timesCalled3, result1 ++ result2 ++ result3)

{-
After implementing this, you'll notice:
1. We still have to manually handle state threading
2. We still have to manually combine results
3. The code is still messy
4. We need a better way to compose State actions!
-}

-- Part 3: Making State Composable
-- We need a function to compose State actions. Given:
--   first :: State s a
--   second :: a -> State s b
-- We want to run first, then pass its result to second while managing the state
chain :: (a -> State s b) -> State s a -> State s b
chain nextFn (State stateFn) = State $ \s0 ->
  let (s1, x) = stateFn s0
      State nextStateFn = nextFn x
   in nextStateFn s1

infixl 1 |>

(|>) :: State s a -> (a -> State s b) -> State s b
(|>) = flip chain

wrap :: a -> State s a
wrap x = State $ \s -> (s, x)

-- Exercise 3: Now implement reverseThreeListsWithCountState using |>
reverseThreeListsWithCountStateClean :: ([a], [a], [a]) -> State Int [a]
reverseThreeListsWithCountStateClean (list1, list2, list3) =
  reverseListWithCountState list1 |> \result1 ->
    reverseListWithCountState list2 |> \result2 ->
      reverseListWithCountState list3 |> \result3 ->
        wrap $ result1 ++ result2 ++ result3

-- Part 4: Using the Monad Instance
-- We can also implement the Moand instance for State so we can use "do" notation:

instance Functor (State s) where
  fmap :: (a -> b) -> State s a -> State s b
  fmap f (State stateFn) = State $ \s0 ->
    let (s1, x) = stateFn s0
     in (s1, f x)

instance Applicative (State s) where
  pure :: a -> State s a
  pure x = State $ \s0 -> (s0, x)

  (<*>) :: State s (a -> b) -> State s a -> State s b
  (<*>) stateF stateX =
    State $ \s0 ->
      let (s1, f) = runState stateF $ s0
          (s2, x) = runState stateX $ s1
       in (s2, f x)

instance Monad (State s) where
  return :: a -> State s a
  return x = State $ \s0 -> (s0, x)

  (>>=) :: State s a -> (a -> State s b) -> State s b
  (>>=) stateX f = State $ \s0 ->
    let (s1, x) = runState stateX $ s0
     in runState (f x) $ s1

-- Exercise 4: Implement reverseThreeListsWithCount using the "do" notation
reverseThreeListsWithCountStateMonad :: ([a], [a], [a]) -> State Int [a]
reverseThreeListsWithCountStateMonad (list1, list2, list3) = do
  result1 <- reverseListWithCountState list1
  result2 <- reverseListWithCountState list2
  -- currentCount <- get
  -- set (currentCount + 10)
  result3 <- reverseListWithCountState list3
  return $ result1 ++ result2 ++ result3

-- Test your implementation:
main :: IO ()
main = do
  let lists = ([1, 2, 3], [4, 5, 6], [7, 8, 9])

  -- The painful way (Exercise 1)
  let (count1, result1) = reverseThreeListsWithCount 0 lists
  putStrLn "Manual state threading:"
  putStrLn $ "Result: " ++ show result1
  putStrLn $ "Count: " ++ show count1
  putStrLn ""

  -- The slightly better but still painful way (Exercise 2)
  let (count2, result2) = runState (reverseThreeListsWithCountState lists) 0
  putStrLn "Basic State usage:"
  putStrLn $ "Result: " ++ show result2
  putStrLn $ "Count: " ++ show count2
  putStrLn ""

  -- The clean way (Exercise 3)
  let (count3, result3) = runState (reverseThreeListsWithCountStateClean lists) 0
  putStrLn "Clean State usage with |>:"
  putStrLn $ "Result: " ++ show result3
  putStrLn $ "Count: " ++ show count3
  putStrLn ""

  -- Using the Monad instance
  let (count4, result4) = runState (reverseThreeListsWithCountStateMonad lists) 0
  putStrLn "Clean State usage with Monad:"
  putStrLn $ "Result: " ++ show result4
  putStrLn $ "Count: " ++ show count4
