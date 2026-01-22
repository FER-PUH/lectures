module Exercises where

import           Lecture       (State (..), get, put)
import           System.Random (Random (random), RandomGen, StdGen, mkStdGen)

{- EXERCISE 1

  Solve the following problems in the state monad 'State s a'.
-}

{- 1.1.
  Define the following functions:
    - nop :: State s ()
    - reset :: State Int ()
    - modify :: (s -> s) -> State s ()
  Give three definitions for each:
    (1) a direct definition on the 'State' type,
    (2) a monadic definition but without using 'do' notation, and
    (3) a monadic definition using 'do' notation.
-}

nop :: State s ()
nop = undefined

nop' :: State s ()
nop' = undefined

nop'' :: State s ()
nop'' = undefined

reset :: State Int ()
reset = undefined

reset' :: State Int ()
reset' = undefined

reset'' :: State Int ()
reset'' = undefined

modify :: (s -> s) -> State s ()
modify = undefined

modify' :: (s -> s) -> State s ()
modify' = undefined

modify'' :: (s -> s) -> State s ()
modify'' = undefined

{- 1.2.
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
-}

random' :: (Random a, RandomGen g) => State g a
random' = undefined

initRandom :: Int -> State StdGen ()
initRandom = undefined

threeRandoms :: RandomGen g => State g (Int,Int,Int)
threeRandoms = undefined
