University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2024/2025

LECTURE 10: Custom data types 2

v1.3

(c) 2017 Jan Šnajder
    2024 Luka Hadžiegrić

==============================================================================

> import Data.List hiding ( insert )

=== RECAP ======================================================================

=== Sum ------------------------------------------------------------------------

> data ABC = A | B | C
>
> a :: ABC
> a = A
>
> b :: ABC
> b = B
>
> c :: ABC
> c = C
>
> showABC :: ABC -> String
> showABC A = "A"
> showABC B = "B"
> showABC C = "C"

=== Product --------------------------------------------------------------------

> data User = User
>   { username :: String
>   , password :: String
>   }
>
> user1 :: User
> user1 = User "james" "double07"
>
> user2 :: User
> user2 = User
>   { username = "admin"
>   , password = "password123"
>   }
>
> authorized :: User -> Bool
> authorized u = password u == "double07"
>
> authorized' :: User -> Bool
> authorized' User{ username = uname } = uname == "double07"

=== Sum of Products ------------------------------------------------------------

> data Operation = Neg Int | Add Int Int | Mul Int Int
>
> add :: Int -> Int -> Operation
> add a b = Add a b
>
> add' :: Int -> Int -> Operation
> add' = Add
>
> perform :: Operation -> Int
> perform ( Neg n ) = negate n
> perform ( Add a b ) = a + b
> perform ( Mul a b ) = a * b

=== Parametrized ---------------------------------------------------------------

< data Maybe a = Nothing | Just a

> maybeFoo :: Maybe Int
> maybeFoo = Nothing
>
> maybeBar :: Maybe Double
> maybeBar = Just 6.39
>
> safeHead :: [ a ] -> Maybe a
> safeHead [] = Nothing
> safeHead (h:_) = Just h

< data Either e v = Left e | Right v

> eitherFoo :: Either String Double
> eitherFoo = Left "Foo Either"
>
> eitherFoo' :: Either String a
> eitherFoo' = Left "Foo Either"
>
> errBar :: Either String Integer
> errBar = Right 112358

=== The fmap -------------------------------------------------------------------

< fmap :: ( a -> b ) -> Maybe a -> Maybe b
< fmap _ Nothing = Nothing
< fmap f ( Just a ) = Just ( f a )

< fmap  :: ( a -> b ) -> ( Maybe a -> Maybe b )
< (<$>) :: ( a -> b ) -> ( Maybe a -> Maybe b )

> fmap1 = fmap (+1) (Just 3)
> fmap2 = fmap (+1) Nothing

> fmap3 = (1+)  $        3
> fmap4 = (1+) <$> (Just 3)

=== INTRO ======================================================================

We've gone over the 'data' keyword for introducing new algebraic data types,
records and polymorphic data types. Today we'll look into recursive data types
like lists and trees.

=== Recursive Types ============================================================

=== List -----------------------------------------------------------------------

A singly linked list is the simplest form of a tree. It only has one child branch on each node.

  a - a - a - a - x

Here's how we can define a custom list type along with some useful automatically
derived type classes like 'Eq', 'Ord', 'Show' and 'Read'.

> data List a = Null | Cons a ( List a )
>   deriving ( Eq , Ord , Show , Read )

Now we can define some lists:

> l0 = Cons 1 Null
> l1 = 1 `Cons` Null
> l2 = 1 `Cons` ( 2 `Cons` ( 3 `Cons` Null ) )

Using the data constructors as infix operators can be messy, so we can deifine a
helper operator to provide a nicer interface to our list data type.

> infixr 5 ×
> (×) = Cons

Here we've defined the fixity of ':+:' as 5, which is "medium" fixity. Levels
range from 0 to 9 where 0 binds least tightly while 9 binds most tightly. Fixity
levels decide which operator wins when they compete for the same value.

< 1 + 2 * 3 == 1 + ( 2 * 3 )

The '+' sign has fixity of 6 and '*' fixity of 7. You can find out more here:
https://www.haskell.org/onlinereport/decls.html#fixity

