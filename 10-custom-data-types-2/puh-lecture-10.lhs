University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2025/2026

LECTURE 10: Custom data types 2

v1.0

(c) 2025 Mihovil Ilakovac

==============================================================================

> import Data.List

=== INTRODUCTION ==============================================================

Today we are going to finish our overview of custom data types in Haskell by
looking into recursive data types, type classes and instances.

=== RECAP =====================================================================

== Sum type

> data Operation = Add Int Int | Mult Int Int | Negate Int

          ^         ^             ^                ^
          |         |-------------|----------------|
  type constructor                |
                                  |
                          data constructor

> makeAddition :: Int -> Int -> Operation
> makeAddition a b = Add a b

> exec :: Operation -> Int
> exec (Add x y) = x + y
> exec (Mult x y) = x * y
> exec (Negate x) = (-1) * x

== Product type aka record

> data Animal = Animal
>   { numLegs :: Int, -- numLegs is a "field"
>     doesItMoo :: Bool
>   } deriving (Show)

  == Fields as setters

> dog = Animal {numLegs = 4, doesItMoo = False}
>
> cow = dog {doesItMoo = True}

  == Fields as getters

  numLegs :: Animal -> Int
  doesItMoo :: Animal -> Bool

> isBiped :: Animal -> Bool
> isBiped animal = numLegs animal == 2

> isBiped' :: Animal -> Bool
> isBiped' Animal {numLegs = legs} = legs == 2

== Parametrized types

> data ListWithLength a = ListWithLength Int [a]
>
> addLength :: [a] -> ListWithLength a
> addLength xs = ListWithLength (length xs) xs
>
> getLength :: ListWithLength a -> Int
> getLength (ListWithLength len _) = len
>
> getList :: ListWithLength a -> [a]
> getList (ListWithLength _ xs) = xs

== data Maybe a = Nothing | Just a

> chicken = Animal {numLegs = 2, doesItMoo = False}

> findFirstBiped :: [Animal] -> Maybe Animal
> findFirstBiped [] = Nothing
> findFirstBiped (x : xs)
>   | numLegs x == 2 = Just x
>   | otherwise = findFirstBiped xs

== data Either e a = Left e | Right a

> findFirstBiped' :: [Animal] -> Either String Animal
> findFirstBiped' [] = Left "no biped found"
> findFirstBiped' (x : xs)
>   | numLegs x == 2 = Right x
>   | otherwise = findFirstBiped' xs

=== EXERCISE 1 ==================================================================

Consider the following data types representing a music streaming service:

> data Album = Album
>   { albumTitle :: String,
>     releaseYear :: Int,
>     trackCount :: Int
>   }
>   deriving (Eq, Show)
>
> type Seconds = Int
>
> data Song = Song
>   { songTitle :: String,
>     duration :: Seconds,
>     album :: Maybe Album -- singles don't have an album
>   }
>   deriving (Eq, Show)

Some example songs:

> song1 = Song {songTitle = "Bohemian Rhapsody", duration = 354, album = Just $ Album {albumTitle = "A Night at the Opera", releaseYear = 1975, trackCount = 12}}
>
> song2 = Song {songTitle = "Imagine", duration = 183, album = Just $ Album {albumTitle = "Imagine", releaseYear = 1971, trackCount = 10}}
>
> song3 = Song {songTitle = "Blinding Lights", duration = 200, album = Nothing} -- a single without an album

1.1
- Define a function that returns the album title of a song, if the song is part of
  an album.

< getAlbumTitle :: Song -> Maybe String

1.2
- Define a function that returns the release year of a song's album, if the song
  is part of an album.

< getReleaseYear :: Song -> Maybe Int

=== FMAP =====================================================================

Notice how in the exercises above we keep having to unwrap the Maybe album,
extract a field and do something with it.

If we wanted to get the track count of the album of a song, we'd have to do:

> getTrackCount :: Song -> Maybe Int
> getTrackCount s = case album s of
>   Just a -> Just $ trackCount a
>   Nothing -> Nothing

There's a recurring pattern in the above functions: we want to apply some
function 'f' to a datum wrapped with 'Just' and return 'Just (f x)' or
'Nothing', if there's no datum. If there is a datum, we need to unwrap it,
apply a function, and then wrap it up again into 'Just'. There is a function
that does exactly this:

  fmap :: (a -> b) -> Maybe a -> Maybe b
  fmap f (Just x) = Just $ f x
  fmap _ Nothing  = Nothing

