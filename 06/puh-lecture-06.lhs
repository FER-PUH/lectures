University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2022/2023

LECTURE 6: Recursive functions 2

v1.1

(c) 2017 Jan Snajder, 2022/2023 Filip Sodic

==============================================================================

> import Data.Char
> import Data.List

== INTRO =====================================================================

What we'll talk about in today's lecture:
  - Accumulators and tail recursion
    - Tail-call optimization
    - Guarded recursion
    - Choosing the right kind of recursion
    - Haskell's evaluation model
  - Strict vs non-strict semantics, lazy vs. eager evaluation

==============================================================================

== ACCUMULATORS AND TAIL RECURSION ===========================================

Let's look at the definition of the factorial function again:

> fact1 :: (Eq a, Num a) => a -> a
> fact1 0 = 1
> fact1 x = x * fact1 (x-1)

This function is executed as follows: we go down until we "hit" the base case
and then build up the result incrementally as we return from the recursive
calls. In other words, the final result is built up while we're "on our way
back":

fact1 5                        <-- Descending towards the base case
5 * fact1 4
5 * (4 * fact1 3)
5 * (4 * (3 * fact1 2))
5 * (4 * (3 * (2 * fact1 1)))
5 * (4 * (3 * (2 * 1)))        <-- reached the base case and going back "up"
5 * (4 * (3 * 2))
5 * (4 * 6)
5 * 24
120                            <-- Recursive call fully evaluated

Instead of building the final result on our way back, we can recurse down and
"accumulate" the solution incrementally as we descend. When we "hit" the base
case, we simply return the accumulated solution:

> fact2 :: (Eq a, Num a) => a -> a -> a   -- the second arg. is the accumulator
> fact2 0 acc = acc
> fact2 n acc = fact2 (n - 1) (n * acc)

To make the API more user-friendly, we can define a wrapper function that sets
the initial value. 

> fact3 :: (Eq a, Num a) => a -> a
> fact3 n = fact2 n 1

'fact3' is the function we expose to our users (we could define the inner
'fact2' function using the 'where' clause).

All recursive functions from the previous lecture were defined with
"traditional" recursion, but we can also define them using an accumulator. For
example, instead of:

> sum1 :: Num a => [a] -> a
> sum1 [] = 0
> sum1 (current:rest) = current + sum1 rest

We could write:

> sum2 :: Num a => [a] -> a
> sum2 numbers = sum numbers 0
>   where sum [] result = result
>         sum (current:rest) result = sum rest (result + current)

If the result of the recursive call is the final result of the function itself,
we say that the function is TAIL RECURSIVE. If the result of the recursive call
must be further processed (e.g., by adding 1 to it or consing another element
onto the beginning of it), it is not tail recursive. 'fact2' and 'sum2' are
tail-recursive functions, while 'fact1' and 'sum1' aren't.


OPTIONAL: Read more about tail recursion:
  - Quote from Brent Yorgey:
    http://www.haskell.org/pipermail/haskell-cafe/2009-March/058607.html
  - Stack overflow explanation: https://stackoverflow.com/a/37010

But why would we want to write tail-recurisve functions? Isn't it all the same?

Not necessarily. Tail-recursive definitions can be more preformant (generally
in terms of memory, but sometimes also in terms of time).

Let's first see how tail recursion affects time complexity by looking at the
reverse function:
 
> reverse1 :: [a] -> [a]
> reverse1 [] = []
> reverse1 (x:xs) = reverse1 xs ++ [x]

The time complexity of this implementation is as much as O(n^2). Can you say why?

Accumulator-style version:

> reverse2 :: [a] -> [a]
> reverse2 xs = rev xs []
>   where rev [] ys = ys
>         rev (x:xs) ys = rev xs (x:ys)

What is the complexity of this function?

More on reversing lists in Haskell: https://stackoverflow.com/a/26847373
  
How does tail recursion affect space complexity?

To calculate a value of an expression containing a recursive function call, we
must first perform this call and obtain its value (as was the case with
'fact1'). We can only evaluate the rest of the expression after returning from
the recursive call. Conceptually, this means that recursive expressions
gradually grow larger, and we can only start reducing them after we've reached
the base case.

Different languages and compilers take different approaches to implementing
nested function calls, but they have the same implications on space complexity.

The most popular evaluation strategy (used in C, Java, JavaScript, Python,
etc.) uses a preallocated execution stack. Before executing the nested function
call, the compiler pushes the caller's context and return address onto the
stack. After executing the nested function call, the previously pushed context
is restored, allowing the calling function to continue where it left off. The
stack grows with each function call - if there's only a single recursive call
that is invoked 'n' times, we'll be creating 'n' stack frames, giving us a
space complexity of O(n), as was the case with 'fact1'.