Anyway, we can now use our new '#' operator to construct lists, just like we
can do with the standard list type:

> l3 = 1 × 2 × 3 × Null

Which is quite similar to how we'd normall define a list using the `:`
constructor:

> l4 = 1 : 2 : 3 : []

What happens if we define a list recursively?

> l5 = 1 : 2 : l5

=== EXERCISE 1 -----------------------------------------------------------------

< data Maybe a = Nothing | Just a
<
< data List a = Null | Cons a ( List a )
<   deriving ( Eq , Ord , Show , Read )

1.1
- Define

< listHead :: List a -> Maybe a


1.2
- Define

< listFmap :: ( a -> b ) -> List a -> List b

=== Tree -----------------------------------------------------------------------

A list is just a special case of a tree. Next, let's look at the more complex
kind of tree. The binary tree.

                               ┌●
                             ┌×┤
                           ┌×┤ └●
                           │ └●
                          ×┤   ┌●
                           │ ┌×┤ ┌●
                           └×┤ └×┤
                             └●  └●

Let's define a binary tree type:

> data Tree a = Leaf | Node a ( Tree a ) ( Tree a )
>   deriving ( Show )

And here's a binary tree filled with some numbers:

> treeFoo :: Tree Int
> treeFoo = Node 1
>   ( Node 2
>     Leaf
>     ( Node 3
>       ( Node 4 Leaf Leaf )
>       Leaf
>     )
>   )
>   ( Node 5 Leaf ( Node 6 Leaf Leaf ) )

Which we can visualize like this:

                               ┌●
                             ┌6┤
                           ┌5┤ └●
                           │ └●
                          1┤   ┌●
                           │ ┌3┤ ┌●
                           └2┤ └4┤
                             └●  └●

=== EXERCISE 2 -----------------------------------------------------------------

2.1
- Define the empty tree.

< empty :: Tree a

> empty :: Tree a
> empty = Leaf

2.2
- Define a function for inserting elements into the binary search tree (BST).
  Values smaller than the root node should go to the left branch, and everything
  else to the right branch.

< insert :: Ord a => a -> Tree a -> Tree a

2.3
- Define a function which uses the inorder traversal (left, node, right) to
  convert a tree into a list.

< toList :: Tree a -> [ a ]

2.4
- Define a function that will sort a list by converting it to tree and back to
  list with the 'toList'.

< sortList :: [ a ] -> [ a ]

=== Knot -----------------------------------------------------------------------

What if we want to "tie the knot" so to speak? Create a cyclic graph of some
kind.

Earlier we've already seen how to do it with a list in the 'l5' example:

< l5 = 1 : 2 : l5

If we try to print that out, we get a cycle of 1s and 2s.

Let's examine a slightly more complex example. We'll define the following type:

> data Person = Person
>   { pid :: Int
>   , name :: String
>   , friends :: [ Person ]
>   } deriving ( Eq , Ord , Show , Read )

Now, let's define some people and their relationships with eachother:

> ana    = Person 0 "Ana"    [ mateja ]
> luka   = Person 1 "Luka"   [ marko , mateja ]
> marko  = Person 2 "Marko"  []
> matija = Person 3 "Matija" [ ana , luka ]
> mateja = Person 4 "Mateja" [ ana ]
> petar  = Person 5 "Petar"  []

Notice how we can reference constants before they were defined in the code. Due
to it's lazyness, Haskell can easily resolve those references later.

Here's the visualization of the relationship graph:

                          0 <--- 3     5
                          ↑      |
                          ↓      ↓
                          4 <--- 1 --> 2

What would happen if we try to evaluate the following expressions?:

> pex0 = show ana
> pex1 = ana == ana
> pex2 = ana == marko
> pex3 = marko > petar


=== Type Classes ===============================================================

Type classes are not related to classes in OOP. There, classes specify the
internal state of an object, while type classes specify interactions we can
have with a value of a certain type.

A type class is an INTERFACE describing what actions we can perform  over the
suported types. They enable us to have ad-hoc polymorphism. The difference
between that and the type variable polymorphism we've seen so far is that we can
have a completely different implementation for each type.

