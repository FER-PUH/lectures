-- Load the lecture inside a GHCi session and try these examples out:
-- Use the :set +s flag where appropriate
-- flags
-- :set +s

-- show list copying
last [1 .. 100000000]
last $ [1] ++ [1 .. 100000000]
last $ [1 .. 100000000] ++ [1]

-- Tail vs standard recursion 1
fact3 5
fact1 5

-- Tail vs standard recursion 2
sum1 [1 .. 10]
sum2 [1 .. 10]

-- Tail vs standard recursion 3
reverse1 [1 .. 2000000]
reverse2 [1 .. 2000000]

-- Prepend vs append list
incList2 [1 .. 1000000]
incList3 [1 .. 1000000]

-- Tail vs Guarded recursion
head $ incList2 [1 .. 1000000]
head $ incList3 [1 .. 1000000]
head $ incList1 [1 .. 1000000]

-- Strict vs non-strict tail recursion (make sure to monitor system memory).
sumAcc [0 .. 100]
sumAcc [0 .. 12000000]
sumAccStrict [0 .. 12000000]

sumAcc [0 .. 15000000] -- stack overflow
sumAccStrict [0 .. 15000000] -- works