Haskell performs nested function calls using a different evaluation strategy
called "graph reduction." Instead of creating a new stack frame for each
function call, this strategy constructs a nested pile of "thunks" (i.e., data
structures pending evaluations) on the heap. For example, after reaching the
base case of 'fact1 5', we end up with the following structure (chain of
thunks) on the heap:

5 * (4 * (3 * (2 * 1)))

The space complexity is still linearly dependent on the number of recursive
calls - if we have 'n' recursive calls, we'll have n thunks, giving us a space
complexity of O(n).

OPTIONAL: Read more about Haskell's evaluation model:
  - https://en.wikibooks.org/wiki/Haskell/Graph_reduction
  - https://takenobu-hs.github.io/downloads/haskell_lazy_evaluation.pdf
  - https://stackoverflow.com/questions/43265198/do-stack-overflow-errors-occur-in-haskell
  - https://stackoverflow.com/a/13787390

OPTIONAL: Visualizing Haskell data structures in GHCi
  - http://felsin9.de/nnis/ghc-vis/
  - https://hackage.haskell.org/package/ghc-heap-view

Let's see what happens if the recursive call is NOT a part of a larger
expression (i.e., the function is tail recursive), assuming a stack-based
evaluation strategy. After the recursion hits its base case, there's no need to
go back - there's nothing left to do. All that non-base case recursive calls do
is forward the already calculated result to their caller, all the way to the
top.

Therefore, there's no need to save each call's return address and context. We
can instead simply update (overwrite) the arguments and jump back to the start
of the function. After reaching the base case, the function returns the result
to the original caller. We have essentially turned a recursive call into a
jump/goto with parameters. This trick is called TAIL CALL OPTIMIZATION, and
some compilers (including GHC) will detect tail calls and automatically
optimize them.
Since a tail-recursive function only needs a single stack frame regardless of
the input size, its space complexity is constant, O(1). As mentioned, Haskell
does not use a call stack, but GHC still optimizes tail-recursive calls and
reduces their space complexity to O(1)*. Instead of creating a long recursive
structure on the heap, it's enough to only store and update a single result.

* This is not 100% true, but we'll come back to it.

OPTIONAL: Read more about TCO:
  - https://stackoverflow.com/a/310980

Therefore, 'fact1' and 'sum1' have a space complexity of O(n), while 'fact2'
and 'sum2' have a space complexity of O(1). Once again, this is actually a soft
lie. The full truth is: They would be O(1) if they weren't lazy. We'll explore
this in a bit.

Here's a standard version of a `listMaximum` function.

> listMaximum :: Ord a => [a] -> a
> listMaximum [] = error "empty list"
> listMaximum [x] = x
> listMaximum (x:xs) = x `max` listMaximum xs

== EXERCISE 1 ================================================================

1.1.

- Define a tail recursive version of `listMaximum` called `tailMaximum`.

  Is your function less polymorphic than non-tail recursive `listMaximum`?
  Which calls can you make, and which calls throw compile errors:
    tailMaximum [1..10]
    tailMaximum "haskell"
    tailMaximum ["one", "two", "three"]

  Compare that with `listMaximum`.

== GUARDED RECURSION ==========================================================

Sometimes, using an accumulator doesn't even make sense to begin with. One such
example is the 'incList' function:

> incList1 :: Num a => [a] -> [a]
> incList1 [] = []
> incList1 (curr:rest) = curr + 1 : incList1 rest

The space complexity of this function is O(1).

NOTE:
The constructed list is not counted towards the space complexity. We only care
about the additional memory we need to allocate for the computation. Once again,
it's worth mentioning that Haskell does not use stack frames for nested calls.
Instead, it builds a structure (a chain of thunks) on the heap. In this case,
the constructed structure represents our final result and is therefore not
counted towards the function's space complexity. This wasn't the case in the
'fact1' function. The desired result of 'fact1 5' is 120, but the constructed
structure is '5 * (4 * (3 * (2 * (1))))', giving us a space complexity of O(n).

Let's take a shot at implementing 'incList' using tail-recursion:

> incList2 :: Num a => [a] -> [a]
> incList2 numbers = inc numbers []
>   where inc [] incremented = reverse incremented
>         inc (curr:rest) incremented = inc rest ((curr + 1):incremented)

> incList3 :: Num a => [a] -> [a]
> incList3 numbers = inc numbers []
>   where inc [] incremented = incremented
>         inc (curr:rest) incremented = inc rest (incremented ++ [curr + 1])

Prepending is done in O(1), while concatenation is done in O(n) where n is the
size of the first list. Therefore, we can choose to either:
 - Build the accumulator in reverse and reverse it at our base case (incList2),
   giving us a time complexity of O(n).
 - Build the accumulator using concatenation instead of prepending (incList3),
   giving us a time complexity of O(n^2).