Here's the definition of the 'Eq' type class:

< class Eq a where
<   (==) , (/=) :: a -> a -> Bool
<
<   x /= y = not (x == y)
<   x == y = not (x /= y)

=== Deriving -------------------------------------------------------------------

Because of how the 'Eq', 'Ord' and 'Show' type classes are derived by the
compiler we may have some issues when using their interface in certain cases, as we've seen with the 'Person' type.

By default Haskell has the following "stock" derivable type classes:

  | Eq, Ord, Enum, Ix, Bounded, Read, and Show

Through some language extensions we can also derive the following:

  | Functor, Foldable, Traversable, Generic, Generic1, Lift, Data

As a side not, let's recall the 'Person' definition:

< data Person = Person
<   { pid :: Int
<   , name :: String
<   , friends :: [ Person ]
<   } deriving ( Eq , Ord , Show , Read )

If we use the 'show' on 'marko' we get the following string (notice the escaped
quotes):

< "Person {pid = 2, name = \"Marko\", friends = []}"

We can convert that 'String' back into a 'Person' by using the 'read' coming
from the 'Read' type class. However, one important thing to note here is that
the automatically derived 'Read' type class relies on the 'Show' instance to
output correctly formatted code.

We can implement any of those type class instances by hand, so it's important to
remember that some of them rely on certain features of another type class.

One useful stock derivable type class is 'Enum'. It allows us to use that nice
'[0..1]' syntax.

Let's define the 'Weekday' type:

> data Weekday =
>   Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday
>   deriving (Show,Enum)

Now we can define a list containing all twelve months:

> weekdays :: [ Weekday ]
> weekdays = [ Monday .. Friday ]

We also get the 'succ' and 'pred' functions that will give us a successor or
predecessor of a value:

> yesterday :: Weekday -> Weekday
> yesterday = pred

> dayAfterYesterday :: Weekday -> Weekday
> dayAfterYesterday = succ . pred

=== Instances ------------------------------------------------------------------

What if we don't want to derive a type class instances, but want to define our
own, custom type class instance?

Let's look at an example. We'd like to define a different kind of equality test
for our 'Person' data type. E.g., we'd like to consider two persons to be
identical if they have the same 'pid'. We can also define 'Ord'ering based on
the 'pid' value.

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

We can now define our own 'Eq' instance for the 'Person' type:

< instance Eq Person where
<   p1 == p2 = pid p1 == pid p2

Now 'ana == ana' will work.

Let's also define an instance for 'Ord' type class. The minimal complete
definition is (<=). So it suffices to define:

< instance Ord Person where
<   p1 <= p2 = idNumber p1 <= idNumber p2

=== EXERCISE 3 -----------------------------------------------------------------

5.1.
- Define an 'Eq' instance for the 'Weekday' type that describes a repetitive
  work week, in a sense that all the days are identical to every each other,
  except for Saturday and Sunday, those are unique and even two Saturdays or
  Sundays are not identical. So e.g. Monday == Tuesday should be True but Saturday == Saturday should be False.

5.2.
- Define 'Person' as an instance of 'Show' type class so that instead of the
  full values of 'friends' you only print out their names. Remove the derived
  'Show' instance from the 'Person' definition.

=== Parametrized types ---------------------------------------------------------

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

=== EXERCISE 4 -----------------------------------------------------------------

6.1.
- Define an instance of `Eq` for `List a` so that two lists are considered
  equal only if they have the same first element, or if they are both empty.

  < data List a = Null | Cons a ( List a )
  <   deriving ( Eq , Ord , Show , Read )

6.2.
- Define an instance of `Eq` for `Tree a` so that two trees are considered
  equal if they store the same values, regardless of the position of these
  values in the trees, and regardless of duplicates.

  < data Tree a = Leaf | Node a ( Tree a ) ( Tree a )
  <   deriving ( Show )

=== NEXT =====================================================================

In the next lecture we'll look into custom types classes as well as standard
data types, such as sets, maps, trees, and graphs.