(Actually, 'fmap' is not really defined like this, rather a bit more generic,
but more on this later.)

We now can define:

> songAlbumTitle2 :: Song -> Maybe String
> songAlbumTitle2 s = fmap albumTitle $ album s

> songReleaseYear2 :: Song -> Maybe Int
> songReleaseYear2 s = fmap releaseYear $ album s


=== RECURSIVE DATA STRUCTURES  ===============================================

We've gone over the 'data' keyword for introducing new algebraic data types,
records and polymorphic data types. We'll look into defining recursive data types
next.

== List

A singly linked list is the simplest form of a tree. It only has one child branch on each node.

  a - a - a - a - x

Here's how we can define a custom list type along with some useful automatically
derived type classes like 'Eq', 'Ord', 'Show' and 'Read'.

> data List a = Empty | Cons a (List a)
>   deriving (Eq, Ord, Show, Read)

Now we can define some lists:

> l0 = Cons 1 Empty
>
> l1 = 1 `Cons` Empty
>
> l2 = 1 `Cons` (2 `Cons` (3 `Cons` Empty))

Using the data constructors as infix operators can be messy, so we can define a
helper operator to provide a nicer interface to our list data type.

> infixr 5 ×
>
> (×) = Cons

Here we've defined the fixity of '×' as 5, which is "medium" fixity. Levels
range from 0 to 9 where 0 binds least tightly while 9 binds most tightly. Fixity
levels decide which operator wins when they compete for the same value.

< 1 + 2 * 3 == 1 + ( 2 * 3 )

The '+' sign has fixity of 6 and '*' fixity of 7. You can find out more here:
https://www.haskell.org/onlinereport/decls.html#fixity

Anyway, we can now use our new '×' operator to construct lists, just like we
can do with the standard list type:

> l3 = 1 × 2 × 3 × Empty

Which is quite similar to how we'd normally define a list using the `:`
constructor:

> l4 = 1 : 2 : 3 : []

What happens if we define a list recursively?

> l5 = 1 : 2 : l5

=== EXERCISE 2 =================================================================

< data Maybe a = Nothing | Just a
<
< data List a = Empty | Cons a ( List a )
<   deriving ( Eq , Ord , Show , Read )

2.1
- Define

< listHead :: List a -> Maybe a


2.2
- Define

< listFmap :: ( a -> b ) -> List a -> List b

== Tree

A prototypical example of a recursive data structure is a tree.

How many of you have worked with trees?

Binary tree:

                      __a__
                     /     \
                    a       a
                   / \     / \
                  ●   ●   a   ●
                         / \
                        ●   ●

Here's a binary tree that stores the values in its inner nodes:

> data Tree a = Null | Node a (Tree a) (Tree a)
>   deriving (Show, Eq)

E.g., a binary tree of integers:

> intTree :: Tree Int
> intTree = Node 1 (Node 2 Null Null) (Node 3 Null Null)

                      __1__
                     /     \
                    2       3
                   / \     / \
                  ●   ●   ●   ●

A function that sums the elements in a binary tree of integers:

> sumTree :: Tree Int -> Int
> sumTree Null                = 0
> sumTree (Node x left right) = x + sumTree left + sumTree right

A function that tests whether an element is contained in a tree:

> treeElem :: Eq a => a -> Tree a -> Bool
> treeElem _ Null = False
> treeElem x (Node y left right)
>   | x == y    = True
>   | otherwise = treeElem x left || treeElem x right


=== EXERCISE 3 ===============================================================

Reminder:
  data Tree a = Null | Node a (Tree a) (Tree a)
    deriving (Show, Eq)

3.1.
- Define a function
  treeMax :: Ord a => Tree a -> Maybe a
  that finds the maximum element in a tree. Return Nothing if the tree is
  empty.

3.2.
- Define a function
  treeToList :: Tree a -> [a]
  that will collect in a list all elements of a tree by doing
  an in-order (left-root-right) traversal.

3.3.
- Define a function to prune the tree at a given level (root has level 0).
  That means that all the nodes that are beyond that level should be dropped.
  levelCut :: Int -> Tree a -> Tree a

==============================================================================


A sorted tree (binary search tree): for each node containing value 'x', the
left subtree contains values that are less than 'x', while the right subtree
contains values that are greater than 'x'. There are no duplicates.

Insertion into a binary search tree:

