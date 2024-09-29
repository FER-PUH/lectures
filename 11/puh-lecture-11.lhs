University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2017/2018

LECTURE 11: Custom type classes and standard data types

v1.0

(c) 2017 Jan Šnajder

==============================================================================

> import Data.Char
> import Data.Functor
> import Data.Foldable
> import Prelude hiding (foldr,foldl,foldr1)
> import qualified Data.Set as S
> import qualified Data.Map as M
> import qualified Data.Tree as T

import GHC (compileExpr)
  === INTRO ====================================================================

Last week we looked into recursive data types, inclusive lists and trees. Today
we'll look into custom type classes, which is a way of defining interface of a
data type. Essentially, we use type classes when we want to capture similar
operations over different structures. (This is in contrast to polymorphism,
which captures the cases of similar structures over different values.) We'll
also look into built in type classes Functor and Foldable, which capture
generic computational patterns. Moreover, we'll look into built in data types,
such as Map and Set.

== CUSTOM TYPE CLASSES =======================================================

Recall the 'Person' data type:

> data Sex = Male | Female deriving (Show,Read,Eq,Ord)
> data Person = Person {
>   idNumber :: String,
>   forename :: String,
>   surname  :: String,
>   sex      :: Sex,
>   age      :: Int,
>   partner  :: Maybe Person,
>   children :: [Person] } deriving (Show,Read,Eq,Ord)

Up until now we've been defining our own data types, type constructors, and type
instances. What remains is to define our own type class. Let's do that.

> class Ageing a where
>   currentAge :: a -> Int
>   maxAge     :: a -> Int
>   makeOlder  :: a -> a

We can define 'Person' to be an instance of this type class:

> instance Ageing Person where
>   currentAge = age
>   makeOlder p = p {age = age p + 1}
>   maxAge    _ = 123

In our definition 'maxAge' does not depend on any value, in other words 'maxAge'
is identical for all values of type 'Person'.

Let's define another data type:

> data Breed = Beagle | Husky | Pekingese deriving (Eq,Ord,Show,Read)
> data Dog = Dog {
>   dogName  :: String,
>   dogBreed :: Breed,
>   dogAge   :: Int } deriving (Eq,Ord,Show,Read)

We can also make it an instance of our newly defined class:

> instance Ageing Dog where
>   currentAge  = dogAge
>   makeOlder d = d {dogAge = dogAge d + 1}
>   maxAge d    = case dogBreed d of 
>                   Husky -> 29
>                   _     -> 20

We can now define a function that is applicable to values of types of the
'Ageing' class (to all values that can age):

> veryOld :: Ageing a => a -> Bool
> veryOld x = 10 * currentAge x >= 8 * maxAge x

We can apply this to any value of a type from the 'Ageing' class.

> toto = Dog "Toto" Beagle 16
> ines = Person "2692" "Ines" "Seni" Female 16 Nothing []
> dado = Person "2692" "Dado" "Dadić" Male 105 Nothing []

> b1 = veryOld toto
> b2 = veryOld ines
> b3 = veryOld dado

== EXERCISE 1 ================================================================

1.1.
- Define a function
    compareRelativeAge :: (Ageing a, Ageing b) => a -> b -> Ordering 
  that compares the ages relative to the maximum age, so that, say, a 10-year
  old dog is considered older than a 20-year old human.

1.2.
- Define a class 'Nameable' with function
    name :: a -> String
  Define 'Person' and 'Dog' as instances of this class. For a person, return
  "<Name> <Surname>", while for a dog return "<Name> the Dog".

==============================================================================

Let's look at another example. We often use type classes to define an interface
to a data structure. For instance, we can define a type class for all types in
which one can insert and from which one can take out a value:

> class Pushable t where
>   push   :: a -> t a -> t a
>   peek   :: t a -> a
>   pop    :: t a -> t a

Notice that this class is defined for a type constructor 't', whose kind is 
'* -> *', and not for a type 't a', whose kind is kind '*'. What this means is
that instances of 'Pushable' class will have to be type constructors rather
than types.

For example, an instance for a list type constructor:

> instance Pushable [] where
>   push x xs   = x:xs
>   peek (x:_)  = x
>   peek []     = error "Empty list"
>   pop (_:xs)  = xs
>   pop []      = error "Empty list"

