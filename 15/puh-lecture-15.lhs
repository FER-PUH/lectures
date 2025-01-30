University of Zagreb
Faculty of Electrical Engineering and Computing

(c) 2017 Jan Šnajder, 2022 Martin Sosic

PROGRAMMING IN HASKELL

Academic Year 2024/2025

LECTURE 15: Tying up loose ends

(c) 2024 Martin Sosic, 2025 Filip Sodic

> import Data.Text (Text)
> import Debug.Trace (trace)
> import Control.Monad (replicateM, replicateM_, join, liftM, liftM2)

This is the last lecture of PUH!

The idea of this lecture is to cover anything we skipped in the previous
lectures but think is nevertheless worth covering.

== Error/Exception handling in Haskell ==============================

Explanation from Haskell Wiki (https://wiki.haskell.org/Error_vs._Exception):

  ERROR = mistake in the running program that can be resolved only by fixing the program
  EXCEPTION = expected but irregular situations at runtime

in other words:

  ERROR = programmer bug, that we don't know how to recover from and
          will often let it crash the whole program. Other languages often use `assert` for this.
  EXCEPTION = tricky situation caused by external world that we often want to recover from,
              to some degree at least.

For errors, we use `error`!

For exceptions, we use:
  - Maybe         -> 1 possible exception
  - Either        -> N possible exceptions (consider using custom data vs String)
  - IO Exceptions -> In IO

Q: When in IO code, should I use Either or IO exceptions or both?
A: Depends on situation! Either is more explicit and forces immediate handling,
   while IO exceptions can be ignored, so depends what you need -> how much
   do you want the consumer of your function to worry about specific exceptions.

= Examples:

> safeDiv :: Int -> Int -> Maybe Int
> safeDiv = undefined

> readTextFile :: String -> IO (Either ReadFileException Text)
> readTextFile = undefined
> data ReadFileException = NoSuchFile | MissingPermissions | WrongFormat

= IO Exceptions

Most similar to "normal" exceptions -> exceptions in other languages.

Can be thrown from pure or IO code, but can be handled only within IO monad.
Prefer not throwing it from pure code though, if possible.

Functions from the 'Control.Exception':

  throwIO :: Exception e => e -> IO a
  throw :: forall a e. Exception e => e -> a   -- Avoid this one if possible

  try :: Exception e => IO a -> IO (Either e a)
  catch :: Exception e => IO a -> (e -> IO a) -> IO a
  bracket :: IO a -> (a -> IO b) -> (a -> IO c) -> IO c


== Debugging ========================================================

Don't worry, you can print debug in Haskell too!

import Debug.Trace (trace)

trace :: String -> b -> b

> add x y = x + y

> add' x y = trace message (x + y)
>   where message = "Adding " ++ show x ++ " and " ++ show y
