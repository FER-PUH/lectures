University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2023/2024

LECTURE 14: Monads 2

v1.0

(c) 2025 Jan Šnajder, Mihovil Ilakovac

==============================================================================

> module Lecture where
> import Control.Monad
> import System.Random

== MONAD RECAP ================================================================

Last time we saw how a lot of common patterns in programming can be abstracted
away by monads. From keeping some logs and dealing with nondeterminism to
expressing possible failure. One important aspect of monads we glossed over is
the special syntax sugar called "the do notation" that allows us to write
programs in a fashion similar to what we might find in imperative languages.
To understand how it works first we need to refresh our memories on the bind
operator:

  (>>=) :: Monad m => m a -> (a -> m b) -> m b

This operator, allows us to take a monadic value 'm a' and feed it to an
arbitray function that only expects the underlying value 'a'. This is powerful
because it essentially allows us to extract the value from the monad and treat
it like it's a normal value.

Let's look at an example with 'Maybe'. Division is not a total operation because
dividing by 0 is not defined. Instead of crashing our whole program we would
like to catch that error and force the caller to handle it.

> safeDiv :: (Eq a, Fractional a) => a -> a -> Maybe a
> safeDiv _ 0 = Nothing
> safeDiv x y = Just $ x / y

> data Expr
>   = Val Double
>   | Mul Expr Expr
>   | Div Expr Expr
>   deriving (Show,Eq)

> --       3   *   (    5   /       0)
> ex = Val 3 `Mul` (Val 5 `Div` Val 0)

> eval :: Expr -> Maybe Double
> eval (Val v)     = return v
> eval (Mul e1 e2) =
>   eval e1 >>= \r1 ->
>   eval e2 >>= \r2 ->
>   pure $ r1 * r2
> eval (Div e1 e2) =
>   eval e1 >>= \r1 ->
>   eval e2 >>= \r2 ->
>   r1 `safeDiv` r2

Notice how even though 'eval e' returns a 'Maybe Double' we have 'r1' and 'r2'
which are just good old 'Double's. Writing all these lambdas though can be a
bit tedious and that's where the syntax sugar comes in. Since we're going to
use (>>=) with a lambda so often the designers of Haskell blessed us with a
notation that does that automaticallly.

> eval' :: Expr -> Maybe Double
> eval' (Val v)     = return v
> eval' (Mul e1 e2) = do
>   r1 <- eval' e1
>   r2 <- eval' e2
>   pure $ r1 * r2
> eval' (Div e1 e2) = do
>   r1 <- eval' e1
>   r2 <- eval' e2
>   r1 `safeDiv` r2

This almost looks like something you would write in C (you can even use curly
braces if you want). This is the same notation you already used for 'IO' and
that's no coincidence. The power of the do notation is not in any specific type
but rather the fact that it works for any monad and the behavior of binding
a monadic value using the left arrow is up to us to decide. Like everything in
Haskell a do block is just an expression and the exact instance of the monad
used is determined by the type of that expression.

== STATE MONAD ===============================================================

Haskell is a purely functional language and disallows side effects. This means
that there is no implicit state in Haskell, or, in other words, we have
STATELESS COMPUTATION. If we want to have a state, we must drag it around
explicitly from function to function. This is obviously awkward. To circumvent
this, we use a STATE MONAD. A state monad "hides" an explicit state and makes
it accessible within the monad. This effectively enables us to do STATEFULL
COMPUTATION. It turns out that the IO monad is actually a state monad.

Let's first consider two examples in which we will make the use of explicit
state.

Example 1: Labeling the nodes of a tree

> data Tree a = Leaf a | Branch (Tree a) (Tree a) deriving (Show, Eq)

> t1 = Branch (Branch (Leaf 'b') (Leaf 'c')) (Branch (Leaf 'd') (Leaf 'a'))