REMARK: A type constructor for a list is '[]' and its kind is '* -> *'. This
means that a list of, say, integers has a type '[] Int', strings have a type
'[] Char', a polymorphic list has a type '[] a', etc. The notation '[Int]',
'[Char]', and '[a]' is just syntactic sugar. Notation '[] a' is actually the
main one and also consistent with the notation for other type constructors.

Our list 'MyList' can also be made a member of the 'Pushable' class:

> data MyList a = Empty | Cons a (MyList a) deriving (Show,Read,Eq,Ord)

> instance Pushable MyList where
>   push x xs          = x `Cons` xs
>   peek (x `Cons` _)  = x
>   peek Empty         = error "Empty MyList"
>   pop  (_ `Cons` xs) = xs
>   pop Empty          = error "Empty MyList"

The same holds for our binary tree:

> data Tree a = Null | Node a (Tree a) (Tree a) deriving (Show,Eq)

> instance Pushable Tree where
>   push x t          = Node x t Null
>   peek (Node x _ _) = x
>   peek Null         = error "Empty Tree"
>   pop  (Node _ t _) = t
>   pop  Null         = error "Empty Tree"

== EXERCISE 2 ================================================================

2.1.
- Define a 'Takeable' class with a function
    takeSome :: Int -> t a -> [a]
- Define '[]' and 'Tree' as instances of 'Takeable'. Take elements from the
  tree using in-order traversal.

2.2.
- Define a 'Headed' class with functions
    headOf  :: t a -> a      -- takes the head of the structure
    headOff :: t a -> t a    -- removes the head and returns the rest
- Define '[]', 'Tree', and 'Maybe' as instances of this type class.
  (The head of 'Maybe' type is the value wrapped into 'Just', while the rest is
  'Nothing'.)

== FUNCTOR ===================================================================

Some operations on data structures are so common that it makes sense to define
special type classes for such operations.

For example, the 'map' operation. For a list we have:

  map :: (a -> b) -> [a] -> [b]
  map _ []     = []
  map f (x:xs) = f x : map f xs

We can define a 'map' function for a tree:

> treeMap :: (a -> b) -> Tree a -> Tree b
> treeMap _ Null         = Null
> treeMap f (Node x l r) = Node (f x) (treeMap f l) (treeMap f r)

And also for a 'Maybe' type:

> maybeMap :: (a -> b) -> Maybe a -> Maybe b
> maybeMap _ Nothing  = Nothing
> maybeMap f (Just x) = Just $ f x

This operation (generic map) is abstracted by the 'Functor' type class from
'Data.Functor' module:

  class Functor f where
    fmap :: (a -> b) -> f a -> f b
    (<$>) :: (a -> b) -> f a -> f b -- inline version of fmap

