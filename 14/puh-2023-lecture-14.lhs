University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2023/2024

LECTURE 14: Monads 2

v1.0

(c) 2017 Jan Šnajder

==============================================================================

> import Data.List
> import Control.Monad
> import Data.Maybe
> import System.Random

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

> data Tree a = Leaf a | Branch (Tree a) (Tree a) deriving (Show,Eq)

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
> (r1,g2) = random g :: (Int, StdGen)
> (r2,g3) = random g2 :: (Int, StdGen)
> (r3,g4) = random g3 :: (Int, StdGen)

In both cases we have to drag around a state: each function takes the current
state as an argument and yields a return a value plus the updated state. This
can be nicely abstracted with a state monad. Its type is

> data SM s a = SM (s -> (s, a))

So, the state monad is actually a *function* that takes a state and returns a
new state and a return value. Binding together a sequence of such functions
will give a single function that effectively performs statefull computation. We
then can apply this function to an initial state.

First, let's make 'SM' an instance of the 'Monad' type class:

> instance Functor (SM s) where
>   fmap f (SM a) = SM $ \s -> let (s', a') = a s in (s', f a')
>
> instance Applicative (SM s) where
>   pure a = SM (\s -> (s,a))
>   SM f <*> (SM a) = SM $ \s ->
>     let (s',f') = f s
>         (s'', a') = a s'
>     in (s'', f' a')
>
> instance Monad (SM s) where
>
>   return a = SM (\s -> (s, a))
>
>   SM sm0 >>= fsm1 = SM $ \s0 ->
>     let (s1,a1) = sm0 s0  -- left computation on the state
>         SM sm1 = fsm1 a1  -- the computation of the "right monad"
>         (s2,a2) = sm1 s1  -- right computation on the state
>     in (s2,a2)

'return a' gives us a function that takes a state and returns the unaltered
state together with a return value 'a'. The definition of binding operator
(>>=) is a bit more intricate. Let's remind ourselves of its type:

  (>>=) :: m a -> (a -> m b) -> mb

The bind operator needs to unwrap the left 'm a' value, which is actually a
function. This function is applied to the initial state, which gives a new
state and a result. The result is passed to the function 'a -> m b', which
gives 'm b', which again is a function. This function is then applied to the
state to alter the state once again, and return the final result. The overall
result is a actually a function that alters the state and returns a value.

An example:

> inc :: SM Int ()
> inc = SM (\s -> (s+1, ()))

> dec :: SM Int ()
> dec = SM (\s -> (s-1, ()))

> foo :: SM Int ()
> foo = inc >> inc >> inc

How can we run this? We need a function that "runs the monad". More concretely,
the function needs to (1) take a value of the 'SM' type and unwrap the function
from it, (2) take the initial state, and (3) apply the function on the initial
state.

> runSM' :: SM s a -> s -> (s, a)
> runSM' (SM sm0) s0 = sm0 s0     -- can we make this shorter?

Let's try it out:

> v1 = runSM' foo 10
> v2 = runSM' (dec >> inc >> dec) 0

The above examples suggest that we can think of a monad as a sequence of
computations that wait to be executed.  Using the (>>=) operator, we bind
together the individual computations into one big chain. This chain is actually
one large function that needs to be applied to an initial state. When we want
to execute this chain of computation, we use the 'runSM' function, which
unwraps our function and applies it to the initial state.

In most cases we only need the return value of a computation and don't care
about the final state. Thus, we can define:

> runSM :: SM s a -> s -> a
> runSM (SM sm0) = snd . sm0

Let's try it out:

> v3 = runSM foo 10

Of course, the return value is (), because all we did was changing the state,
which we now have discarded. We must somehow transfer the state to the return
value. But this is easy:

> get :: SM s s
> get = SM (\s -> (s, s))

> v4 = runSM (foo >> get) 10

How would you go about defining the 'set' function? What is its type?

> set :: s -> SM s ()
> set a = SM (\_ -> (a, ()))

> v5 = runSM (set 5) 10
> v6 = runSM (set 5 >> get) 10
> v7 = runSM (set 5 >> inc >> get) 10

Your turn now: what's the result of the following computations?

> v8 = runSM (get >>= set) 10
> v9 = runSM (get >>= set >> get) 10
> v10 = runSM (return 0 >> inc >> get) 10
> v11 = runSM (get >> return 5) 10
> v12 = runSM (inc >> return 0) 10
> v13 = runSM (dec >> return 0 >> get) 10
> v14 = runSM (get >>= set . (+5) >> get) 10

Statefull computation becomes more readable if use the 'do' notation. For
example, the last computation from above:

> foo2 :: SM Int Int
> foo2 = do
>   x <- get
>   set $ x + 5
>   get

> v15 = runSM foo2 10

What is the following function doing and what is its type?

> foo3 = do
>   x <- get
>   set $ x + 100
>   return ()

Great! We are now ready to tackle the problem we started with: labeling the
nodes of a tree.

> label2 :: Tree a -> SM Int (Tree Int)
> label2 (Leaf _) = do
>   n <- get
>   inc
>   return (Leaf n)
> label2 (Branch t1 t2) = do
>   t1' <- label2 t1
>   t2' <- label2 t2
>   return $ Branch t1' t2'

> labelTree :: Tree a -> Tree Int
> labelTree t = runSM (label2 t) 0

== EXERCISE 1 =================================================================

Solve the following problems in the state monad 'SM s a'.

1.1.
- Define the following functions:
    nop :: SM s ()
    reset :: SM Int ()
    update :: (s -> s) -> SM s ()
  Give three definitions for each: (1) a direct definition on the 'SM' type,
  (2) a monadic definition but without using 'do' notation, and (3) a monadic
  definition using 'do' notation.

1.2.
- Define a function
    random' :: (RandomGen g, Random a) => SM g a
  that generates a random number using a RNG 'g' as the state. Internally, the
  function should use the 'random' function.
- Define a function
    initRandom :: Int -> SM StdGen ()
  that initializes the RNG with the seed value.
- Define a function
    threeRandoms :: SM g (Int,Int,Int)
  that returns three random numbers.

== LIST MONAD ================================================================

A list (more precisely: the '[]' type constructor) is also a monad instance. It
is defined as follows:

  instance Monad [] where
    return x = [x]
    xs >>= f = concat (map f xs)
    fail _ = []

m1 >> m2 = m1 >>= \_ -> m2

The (>>=) operator simply maps the function 'f' over the given list as its
left argument. Because 'f' itself returns a list, we end up with a list of
lists, which we than flatten out into a single list using 'concat'. For
example:

> l1 = [1, 2, 3] >>= \x -> [x, x^2]

This is equivalent to:

> l2 = do
>   x <- [1,2,3]
>   [x, x^2]

which probably is more readable.

What about the following computation?

> l3 = [1,2,3] >> [4,5,6]

This is equivalent to:

> l3' = [1,2,3] >>= \_ -> [4,5,6]

Another example:

> tuples = do
>   n <- [1..10]
>   c <- "abc"
>   return (n, c)

We end up with a list of pairs (Cartesian product [1..10]*"abc"). We could have
accomplished the same using a list comprehension:

> tuples' = [(n,c) | n <- [1..10], c <- "abc"]

We now see that a list comprehension is just syntactic sugar for a list monad.

What is the following function doing?

> fooo [] = [[]]
> fooo xs = do
>   x <- xs
>   ys <- fooo (delete x xs)
>   return (x:ys)

> tuples2 = do
>   n <- [1..10]
>   guard $ n >= 5
>   c <- "abc"
>   return (n, c)

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
> e4 = runSM (inc3 >> get) 3

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

> e8 = runSM (inc30 >> dec >> get) 0

Let's consider some other useful functions.

The function

  (=<<) :: Monad m => (a -> m b) -> m a -> m b

is the same as bind operator (>>=) but with arguments flipped. We can use this
function when the data flow is from right to left, as is the case with
functional composition in pure code. Therefore, this operators makes sense when
we mix pure and monadic code. For example:

> main5 =
>   putStr . unlines . filter (not . null) . lines =<< getContents

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
  join m =  m >>= id

This function might seem dull at first, but it's actually quite interesting
from a theoretical point of view because it gives us an alternative definition
of a monad. Assume that 'm' is an instance of 'Functor'. This means that we
have at our disposal the 'fmap' function:

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

Nonetheless, as we've seen, in Haskell the (>>=) operator is not defined via
'join'. If this were the case, every monad instance would also have to be a
functor instance (and this really is the case in Category Theory).
More:
http://en.wikibooks.org/wiki/Haskell/Category_theory#Monads

One very useful function is 'liftM':

  liftM :: Monad m => (a -> b) -> m a -> m b
  liftM f m = m >>= \x -> return (f x)

or

  liftM f xs = xs >>= (return . f)

This function unwraps a value from a monad, applies to this the function 'a ->
b', and then wraps up the resulting value back into the monad. We say that the
function LIFTS an ordinary (pure) function into a monad.

For example:

> e11 = liftM (+1) (Just 5)

> e12 = liftM (unlines . filter (not . null) . lines) getContents

> e13 = liftM signum [1,2,3]

We can see that the 'liftM' is actually the same as 'fmap' (which, when it
comes to lists, is in turn is the same as 'map'). The difference between
'liftM' and 'fmap' is that the former is defined for 'Monad' instances, whereas
the latter is defined for 'Functor' instances.

We often use the 'liftM' function within the IO monad, when we want to apply a
pure function on the result of an IO action. For example

> catZipped :: FilePath -> FilePath -> IO ()
> catZipped f1 f2 = do
>   xs <- lines `liftM` readFile f1
>   ys <- lines `liftM` readFile f2
>   putStr . unlines $ zipWith (++) xs ys

There also is a binary version of the 'liftM' function:

  liftM2 :: (Monad m) => (a -> b -> c) -> m a -> m b -> m c
  liftM2 f m1 m2 =
      m1 >>= \a ->
      m2 >>= \b ->
      return (f a b)

or

  liftM2 f m1 m2 = do
    a <- m1
    b <- m2
    return $ f a b

For example, we can use the 'liftM2' function in a 'Maybe' monad:

> e14 = liftM2 (+) (Just 2) (Just 3)
> e15 = liftM2 (+) (Just 2) Nothing

> e16 = liftM2 (+) [1,2,3] [4,5,6]

Another example: evaluation of an arithmetic expression.

> data Expr =
>     Val Double
>   | Add Expr Expr
>   | Sub Expr Expr
>   | Mul Expr Expr
>   | Div Expr Expr
>   deriving (Show,Eq)

> ex = (Val 3) `Add` ((Val 5) `Div` (Val 0))

> eval :: Expr -> Maybe Double
> eval (Val v)     = Just v
> eval (Add e1 e2) = liftM2 (+) (eval e1) (eval e2)
> eval (Sub e1 e2) = liftM2 (-) (eval e1) (eval e2)
> eval (Mul e1 e2) = liftM2 (*) (eval e1) (eval e2)
> eval (Div e1 e2) = case eval e2 of
>   Just 0 -> Nothing
>   e      -> liftM2 (/) (eval e1) e

WE CONTINUE AT 20:10