Moreover, tail-recursion doesn't save memory in this case, as the space
complexity of 'incList1' was already O(1).

Another example is 'unzip'. We may give it a try with an accumulator:

> unzip' :: [(a,b)] -> ([a],[b])
> unzip' zipped = unz zipped ([], [])
>   where unz [] unzipped = unzipped
>         unz ((x, y):restZipped) (xs, ys) = unz restZipped (x:xs, y:ys)

But this again doesn't work because of the same reason: we end up with lists in
reverse order. We could reverse the input list first, but that would require
two list traversals (one for the reversal and one for unzipping).

Hence in this case too we should resort to "traditional" recursion:

> unzip'' :: [(a,b)] -> ([a],[b])
> unzip'' [] = ([], [])
> unzip'' ((x, y):zs) = (x:xs, y:ys)
>   where (xs, ys) = unzip'' zs

The two functions above ('incList' and 'unzip') have one thing in common: they
use recursion to *incrementally* create the output list(s). The result starts
being available immediately and continues to grow as the recursion progresses.
Because Haskell is LAZY, if we consume just the first part of the result, the
recursion will never generate results beyond that point since those results
aren't needed. In other words, the result of the function can be CONSUMED
LAZILY. This is called GUARDED RECURSION. In guarded recursion, the recursive
call occurs within a lazy "data constructor" (cons operator ':' in this case).
Because of laziness, Haskell will evaluate the expression up to the data
constructor and delay the recursive call until it's needed.

Notice that guarded recursion is not tail-recursive. However, there is nothing
left to be done after exiting the recursive call, so space complexity is O(1).
Hence we call such recursion TAIL RECURSION MODULO CONS.

Guarded recursion is the reason why Haskell's concatenation operator is so
efficient:

> plusplus :: [a] -> [a] -> [a]
> plusplus [] list2 = list2
> plusplus (x:xs) list2 =  x : plusplus xs list2

Real definition of the cons operator ('++'):
https://hackage.haskell.org/package/base-4.17.0.0/docs/src/GHC.Base.html#%2B%2B

The expression 'plusplus l1 l2' starts producing values immediately, there's no
need to wait for the function to reach its base case before we start consuming
its return value.

> listHead = head $ [1..10000000] ++ [1..10000000]

SUMMARY:
Tail recursion and guarded recursion can reduce a function's space and time
complexities:

  - Use tail recursion (i.e., accumulator-style) when you need a result that
    depends on the entire input structure (e.g., sum, max, length, etc.).

  - Use guarded recursion (i.e., tail recursion modulo cons) if your result
    doesn't depend on the entire input structure and you wish to consume it
    lazily (e.g., filtering a list, processing each element into a new list).


More on guarded recursion vs tail recursion:
  - https://stackoverflow.com/a/4092957
  - https://wiki.haskell.org/Tail_recursion
  - https://en.wikipedia.org/wiki/Tail_call#Tail_recursion_modulo_cons

== STRICTNESS AND LAZINESS ====================================================

We have been talking a lot about how Haskell is a non-strict/lazy language. The
terms non-strict and lazy are often used interchangeably, but they don't quite
mean the same thing.

A FUNCTION IS STRICT if, when applied to a non-terminating expression (e.g., a
call that loops infinitely or throws an exception), it also fails to terminate.
For example, in most languages, the expression:

    f(g(), functionWithAnInfiniteLoop())

Will enter an infinite loop regardless of what 'f' does with its arguments.

A PROGRAMMING LANGUAGE IS STRICT if all user-defined functions are strict
(e.g., C, Java, Python).
Why emphasize user-defined functions? Becuase most strict languages have a
couple of built-in non-strict constructs. The expression (in let's
say C):

    g() && functionWithAnInfiniteLoop()

Will not enter an infinite loop if g() returns 'false'. Since '&&' will only
evaluate its second argument if the first one is 'true', we can say that the
'&&' operator is non-strict in its second argument (as is '||').

LAZINESS is one possible way of implementing non-strict semantics. For example,
non-strictness could also be implemented by running all expressions in parallel
and throwing away unneeded results.

Lazy evaluation in Haskell means that each expression is evaluated:
 - Only when it's needed (e.g., someone wants to consume the result).
 - Only enough (e.g., only the beggining of the list if you need head).
 - Only once (e.g., evaluation replaces the thunk with the result).

Therefore, saying that Haskell is a non-strict lazy language means that Haskell
features non-strict semantics implemented via lazy evaluation. In practice,
this means that Haskell won't evaluate an expression until someone asks for the
result:

> e1 = head [1, 2..]

How does that work? As previously described, instead of evaluating the complete
list, Haskell generates a so-called THUNK or SUSPENSION -- a pointer to the
expression and a data structure containing all data required to evaluate the
expression. This thunk will only be evaluated when needed.