From the Data.Functor docs on Hackage (https://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Functor.html):
Functors: uniform action over a parameterized type, generalizing the map function on lists.

So, instances of this type class are types that can be mapped over. All types
that serve as data containers (and some that are not) can be mapped over. Function 'fmap' is a
generalization of 'map', which is defined only for lists.

  instance Functor [] where
    fmap = map

  instance Functor Maybe where
     fmap f (Just x) = Just $ f x
     fmap _ Nothing  = Nothing

> instance Functor Tree where
>   fmap _ Null         = Null
>   fmap f (Node x l r) = Node (f x) (fmap f l) (fmap f r)

REMARK: When we map over lists, it is all the same if we write 'fmap' or 'map',
but the latter is used more often.

This was interesting, but let's now look at some more fun instances of Functor:

QUIZ: Either a b

Oho, so now we have TWO type parameters instead of one! What do we do now?

SPOILER
instance Functor (Either a) where
    fmap _ (Left x) = Left x
    fmap f (Right y) = Right (f y)

QUIZ: How does tuple perform as functor?

SPOILER
The last element gets changes!

QUIZ: Function: (->) r s

Here is an example of non-data-container type that is an instance of Functor. Using what we learned from Either,
what can we do here?

SPOILER
instance Functor ((->) r) where
    fmap = (.)

There are also specific "laws" that must be satisfied by each Functor instance. The "issue" is they cannot be checked at compile
time, so it's your responsibility to make sure they are satisfied. in 90% of the cases you'll do it by default, but more on that later.

== EXERCISE 3 ================================================================

3.1.
- Using 'fmap' define 'mapOnTreeMaybe' that will apply 'f' to each element of
  a tree of the 'Tree (Maybe a)' type. For example:
    tr = Node (Just 1) (Node (Just 2) Null Null) (Node Nothing Null Null)
    mapOnTreeMaybe (+1) tr =>
    Node (Just 2) (Node (Just 3) Null Null) (Node Nothing Null Null)
  
3.2.
- Define a 'RoseTree' type for trees in which each node can have a number of
  subtrees (a forest). As data constructors, use 'RoseTree' and 'RoseEmpty'.
- Make this type an instance of the 'Functor' class.

== FOLDABLE ==================================================================

Another useful type class is 'Foldable'. This class is for types than can be
folded over. 

From the docs (https://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Foldable.html):
Class of data structures that can be folded to a summary value.

The definition of the class from 'Data.Foldable' (somewhat
simplified):

  class Foldable t where
    foldr  :: (a -> b -> b) -> b -> t a -> b
    foldl  :: (a -> b -> a) -> a -> t b -> a
    foldr1 :: (a -> a -> a) -> t a -> a
    foldl1 :: (a -> a -> a) -> t a -> a

The minimal complete definition is 'foldr'. We know how 'foldr' is defined for
a list:

  instance Foldable [] where
    foldr f z []     = z 
    foldr f z (x:xs) = f x (foldr f z xs) 

For our binary tree, a typical definition would be:

> instance Foldable Tree where
>   foldr f z Null         = z
>   foldr f z (Node x l r) = x `f` (foldr f (foldr f z r) l)

'foldr' must be defined in such a way that function 'f' takes as its first
argument the current element of the tree and as its second element the
accumulator. Care must be taken to traverse recursively all branches. To this
end, we need two recursive calls to 'foldr' (one for the left and one for the
right branch). Each of these two calls independently returns a new value for
the accumulator.

If we had a tree with three subtrees (a ternary tree):

> data Tree3 a = Null3 | Node3 a (Tree3 a) (Tree3 a) (Tree3 a) 
>   deriving (Show,Eq)

> instance Foldable Tree3 where
>   foldr f z Null3           = z
>   foldr f z (Node3 x l m r) = f x (foldr f (foldr f (foldr f z r) m) l)

(How would a 'foldr' for a rose tree look like? try to generalize from the
above case.)

Let's check if this works:

> intTree = Node 1 (Node 2 Null Null) (Node 3 Null Null)

> intTree3 = Node3 5 
>   (Node3 6 Null3 Null3 Null3) 
>   (Node3 7 Null3 Null3 Null3) 
>   (Node3 8 Null3 Null3 Null3)

> r1 = foldr (+) 0 intTree
> r2 = foldr (+) 0 intTree3

We can easily turn any 'Foldable' type into a list using 'foldr':

  toList :: Foldable t => t a -> [a]
  toList = foldr (:) []

QUIZ: How do we fold over Maybe?

SPOILER
instance Foldable Maybe where
    foldr _ z Nothing = z
    foldr f z (Just x) = f x z

Even better than that, we can apply any of the following functions from
'Data.Foldable' to any 'Foldable' type:

  concat :: Foldable t => t [a] -> [a]
  concatMap :: Foldable t => (a -> [b]) -> t a -> [b]
  and :: Foldable t => t Bool -> Bool
  or :: Foldable t => t Bool -> Bool
  any :: Foldable t => (a -> Bool) -> t a -> Bool
  all :: Foldable t => (a -> Bool) -> t a -> Bool
  sum :: (Foldable t, Num a) => t a -> a
  product :: (Foldable t, Num a) => t a -> a
  maximum :: (Foldable t, Ord a) => t a -> a
  maximumBy :: Foldable t => (a -> a -> Ordering) -> t a -> a
  minimum :: (Foldable t, Ord a) => t a -> a
  minimumBy :: Foldable t => (a -> a -> Ordering) -> t a -> a
  elem :: (Foldable t, Eq a) => a -> t a -> Bool
  notElem :: (Foldable t, Eq a) => a -> t a -> Bool
  find :: Foldable t => (a -> Bool) -> t a -> Maybe a

== EXERCISE 4 ================================================================

4.1.
- Using 'foldr' from 'Foldable' class define a function
    sumPositive :: (Foldable t, Num a, Ord a) => t a -> a
  that sums the positive elements in a structure of a 't a' type.

4.2.
- Using 'foldr' define a function 'size' that returns the size of any structure
  whose type is 'Foldable':
    size :: Foldable t => t a -> Int
    size intTree   => 3
    size [1,5..99] => 25
    size (Just 5)  => 1

4.3.
- Define a function 'eqElems' that tests whether all elements of a structure 
 't a' are equal to each other.
    eqElems :: (Foldable t, Eq a) => t a -> Bool

4.4.
- Define a 'Foldable' instance for 'RoseTree'.

=== STANDARD DATA TYPES ======================================================

In Haskell's Hierarchical Library, in the 'Data' module, you'll find a handful
of useful data types and functions that operate on them.

http://www.haskell.org/ghc/docs/latest/html/libraries/

=== Data.Set ===

  data Set a = ...

A data structure for sets (the order of elements is irrelevant and there are no
duplicate elements), implemented as a size balanced tree.

Main functions:

  empty :: Set a
  insert :: Ord a => a -> Set a -> Set a
  delete :: Ord a => a -> Set a -> Set a
  
  elems :: Set a -> [a]
  toList :: Set a -> [a]
  fromList :: Ord a => [a] -> Set a

  union :: Ord a => Set a -> Set a -> Set a
  difference :: Ord a => Set a -> Set a -> Set a
  intersection :: Ord a => Set a -> Set a -> Set a

  map :: (Ord a, Ord b) => (a -> b) -> Set a -> Set b
  filter :: Ord a => (a -> Bool) -> Set a -> Set a
  fold :: (a -> b -> b) -> b -> Set a -> b

  null :: Set a -> Bool
  size :: Set a -> Int
  member :: Ord a => a -> Set a -> Bool
  isSubsetOf :: Ord a => Set a -> Set a -> Bool

Note that most functions have an 'Ord a' class constraint, because this
structure is internally implemented as a tree and hence elements need to be
compared when inserting new elements or traversing the structure.

E.g.:

> s1 = S.fromList [2,1,1,2,5,6,5]
> s2 = S.insert 100 s1
> s3 = S.insert 1 s2
> s4 = s3 `S.difference` s1

Inserting an element from a list into a tree and then flattening the tree back
into a set is equivalent to 'sort . nub' but without the 'Eq a' constraint:

> xs = S.toList $ S.fromList [2,1,1,2,5,6,5]

If you work with sets of integers, use 'Data.IntSet' instead.

=== Data.Map ===

  data Map k a = ...

A dictionary data structure (stores key-value values), also implemented as a
balanced tree. The type variable 'k' is the key type, while 'a' is the type of
the value stored in the dictionary. For example, 'Map Int String' is a map of
strings with integer keys.

Main functions:

  lookup :: Ord k => k -> Map k a -> Maybe a
  insert :: Ord k => k -> a -> Map k a -> Map k a
  insertWith :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a
  delete :: Ord k => k -> Map k a -> Map k a
  adjust :: Ord k => (a -> a) -> k -> Map k a -> Map k a
  toList :: Map k a -> [(k, a)]
  fromList :: Ord k => [(k, a)] -> Map k a

'Data.Map' is already defined as an instance of 'Functor' and 'Foldable', so we
can map over it and fold it up.

Some usage examples:

> m1 = M.fromList [("342",ines),("231",dado)]
> Just p1 = M.lookup "231" m1
> m2 = M.fromList [(1,["haskell","python"]),(5,["java"]),(8,["c#","c++"])]
> m3 = M.insertWith (++) 9 ["ocaml"] m2
> m4 = M.insertWith (++) 5 ["scala"] m3
> m5 = M.map (map $ map toUpper) m4

If you work with integer keys, use 'Data.IntMap' instead.

== EXERCISE 5 ================================================================

5.1.
- Define a function for turning any 'Foldable' type into a 'Set' type:
    toSet :: (Foldable t, Ord a) => t a -> S.Set a

5.2.
- Define a function 'indexWords' that indexes the positions of words in a text
  and returns an index (a dictionary). The keys are the words, while the values
  are the list of indices (positions at which the word appears in text).
    indexWords :: String -> M.Map String [Int]
    indexWords "to be or not to be" => 
    fromList [("be",[1,5]),("not",[3]),("or",[2]),("to",[0,4])]
  (Hint: use 'insertWith'.)

=== NEXT =====================================================================

In the next lecture we'll look into IO operations in Haskell, including file
streams and random number generators.

