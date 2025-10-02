# Cheatsheet
Basically the examples from the .lhs files with no text
## Table of Contents
- [Basics](#basics)
  - [Basics of Functions & Control Flow](#basics-of-functions--control-flow)
  - [Basic function definition](#basic-function-definition)
  - [If-then-else](#if-then-else)
  - [Guards](#guards)
  - [List construction (:)](#list-construction)
  - [Concatenation (++)](#concatenation)
  - [head](#head)
  - [tail](#tail)
  - [last](#last)
  - [init](#init)
  - [indexing (!!)](#indexing-)
- [Sub-lists](#sub-lists)
  - [take](#take)
  - [drop](#drop)
  - [trim](#trim)
  - [reverse](#reverse)
- [Infinite list construction](#infinite-list-construction)
  - [repeat](#repeat)
  - [cycle](#cycle)
  - [replicate](#replicate)
- [List intervals](#list-intervals)
- [Strings](#strings)
  - [padding example](#padding-example)
- [Lists of lists](#lists-of-lists)
  - [nested lists](#nested-lists)
  - [concat](#concat)
- [Lookup & conversion](#lookup--conversion)
  - [indexing](#indexing)
  - [intToChar](#inttochar)
- [Reductions](#reductions)
  - [minimum / maximum](#minimum--maximum)
  - [logical and/or](#logical-andor)
- [Transformations](#transformations)
  - [nub](#nub)
  - [sort](#sort)
- [Membership & emptiness](#membership--emptiness)
  - [elem / notElem](#elem--notelem)
  - [null](#null)

- [Common error cases](#common-error-cases)

---

## Basics

## Basics of Functions & Control Flow

### Basic function definition
```haskell
x = 2           -- defining a value
inc x = x + 1   -- single-argument function
digitsToNumber x y = x * 10 + y  -- multi-argument function

-- Example applications
y = inc 2
z = digitsToNumber 4 2
```

### If-then-else
```haskell
condDec x = if x > 0 then x - 1 else x

foo x = (if even x then x*2 else 2) + 1

-- Avoid unnecessary explicit True/False
bigNumber x = if x >= 1000 then True else False
bigNumber' x = x >= 1000

-- Working with strings
compareStrings s1 s2 =
  s1 ++ " comes " ++ (if s1 < s2 then "before " else "after ") ++ s2
```

### Guards
```haskell
compareStrings' s1 s2
  | s1 < s2   = s1 ++ " comes before " ++ s2
  | otherwise = s1 ++ " comes after " ++ s2

grade score
  | score < 50 = 1
  | score < 63 = 2
  | score < 76 = 3
  | score < 89 = 4
  | otherwise  = 5

showSalary amount bonus
  | bonus /= 0 = "Salary is " ++ show amount ++ ", and a bonus " ++ show bonus
  | otherwise  = "Salary is " ++ show amount
```



### List construction
```haskell
1 : [2,3] == [1,2,3]
```
(`:` prepends an element)

### Concatenation
```haskell
[1,2] ++ [3,4] == [1,2,3,4]
```

### head
```haskell
head [1,2,3] == 1
```

### tail
```haskell
tail [1,2,3] == [2,3]
```

### last
```haskell
last [1,2,3] == 3
```

### init
```haskell
init [1,2,3] == [1,2]
```

### indexing `!!`
```haskell
[10,20,30] !! 1 == 20
```

---

## Sub-lists

### take
```haskell
take 2 [1,2,3] == [1,2]
```

### drop
```haskell
drop 2 [1,2,3,4] == [3,4]
```

### trim
NOTE:  this is just an example, the function is not in the standard library
```haskell
trim xs  = tail (init xs)
trim' xs = init (tail xs)
```

### reverse
```haskell
reverse [1,2] == [2,1]
```

---

## Infinite list construction

### repeat
```haskell
repeat 0 == [0,0,0,...]
```

### cycle
```haskell
cycle [1,2] == [1,2,1,2,...]
```

### replicate
```haskell
replicate 5 'a' == "aaaaa"
```

---

## List intervals
```haskell
[1..3]     == [1,2,3]
[1,3..7]   == [1,3,5,7]
[1,3..8]   == [1,3,5,7]
[1,3..10]  == [1,3,5,9]
[1..]      == [1,2,3,...] -- infinite list
```

---

## Strings

### A string is just a list of characters
```haskell
['a','b'] == "ab"
```

### padding example
```haskell
blanks = repeat ' '
padTo10 s  = s ++ take (10 - length s) blanks
```

---

## Lists of lists

### nested lists
```haskell
[[1,2,3],[4,5,6],[7,8,9,10]]
["red","green","blue"]
```

### concat
```haskell
concat [[1,2],[3,4]] == [1,2,3,4]
```

---

## Lookup & conversion

### indexing
```haskell
[1,3..100] !! 3  -- 7
[[1,2,3],[4,5,6]] !! 1 !! 2 == 6
```

### intToChar
```haskell
intToChar  i = ['A'..] !! (i - 65)

intToChar' i
  | i >= 65   = ['A'..] !! (i - 65)
  | otherwise = error "Index should be at least 65"
```

---

## Reductions

### minimum / maximum
```haskell
minimum [4,1,2,3] == 1
maximum "Haskell for the win!" == 'w'
```

### logical and/or
```haskell
and [True,True,False] == False
or  [True,True,False] == True
```

---

## Transformations

### nub
```haskell
nub [1,2,3,1,2] == [1,2,3]
nub "hello"     == "helo"
```

### sort
```haskell
sort [3,1,2] == [1,2,3]
sort "cab"   == "abc"
```

---

## Membership & emptiness

### elem / notElem
```haskell
'a' `elem` "cat"      == True
'z' `notElem` "cat"   == True
```

### null
```haskell
null []     == True
null [1,2]  == False
```

👉 Prefer `null xs` over `length xs == 0`  *(works for infinite lists)*

👉 Prefer `null xs` over `xs == []`  *(works for all containers, no `==` needed on elements)*

---

## Common error cases

- **Empty list access**
  ```haskell
  head []    -- error: Prelude.head: empty list
  tail []    -- error: Prelude.tail: empty list
  ```

- **Indexing out of bounds**
  ```haskell
  [1,2,3] !! 5  -- error: Prelude.!!: index too large
  ```