OPTIONAL: Read more non-strictness, laziness, and their benefits:
  - http://www.haskell.org/haskellwiki/Lazy_vs._non-strict
  - https://stackoverflow.com/a/7868790

While in most cases we want the evaluation to be lazy, occasionally lazy
evaluation becomes problematic. For example, we absolutely need lazy evaluation
for this to work:

> filterOdd :: [a] -> [a]
> filterOdd numbers = [n | (i, n) <- zip [0..] numbers, odd i]

On the other hand, recall the sum function:

> sumAcc :: Num a => [a] -> a
> sumAcc numbers = sum numbers 0
>   where sum [] sumSoFar = sumSoFar
>         sum (n:rest) sumSoFar = sum rest (sumSoFar + n)

> e2 = sumAcc [0..100]
> e3 = sumAcc [0..1000000000]

Note that we're using an accumulator here, so this is supposed to be space
efficient because it's tail recursive. But despite this, we have a problem
because '(x + s)' won't be evaluated until it is needed.

Instead, it will build up a large thunk:

  sumAcc [0..10] =>
  => sum (0:[1..10]) 0
  => sum (1:[2..10]) (0+0)
  => sum (2:[3..10]) (1+(0+0))
  => sum (3:[4..10]) (2+(1+(0+0)))
  => sum (4:[5..10]) (3+(2+(1+(0+0))))
  => ...

This causes a MEMORY LEAK (and a very dangerous one). Since there's no
execution stack involved, nothing will overflow and terminate the expression.
Instead, A thunk builds up on the heap, consuming more and more space, until it
finally gets evaluated. If Haskell runs out of memory before it finishes
building the thunk, that's a big problem (try evaluating e3 after the lecture,
but make sure to save your work before you do :).
Even if we have enough memory to fully construct and evaluate the thunk, it's
still less than ideal because thunks consume a lot more memory than the values
they end up evaluating to (as demonstrated by 'sumAcc'). To prevent this from
happening, we need a way to FORCE the evaluation of '(x + s)'.

Luckily, there's a function that does exactly that:

  seq :: a -> b -> b

The function 'seq' evaluates its first argument before it returns its second
argument.

For example:

> e4 = let x = undefined in 2
> e5 = let x = undefined in x `seq` 2
> e6 = let x = undefined in x `seq` snd (x, 5)

We can now define a strict version of sumAcc:

> sumAccStrict :: Num a => [a] -> a
> sumAccStrict numbers = sum numbers 0
>   where sum [] sumSoFar = sumSoFar
>         sum (n:rest) sumSoFar = let tmp = sumSoFar + n in tmp `seq` sum rest tmp
  
> e7 = sumAccStrict [0..1000000000]

We can also define a strict version of the application operator ($):

  ($!) :: (a -> b) -> a -> b
  f $! x = x `seq` f x

'f $! x' will first evaluate the argument 'x', and then apply a function to it.

For example:

> e8 = let x = undefined in const 5 x
> e9 = let x = undefined in const 5 $! x

It's important to understand that 'seq' does not evaluate "too deep". If
expressions have structure, 'seq' will only "scratch the surface." In
theoretical terms, this is called "reducing an expression to its weak head
normal form (WHNF)"

For example:

> e10 = let x = (undefined, 42) in x `seq` snd x

Here, 'seq' evaluated only the outermost structure (which is the pair
constructor), and did not proceed to evaluate the actual content of the pair.

When this is not enough, we need to make sure that 'seq' is applied recursively
to subexpressions. You can use the 'deepseq' package for this:
http://hackage.haskell.org/package/deepseq

OPTIONAL: Read more on 'seq':
  - https://stackoverflow.com/questions/66943741/what-does-seq-actually-do-in-haskell


== EXERCISE 2 ================================================================

2.1.

- Define a strict verion of of `tailMaximum`. Compare its memory footprint to the
  non-strict version on large inputs:
      :set +s 
      tailMaximumStrict [1..1000000]
      tailMaximum [1..1000000]

===============================================================================

SUMMARY:

Haskell is non-strict and lazy by default, you can force strictness using
'seq', '$!', and 'deepseq'.
When using tail recursion, make sure to force strict evaluation of the
accumulator. If you don't, tail recursion doesn't reduce memory consumption, it
merely moves it to a different place (i.e., recursive calls take O(1) space,
but the accumulator thunk takes O(n) space).

OPTIONAL: Read more about strictness and its implications on tail recursion:
  - https://stackoverflow.com/a/13052612

== NEXT ======================================================================

In Haskell, a function is a first-class value (like Int or Char). Next, we'll
look at HIGHER ORDER FUNCTIONS (HOF), which are functions that take or return
other functions. HOF allow for functional design patterns, which make our code
more structured, more modular, and more comprehensible.