> label :: Tree a -> Tree Int
> label = snd . step 0
>   where step n (Leaf _) = (n+1, Leaf n)
>         step n (Branch t1 t2) = let
>           (n1,t1') = step n t1
>           (n2,t2') = step n1 t2
>           in (n2, Branch t1' t2')

Example 2: A random number generator

> g = mkStdGen 13
> (r1, g2) = random g :: (Int, StdGen)
> (r2, g3) = random g2 :: (Int, StdGen)
> (r3, g4) = random g3 :: (Int, StdGen)

In both cases we have to drag around a state: each function takes the current
state as an argument and yields a return a value plus the updated state. This
can be nicely abstracted with a state monad. Its type is

> newtype State s a = State (s -> (a, s))

So, the state monad is actually a *function* that takes a state and returns a
new state and a return value. Binding together a sequence of such functions
will give a single function that effectively performs statefull computation. We
then can apply this function to an initial state.

First, let's make 'State' an instance of the 'Monad' type class:

> instance Functor (State s) where
>   fmap = liftM
>
> instance Applicative (State s) where
>   pure x = State (\s -> (x, s))
>   (<*>) = ap
>
> instance Monad (State s) where
>   State stateProcessor1 >>= getStateProcessor = State $ \s ->
>     let (x, s') = stateProcessor1 s  -- left computation on the state
>         State stateProcessor2 = getStateProcessor x  -- the computation of the "right monad"
>      in stateProcessor2 s'  -- right computation on the state

'return a' gives us a function that takes a state and returns the unaltered
state together with a return value 'a'. The definition of binding operator
(>>=) is a bit more intricate. Let's remind ourselves of its type:

  (>>=) :: m a -> (a -> m b) -> m b

The bind operator needs to unwrap the left 'm a' value, which is actually a
function. This function is applied to the initial state, which gives a new
state and a result. The result is passed to the function 'a -> m b', which
gives 'm b', which again is a function. This function is then applied to the
state to alter the state once again, and return the final result. The overall
result is a actually a function that alters the state and returns a value.

An example:

> inc :: State Int ()
> inc = State (\s -> ((), s+1))

> dec :: State Int ()
> dec = State (\s -> ((), s-1))

> foo :: State Int ()
> foo = inc >> inc >> inc

How can we run this? We need a function that "runs the monad". More concretely,
the function needs to:
  (1) take a value of the 'State' type and unwrap the function from it,
  (2) take the initial state, and
  (3) apply the function on the initial state.

> runState :: State s a -> s -> (a, s)
> runState (State sm0) s0 = sm0 s0

If you spotted the eta reduction in the previous implementation you might have
noticed that steps 2 and 3 are redundant. So if we only need to extract the
function we could've defined state like this:

  newtype State = State { runState :: s -> (a, s) }

Naming the record field 'run...' is a common idiom for newtypes wrapping a
function.
Now let's try using a state processor:

> v1 = runState foo 10
> v2 = runState (dec >> inc >> dec) 0

The above examples suggest that we can think of a monad as a sequence of
computations that wait to be executed. Using the (>>=) operator, we bind
together the individual computations into one big chain. This chain is actually
one large function that needs to be applied to an initial state. When we want
to execute this chain of computation, we use the 'runState' function, which
unwraps our function and applies it to the initial state.

In most cases we only need the return value of a computation and don't care
about the final state. Thus, we can define:

> evalState :: State s a -> s -> a
> evalState (State sm0) = fst . sm0

Let's try it out:

> v3 = evalState foo 10

Of course, the return value is (), because all we did was changing the state,
which we now have discarded. We must somehow transfer the state to the return
value. But this is easy:

> get :: State s s
> get = State (\s -> (s, s))

> v4 = evalState (foo >> get) 10

How would you go about defining the 'put' function? What is its type?

> put :: s -> State s ()
> put x = State $ \_ -> ((), x)

> v5 = evalState (put 5) 10
> v6 = evalState (put 5 >> get) 10
> v7 = evalState (put 5 >> inc >> get) 10
> v7' = evalState (put 5 >> inc >> get) undefined

Your turn now: what's the result of the following computations?

> v8 = evalState (get >>= put) 10
> v9 = evalState (get >>= put >> get) 10
> v10 = evalState (return 0 >> inc >> get) 10
> v11 = evalState (get >> return 5) 10
> v12 = evalState (inc >> pure 0) 10
> v13 = evalState (dec >> return 0 >> get) 10
> v14 = evalState (get >>= put . (+5) >> get) 10

Statefull computation becomes more readable if use the 'do' notation. For
example, the last computation from above:

> foo2 :: State Int Int
> foo2 = do
>   x <- get
>   put $ x + 5
>   get

> v15 = evalState foo2 10

What is the following function doing and what is its type?

> foo3 = do
>   x <- get
>   put $ x + 100
>   return ()

Great! We are now ready to tackle the problem we started with: labeling the
nodes of a tree.

> label2 :: Tree a -> State Int (Tree Int)
> label2 (Leaf _) = do
>   n <- get
>   inc
>   return (Leaf n)
> label2 (Branch t1 t2) = do
>   t1' <- label2 t1
>   t2' <- label2 t2
>   return $ Branch t1' t2'

> labelTree :: Tree a -> Tree Int
> labelTree t = evalState (label2 t) 0

== EXERCISE 1 ================================================================

Solve the following problems in the state monad 'State s a'.
1.1.
- Define the following functions:
    nop :: State s ()
    reset :: State Int ()
    modify :: (s -> s) -> State s ()
  Give three definitions for each: (1) a direct definition on the 'State' type,
  (2) a monadic definition but without using 'do' notation, and (3) a monadic
  definition using 'do' notation.

1.2.
- Define a function
    random' :: (RandomGen g, Random a) => State g a
  that generates a random number using a RNG 'g' as the state. Internally, the
  function should use the 'random' function.
- Define a function
    initRandom :: Int -> State StdGen ()
  that initializes the RNG with the seed value.
- Define a function
    threeRandoms :: (RandomGen g) => State g (Int,Int,Int)
  that returns three random numbers.

== FUNCTIONS FOR WORKING WITH MONADS =========================================

We've already encountered a couple of useful functions for working with monads
when we considered the IO monad. These reside in the 'Control.Monad' module:

sequence :: Monad m => [m a] -> m [a]
sequence_ :: Monad m => [m a] -> m ()
replicateM :: Monad m => Int -> m a -> m [a]
replicateM_ :: Monad m => Int -> m a -> m ()
mapM :: Monad m => (a -> m b) -> [a] -> m [b]
mapM_ :: Monad m => (a -> m b) -> [a] -> m ()
filterM :: Monad m => (a -> m Bool) -> [a] -> m [a]
foldM :: Monad m => (a -> b -> m a) -> a -> [b] -> m a
foldM_ :: Monad m => (a -> b -> m a) -> a -> [b] -> m ()
forM :: Monad m => [a] -> (a -> m b) -> m [b]
forM_ :: Monad m => [a] -> (a -> m b) -> m ()
forever :: Monad m => m a -> m b

All these functions are applicable to any type that is an instance of the
'Monad' type class, although they are not equally useful for every type.

Function 'sequence' evaluates each monad in a list of monads, gathers the
results in a list and wraps it up the monad:

sequence [] = return []
sequence (m:ms) = do
    x <- m
    xs <- sequence ms
    return (x:xs)

For example:

> e1 = sequence [Nothing, Just 1, Just 2]
> e2 = sequence [Just 1, Just 2, Nothing]
> e3 = sequence [Just 1, Just 2, Just 3]

> inc3 = sequence_ [inc, inc, inc]
> e4 = evalState (inc3 >> get) 3

> e5 = sequence [[1,2,3], [4,5,6]]

This is equivalent to:

  do x <- [1, 2, 3]
     y <- [4, 5, 6]
     return [x, y]

which, in turn, is equivalent to:

  [1,2,3] >>= (\x -> [4,5,6] >>= \y -> return (x : y : []))

> e6 = replicateM 10 (Just 1)

> f x = if even x then Just x else Nothing
> e7 = forM [1, 2, 3] f

> inc30 = replicateM_ 10 inc3

> e8 = evalState (inc30 >> dec >> get) 0

Let's consider some other useful functions.

The function

  (=<<) :: Monad m => (a -> m b) -> m a -> m b

is the same as bind operator (>>=) but with arguments flipped. We can use this
function when the data flow is from right to left, as is the case with
functional composition in pure code. Therefore, this operators makes sense when
we mix pure and monadic code. For example:

> main5 foo=
>   putStr . unlines . filter (not . null) . lines =<< readFile foo

Or, if you prefer, left to right...

> (.>) :: (a -> b) -> (b -> c) -> a -> c
> (.>) = flip (.)

> main5' foo = 
>   readFile foo >>= lines .> filter (not . null) .> unlines .> putStr

The function

  join :: Monad m => m (m a) -> m a

eliminates one level of a nested monad. If we think about a monad type as a
box that stores some values, then 'm (m a)' is a box within a box that contains
a value of type 'a'. Using 'join', we take out this value and place it into a
single box.

For example

> e9 = join (Just (Just 5))
> e10 = join $ return getLine

The definition of the 'join' function is quite simple:

  join :: (Monad m) => m (m a) -> m a
  join m = m >>= id

This function might seem dull at first, but it's actually quite interesting
from a theoretical point of view because it gives us an alternative definition
of a monad. Since 'm' is an instance of 'Functor', we have at our disposal the
'fmap' function:

  fmap :: Functor m => (a -> b) -> m a -> m b

Now, instead of defining the binding operator (>>=) for 'm', we can define the
'join' function. The (>>=) is then defined indirectly as

  (>>=) :: (Functor m, Monad m) => m a -> (a -> m b) -> m b
  m >>= k = join $ fmap k m

In other words,
instead of:
  unwrapping 'm a', applying 'a -> m b' and getting 'm b',
we can:
  apply within 'm a' function 'a -> m b', get 'm (m b)', and then flatten
  to 'm b'.

For example:

  Just 5 >>= \x -> Just (x + 1)
  => join (fmap (\x -> Just (x + 1)) (Just 5))
  => join (Just ((\x -> Just (x+1)) 5))
  => join (Just (Just 6))
  => Just 6