> treeInsert :: Ord a => a -> Tree a -> Tree a
> treeInsert x Null = Node x Null Null
> treeInsert x tree@(Node y ltree rtree)
>   | x < y     = Node y (treeInsert x ltree) rtree
>   | x > y     = Node y ltree (treeInsert x rtree)
>   | otherwise = tree


=== EXERCISE 4 ===============================================================

 These are really short, so just 5 minutes.

4.1.
- Define a function that converts a list into a sorted tree. Use treeInsert from above.
  listToTree :: Ord a => [a] -> Tree a

4.2.
- Using 'listToTree' and 'treeToList' defined previously, define:
  sortAndNub :: Ord a => [a] -> [a]
  that sorts a list and removes duplicates.

== Knot

What if we want to "tie the knot" so to speak? Create a cyclic graph of some
kind.

Earlier we've already seen how to do it with a list in the 'l5' example:

< l5 = 1 : 2 : l5

If we try to print that out, we get a cycle of 1s and 2s.

Let's examine a slightly more complex example. We'll define the following type:

> data Artist = Artist
>   { artistId :: Int,
>     artistName :: String,
>     collabs :: [Artist] -- artists they've collaborated with
>   }
>   deriving (Eq, Ord, Show, Read)

Now, let's define some artists and their collaboration relationships:

> queen = Artist {artistId = 0, artistName = "Queen", collabs = [bowie]}
>
> bowie = Artist {artistId = 1, artistName = "Bowie", collabs = [queen, mercury]}
>
> mercury = Artist {artistId = 2, artistName = "Mercury", collabs = []}
>
> mcCartney = Artist {artistId = 3, artistName = "McCartney", collabs = [lennon, jackson]}
>
> lennon = Artist {artistId = 4, artistName = "Lennon", collabs = [mcCartney]}
>
> jackson = Artist {artistId = 5, artistName = "Jackson", collabs = []}

Notice how we can reference constants before they were defined in the code. Due
to its laziness, Haskell can easily resolve those references later.

Here's the visualization of the collaboration graph:

                    queen <--> bowie --> mercury

                    jackson <-- mcCartney <--> lennon

What would happen if we try to evaluate the following expressions?:

> aex0 = show queen
>
> aex1 = queen == queen
>
> aex2 = queen == mercury
>
> aex3 = mercury > jackson


=== TYPE CLASSES ===============================================================

Type classes are not related to classes in OOP. There, classes specify the
internal state of an object, while type classes specify interactions we can
have with a value of a certain type.

A type class is an INTERFACE describing what actions we can perform  over the
supported types. They enable us to have ad-hoc polymorphism. The difference
between that and the type variable polymorphism we've seen so far is that we can
have a completely different implementation for each type.

Here's the definition of the 'Eq' type class:

< class Eq a where
<   (==) , (/=) :: a -> a -> Bool
<
<   x /= y = not (x == y)
<   x == y = not (x /= y)

== Deriving

Because of how the 'Eq', 'Ord' and 'Show' type classes are derived by the
compiler we may have some issues when using their interface in certain cases,
as we've seen with the 'Artist' type.

By default Haskell has the following "stock" derivable type classes:

  | Eq, Ord, Enum, Ix, Bounded, Read, and Show

As a side note, let's recall the 'Artist' definition:

< data Artist = Artist
<   { artistId :: Int
<   , artistName :: String
<   , collabs :: [ Artist ]
<   } deriving ( Eq , Ord , Show , Read )

If we use the 'show' on 'mercury' we get the following string (notice the escaped
quotes):

< "Artist {artistId = 2, artistName = \"Mercury\", collabs = []}"

We can convert that 'String' back into an 'Artist' by using the 'read' coming
from the 'Read' type class. However, one important thing to note here is that
the automatically derived 'Read' type class relies on the 'Show' instance to
output correctly formatted code.

We can implement any of those type class instances by hand, so it's important to
remember that some of them rely on certain features of another type class.

One useful stock derivable type class is 'Enum'. It allows us to use that nice
'[0..1]' syntax.

Let's define the 'Weekday' type:

> data Weekday
>   = Monday
>   | Tuesday
>   | Wednesday
>   | Thursday
>   | Friday
>   | Saturday
>   | Sunday
>   deriving (Show, Enum)

Now we can define a list containing all weekdays:

> weekdays :: [Weekday]
> weekdays = [Monday .. Friday]

