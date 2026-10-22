--------------
-- EXERCISE 1
--------------

-- 1.1.
-- Define a tail-recursive version of `listMaximum` called `tailMaximum`.
-- Is your function less polymorphic than the non-tail-recursive `listMaximum`?
-- Which of these calls compile, and which throw errors?
-- >>> tailMaximum [1 .. 10]
--
-- >>> tailMaximum "haskell"
--
-- >>> tailMaximum ["one", "two", "three"]
--
-- >>> tailMaximum []
tailMaximum :: (Ord a) => [a] -> a
tailMaximum = undefined

--------------
-- EXERCISE 2
--------------

-- 2.1.
-- Define a strict version of `tailMaximum`. Compare its memory footprint to the
-- non-strict version on large inputs (use `:set +s` in GHCi):
-- >>> tailMaximumStrict [1 .. 1000000]
--
-- >>> tailMaximum [1 .. 1000000]
tailMaximumStrict :: (Ord a) => [a] -> a
tailMaximumStrict = undefined
