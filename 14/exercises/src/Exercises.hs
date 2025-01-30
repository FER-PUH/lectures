{-# LANGUAGE InstanceSigs #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-type-defaults #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Exercises where

import Control.Monad (replicateM)
import Data.Tuple (swap)
import System.Random (Random, RandomGen, StdGen, mkStdGen, random)

-- * State Monad

-- ** Example 1: Labeling a tree

data Tree a
  = Leaf a
  | Branch (Tree a) (Tree a)
  deriving (Eq, Show)

label :: Tree a -> Tree Int
label = snd . step 0
  where
    step :: Int -> Tree a -> (Int, Tree Int)
    step n (Leaf _) = (n + 1, Leaf n)
    step n (Branch t1 t2) =
      let (n1, t1') = step n t1
          (n2, t2') = step n1 t2
       in (n2, Branch t1' t2')

tree :: Tree Char
tree =
  Branch
    ( Branch
        (Leaf 'a')
        ( Branch
            (Leaf 'b')
            (Leaf 'c')
        )
    )
    ( Branch
        (Leaf 'd')
        (Leaf 'e')
    )

-- ** Example 2: A random number generator

g1, g2, g3, g4 :: StdGen
r1, r2, r3 :: Int
g1 = mkStdGen 13
(r1, g2) = random g1 :: (Int, StdGen)
(r2, g3) = random g2 :: (Int, StdGen)
(r3, g4) = random g3 :: (Int, StdGen)

-- ** Definition

newtype SM s a = SM
  { runSM' :: s -> (s, a)
  }

{- Exercise 01 : Define the Functor instance for 'SM' -}
instance Functor (SM s) where
  fmap :: (a -> b) -> SM s a -> SM s b
  fmap f (SM ssa) = SM $ \s -> let (s', a) = ssa s in (s', f a)

{- Exercise 02 : Define the Applicative instance for 'SM' -}
instance Applicative (SM s) where
  pure :: a -> SM s a
  pure a = SM $ \s -> (s, a)

  (<*>) :: SM s (a -> b) -> SM s a -> SM s b
  SM sf <*> (SM ssa) = SM $ \s0 ->
    let (s1, f) = sf s0
        (s2, a) = ssa s1
     in (s2, f a)

{- Exercise 03 : Define the Monad instance for 'SM' -}
instance Monad (SM s) where
  (>>=) :: SM s a -> (a -> SM s b) -> SM s b
  SM sa >>= asmsb = SM $ \s0 ->
    let (s1, a) = sa s0
        SM sb = asmsb a
     in sb s1

{- Simple test examples -}

inc :: SM Int ()
inc = SM (\s -> (s + 1, ()))

dec :: SM Int ()
dec = SM (\s -> (s - 1, ()))

foo :: SM Int ()
foo = inc >> inc >> inc

v1 :: (Int, ())
v1 = runSM' foo 10

v2 :: (Int, ())
v2 = runSM' (dec >> inc >> dec) 0

{- Utilities -}
runSM :: SM s a -> s -> a
runSM sm = snd . runSM' sm

v3 = runSM foo 10

get :: SM s s
get = SM (\s -> (s, s))

v4 = runSM (foo >> get) 10

set :: s -> SM s ()
set a = SM (\_ -> (a, ()))

v5 = runSM (set 5) 10

v6 = runSM (set 5 >> get) 10

v7 = runSM (set 5 >> inc >> get) 10

{- Inquisition 1 -}

v8 = runSM (get >>= set) 10

v9 = runSM (get >>= set >> get) 10

v10 = runSM (return 0 >> inc >> get) 10

v11 = runSM (get >> return 5) 10

v12 = runSM (inc >> return 0) 10

v13 = runSM (dec >> return 0 >> get) 10

v14 = runSM (get >>= set . (+ 5) >> get) 10

-- ** The do notation

foo2 :: SM Int Int
foo2 = do
  x <- get
  set $ x + 5
  get

v15 = runSM foo2 10

{- What does this do? -}
foo3 = do
  x <- get
  set $ x + 100
  pure ()

-- ** Labeling the tree

label2 :: Tree a -> SM Int (Tree Int)
label2 (Leaf _) = do
  n <- get
  set (n + 1)
  pure (Leaf n)
label2 (Branch t1 t2) = do
  t1' <- label2 t1
  t2' <- label2 t2
  pure $ Branch t1' t2'

labelTree :: Tree a -> Tree Int
labelTree t = runSM (label2 t) 0

{- Exercise 04

  Define the following functions:

    nop :: SM s ()
    reset :: SM Int ()
    update :: (s -> s) -> SM s ()

  Give three definitions for each: (1) a direct definition on the 'SM' type,
  (2) a monadic definition but without using 'do' notation, and (3) a monadic
  definition using 'do' notation.

-}

nop :: SM s ()
nop = SM $ \s -> (s, ())

nop' :: SM s ()
nop' = get >>= set

nop'' :: SM s ()
nop'' = do
  s <- get
  set s

reset :: SM Int ()
reset = SM $ \_ -> (0, ())

reset' :: SM Int ()
reset' = set 0

reset'' :: SM Int ()
reset'' = do
  set 0

update :: (s -> s) -> SM s ()
update updateFn = SM $ \s -> (updateFn s, ())

update' :: (s -> s) -> SM s ()
update' updateFn = get >>= set . updateFn

update'' :: (s -> s) -> SM s ()
update'' updateFn = do
  s <- get
  set $ updateFn s

{- Exercise 05

  1. Define a function
    random' :: (RandomGen g, Random a) => SM g a
  that generates a random number using a RNG 'g' as the state. Internally, the
  function should use the 'random' function.

  2. Define a function
    initRandom :: Int -> SM StdGen ()
  that initializes the RNG with the seed value.

  3. Define a function
    threeRandoms :: SM g (Int,Int,Int)
  that returns three random numbers.
-}

random' :: (RandomGen g, Random a) => SM g a
random' = do
  gen <- get
  let (ra, gen2) = random gen
  set gen2
  return ra

initRandom :: Int -> SM StdGen ()
initRandom seed = set $ mkStdGen seed

threeRandoms :: SM StdGen (Int, Int, Int)
threeRandoms = do
  a <- random'
  b <- random'
  c <- random'
  return (a, b, c)

-- Marin's solution, uses the fact that `random'` is polymorphic
threeRandomsMarin :: SM StdGen (Int, Int, Int)
threeRandomsMarin = random'

-- * Review of useful Monad functions

{-
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
-}

{-
  sequence [] = return []
  sequence (m:ms) = do
      x <- m
      xs <- sequence ms
      return (x:xs)
-}

e1 = sequence [Nothing, Just 1, Just 2]

e2 = sequence [Just 1, Just 2, Nothing]

e3 = sequence [Just 1, Just 2, Just 3]

inc3 = sequence_ [inc, inc, inc]

e4 = runSM (inc3 >> get) 3

e5 = sequence [[1, 2, 3], [4, 5, 6]]

{-
This is equivalent to:

  do
    x <- [1, 2, 3]
    y <- [4, 5, 6]
    return [x, y]

which, in turn, is equivalent to:

  [1,2,3] >>= (\x -> [4,5,6] >>= \y -> return (x : y : []))
-}

e6 = replicateM 10 (Just 1)

-- * A tiny language interpreter

data Expr
  = Val Double
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  | If Expr Expr Expr
  deriving (Eq, Show)

expr = (Val 3) `Add` ((Val 5) `Div` (Val 2))

exampleS :: Int -> Int
exampleS = do
  let a = 12
  initalArgument <- id
  pure (a + initalArgument)

eval :: Expr -> Maybe Double
eval (Val v) = Just v
eval (Add ex1 ex2) = (+) <$> (eval ex1) <*> (eval ex2)
eval (Sub ex1 ex2) = (-) <$> (eval ex1) <*> (eval ex2)
eval (Mul ex1 ex2) = (*) <$> (eval ex1) <*> (eval ex2)
eval (If test trueEx falseEx) = if eval test == (Just 0) then eval falseEx else eval trueEx
eval (Div ex1 ex2) = case eval ex2 of
  Just 0 -> Nothing
  ex -> (/) <$> (eval ex1) <*> ex