We also get the 'succ' and 'pred' functions that will give us a successor or
predecessor of a value:

> yesterday :: Weekday -> Weekday
> yesterday = pred

> dayAfterYesterday :: Weekday -> Weekday
> dayAfterYesterday = succ . pred

== Instances

What if we don't want to derive a type class instances, but want to define our
own, custom type class instance?

Let's look at an example. We'd like to define a different kind of equality test
for our 'Artist' data type. E.g., we'd like to consider two artists to be
identical if they have the same 'artistId'. We can also define 'Ord'ering based on
the 'artistId' value.

Before we look at how to define an instance of `Eq` type class,
let's first look at how actual `Eq` type class is defined. You can get this
information by typing ':i ClassName' in the repl.

        |- type class name
        |
        |  |- type variable
        v  v
  class Eq a where
    (==) :: a -> a -> Bool
    (/=) :: a -> a -> Bool

    x == y = not (x /= y)
    x /= y = not (x == y)

There's the name of the type class, a type variable, and a list of functions
that must be defined for this type, in this case functions (==) and (/=). The
definitions themselves are not given here, only the type signatures.

This can be read as: for some type `a` to implement typeclass `Eq`, it needs to
implement following methods: (==), (/=).

We then can have default definitions of functions, like it is
done in this case.

Having default definitions means that, when defining and instance, one will not
have to define all functions but can rely on default definitions. For example,
in this case it suffices to define (==), because there's a default definition
for (/=) that uses (==). So, for each type we only have to define those
functions that have no default definitions. This is called a MINIMAL COMPLETE
DEFINITION.

In case of 'Eq', the minimal complete definition is either the (==) function or
the (/=) function.

Let's look now at how we can define that a type is an instance of the 'Eq' type
class:

          |- type class name
          |
          |  |- instance type
          v  v
instance Eq Weekday where
  Monday    == Monday    = True
  Tuesday   == Tuesday   = True
  Wednesday == Wednesday = True
  Thursday  == Thursday  = True
  Friday    == Friday    = True
  Saturday  == Saturday  = True
  Sunday    == Sunday    = True
  _         == _         = False

We can now define our own 'Eq' instance for the 'Artist' type:

< instance Eq Artist where
<   a1 == a2 = artistId a1 == artistId a2

Now 'queen == queen' will work.

Let's also define an instance for 'Ord' type class. The minimal complete
definition is (<=). So it suffices to define:

< instance Ord Artist where
<   a1 <= a2 = artistId a1 <= artistId a2

=== EXERCISE 5 =================================================================

5.1.
- Define 'Artist' as an instance of 'Show' type class so that instead of the
  full values of 'collabs' you only print out their names. Remove the derived
  'Show' instance from the 'Artist' definition.

== Parametrized Types

What if we want to define an instance of a parametrized type?

That's not a problem. We simply have to provide a type variable together with
the type constructor. E.g.:

              |- Constraint(s)
              |
              |     |- type class
              |     |
              |     |     |- instance type
            __|__   |  ___|___
           /     \  v /       \
  instance Eq a => Eq (Maybe a)
    Just x  == Just y   = x == y
    Nothing == Nothing  = True
    _       == _        = False

A DIGRESSION: Why can't we simply write 'Maybe'? Because 'Eq' type class
expects a type, whereas 'Maybe' is not a type but a type constructor. In other
words, a type constructor 'Maybe' will produce a type only when given a type as
input.  E.g., 'Maybe Int' is a type. Similarly, 'Either' expects two types,
before it produces a type. So these type constructors themselves are of
different "types". We're talking about "types of types" here, which we call
KINDS in Haskell. 'Int', 'Maybe', and 'Either' are type constructors of
different kind. You can find out their kind using the ":kind" command in
ghci:

  Int :: *
  Maybe :: * -> *
  Either :: * -> * -> *

Kind '*' is just an ordinary type.
Kind '* -> *' is a unary type constructor, that takes in an ordinary type and
returns an ordinary type.

=== EXERCISE 6 =================================================================

6.1.
- Define an instance of `Eq` for `List a` so that two lists are considered
  equal only if they have the same first element, or if they are both empty.

  < data List a = Empty | Cons a ( List a )
  <   deriving ( Eq , Ord , Show , Read )


=== NEXT =====================================================================

In the next lecture we'll look into custom types classes as well as standard
data types, such as sets, maps, trees, and graphs.

Good luck with the exams!