> module Lecture09 where
>
> import Data.Bool ( bool )

University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2026/2027

LECTURE 9: Custom data types 1

v2.0

================================================================================

So far, we've mostly focused on functions, recursions, higher-order functions
like 'map' and 'fold', how to compose them, as well as some built-in data types.
This time, we'll learn how to define our own custom data types.

=== TYPE =======================================================================

We've seen the 'type' keyword before. Unfortunately, this keyword only allows us
to define a type synonym, like this:

> type Name' = String
> type Surname' = String
> type FullName' = String

> exName' :: Name'
> exName' = "Peter"

> exSurname' :: Name'
> exSurname' = "Griffin"

> mkFullName' :: Name' -> Surname' -> FullName'
> mkFullName' name surname = name ++ " " ++ surname

This, sadly, doesn't allow the compiler to prevent us from misusing the
functions as all of the types are interchangeable with 'String':

ghci> mkFullName' exName exSurname
"Peter Griffin"

ghci> mkFullName' exSurname exName
"Griffin Peter"

Type synonyms have a purpose, but on their own, they don't guarantee type
safety.

=== SUM TYPES ==================================================================

Haskell has Algebraic Data Types, or ADTs for short. In the algebra of types,
our focus will be on the sum and product types. Let's see a familiar sum type:

   +- Keyword   +------+----- Values / inhabitants of the type
   |            |      |
< data Bool = False | True
        |
    Type name

In Haskell, 'Bool' is not a primitive type and can be defined manually with the
data keyword. On the left side of '=' we write the type name, while on the
right side we enumerate possible values of that type separated by '|'. Both the
type name and the value names must start with an uppercase letter.

Let's remember another sum type we've seen before:

< compare :: Ord a => a -> a -> Ordering

< data Ordering = LT | EQ | GT

The 'Bool' type is inhabited by 2 values, while 'Ordering' has 3.

Cardinality is the number of values that inhabit a type. Cardinalities of 'Bool'
and 'Ordering' are 2 and 3. We can look at cardinalities like this:

  card Bool = 1 + 1 = 2
  card Ordering = 1 + 1 + 1 = 3

It's clearer now why they're called sum types. We can use pattern matching to
handle each possible value of an ADT:

> yesno :: Bool -> String
> yesno False = "No!"
> yesno True  = "Yes!"

Let's define our first custom data type representing the red, green, and blue:

> data RGB = Red | Green | Blue

We can define a constant 'red' of the type 'RGB' that has a value of 'Red':

> colourRed :: RGB -- type level
> colourRed = Red  -- value level

Notice the distinction between the type, the value of the type, and the constant
we're storing the value under. It is important not to confuse them.

If we try to evaluate the 'colourRed' or just a plain value like 'Green' in the
GHCi, we'll get the following response:

ghci> colourRed

<interactive>:14:1: error: [GHC-39999]
    • No instance for ‘Show RGB’ arising from a use of ‘print’
    • In a stmt of an interactive GHCi command: print it

GHCi is saying there's no 'Show' type class instance for 'RGB'. As we don't yet
know how to write one, we can let the compiler do this for our next data type:

> data UDT = Uno | Dos | Tres
>   deriving ( Eq , Ord , Show , Read )

The 'deriving' tells the compiler which type classes to write for us. By
By default, we can only derive Eq, Ord, Enum, Bounded, Read, Show, and Ix.

Besides 'Show', we've also derived a few other type classes for 'UDT'. With 'Eq'
we can test 'UDT' values for equality:

ghci> Uno == Uno
True
ghci> Dos == Tres
False

While we can't do the same for the 'RGB' values without the 'Eq' instance:

ghci> Red == Red

<interactive>:17:5: error: [GHC-39999]
    • No instance for ‘Eq RGB’ arising from a use of ‘==’
    • In the expression: Red == Red
      In an equation for ‘it’: it = Red == Red

=== EXERCISE 1 =================================================================

1.1.
- Define a custom sum type 'UpTo5' that represents numbers from 1 to 5. Since
  numerical symbols are already "taken", you can prefix the number with a letter
  'N'. For example, 'N2'. Derive 'Eq', 'Ord', and 'Show' and test inequalities.

> data UpTo5 = N1 | N2 | N3 | N4 | N5
>   deriving ( Eq , Ord , Show )

1.2.
- Since we don't have the 'Show' instance for our 'RGB' type, manually write the
  'showRGB' function that will convert the 'RGB' value into a 'String'.

> showRGB :: RGB -> String
> showRGB Red = "Red"
> showRGB Green = "Green"
> showRGB Blue = "Blue"

1.3.
- Write 'eqRGB' function that tests if two values of the 'RGB' type are the
  same.

> eqRGB :: RGB -> RGB -> Bool
> eqRGB Red   Red   = True
> eqRGB Green Green = True
> eqRGB Blue  Blue  = True
> eqRGB _     _     = False

=== ELIMINATORS ================================================================

Pattern matching is a nice way to break down how our function should behave
based on possible inputs it may receive, however, it can be verbose, especially
when we want to use higher-order functions, such as 'map'. Consider this:

> lessThan5 :: [ Int ] -> [ String ]
> lessThan5 = map ( \ b -> case b of False -> "no"; True -> "yes" ) . map (<5)

Instead of pattern matching with 'case', we could've used a previously defined
'yesno' function like this:

> lessThan5' :: [ Int ] -> [ String ]
> lessThan5' = map yesno . map (<5)

This is very limited. What if we changed our mind and we want to return numbers
'1' and '0' instead of "yes" and "no"? Luckily, for every data type, we can
define an "eliminator". A function that gives us the same power as pattern
matching, and is very practical for code reuse and function composition:

< bool :: a -> a -> Bool -> a
< bool f _ False = f
< bool _ t True  = t

It takes two arguments 'f' and 't' of type 'a', and based on the third argument
returns 'f' if it's 'False' or 't' if it's 'True'. This eliminator can be found
in the 'Data.Bool' module. With it, we can have much nicer-looking expressions:

> lessThan5'' :: [ Int ] -> [ String ]
> lessThan5'' = map ( bool "no" "yes" ) . map (<5)

> lessThan5''' :: [ Int ] -> [ Int ]
> lessThan5''' = map ( bool 0 1 ) . map (<5)

=== EXERCISE 2 =================================================================

< data RGB = Red | Green | Blue

2.1.
- Define an eliminator for the 'RGB' type that allows you to return 3 values of
  type 'a' based on the value of type 'RGB'.

> rgb :: a -> a -> a -> RGB -> a
> rgb r _ _ Red = r
> rgb _ g _ Green = g
> rgb _ _ b Blue = b

2.2.
- Define 'showRGB'', without pattern matching, only using the 'rgb' eliminator.

> showRGB' :: RGB -> String
> showRGB' = rgb "Red" "Green" "Blue"

=== PRODUCT TYPES ==============================================================

Sum types may look like enums for now. Before we dig deeper, let's explore the
product types. You can think of them as containers for values of other types.

         Value constructor
                 |

> data Coord = Coord Int Int

         |            |   |
     Type name        +---+----- Types of value constructor fields.

>   deriving ( Eq , Show )

The 'Coord' data type represents a pair of discrete coordinates for the game of
sinking ships.

By convention, we use the same name for the type and the value constructor when
there's only one value constructor, which may be confusing at first.

If we look at the type of 'Coord' value constructor in GHCi, we'll see the
following:

ghci> :t Coord
Coord :: Int -> Int -> Coord

The 'Coord' constructor is a function that wraps two 'Int's into a "tagged" data
structure of type 'Coord' so we know their pairing represents some coordinates.

We can now construct a list of 'Coord'inates that represents the positions of
the ships in the game of sinking ships:

> ships :: [ Coord ]
> ships = [ Coord 1 3 , Coord 5 5 , Coord (-1) 2 , Coord 11 (-3) ]

The reason 'Coord' is a product type is that the number of unique values that
we can construct corresponds to the product of two 'Int' cardinalities. In
other words:

  card Coord = card Int * card Int = 2^64 * 2^64 = 2^128

To do something useful, we can use pattern matching to open the value
constructor and extract the individual coordinates.

> isOnMainDiagonal :: Coord -> Bool
> isOnMainDiagonal ( Coord x y ) = x == y

This function deconstructs the 'Coord' value on the left side, assigns the 'x'
and 'y' label to the first and the second field of the constructor, and then it
checks if the 'x' and 'y' are equal.

We can define some getters to extract individual components of a coordinate:

> getCX :: Coord -> Int
> getCX ( Coord x _ ) = x

> getCY :: Coord -> Int
> getCY ( Coord _ y ) = y

As well as some setters that will help us "modify" the data inside the 'Coord':

> setCX :: Int -> Coord -> Coord
> setCX newX ( Coord oldX oldY ) = Coord newX oldY

> setCY :: Int -> Coord -> Coord
> setCY newY ( Coord oldX oldY ) = Coord oldX newY

Remember that data structures in Haskell are generally immutable. In order to
"modify" a field, we basically have to create a new data structure and copy the
fields we do not intend to modify, while we replace the field we want to modify
with a new value.

=== EXERCISE 3 =================================================================

- 3.1.
  Define your own data type 'Vec2D' with two 'Int' fields. Essentially the same
  thing as 'Coord' but a different name.

> data Vec2D = Vec2D Int Int
>   deriving ( Eq , Show )

- 3.2.
  Define a function 'moveShips' that takes in a 'Vec2D' and a list of ship
  'Coord's and returns a new list with all ships moved by the 'Vec2D' amount.

  NOTE: You can use pattern matching in lambdas.

> moveShips :: Vec2D -> [ Coord ] -> [ Coord ]
> moveShips ( Vec2D vx vy )
>   = map ( \ ( Coord cx cy ) -> Coord ( cx + vx ) ( cy + vy ) )

- 3.3.
  Write a function 'shipHit' that checks if any ship on a target 'Coord' has
  been hit.

> shipHit :: Coord -> [ Coord ] -> Bool
> shipHit tgt = any (==tgt)

=== RECORDS ====================================================================

For any more complex product data type, writing getters and setters, as well as
relaying on the positions of the fields in the constructor can be annoying. We
can use the record syntax to make our product types more self-documenting:

> data Name = Name
>   { firstName   :: String
>   , familyName  :: String
>   } deriving ( Eq , Show )

With this, we can explicitly state which field we want to assign the value to
without relying on the position of the arguments in the constructor:

> name1 :: Name
> name1 = Name { familyName = "Griffin" , firstName = "Peter" }

We can still rely on the position of the fields to construct a new name:

> name2 :: Name
> name2 = Name "Peter" "Parker"

Besides that, while using the record syntax, we also get getter functions for
free. They have the same name as our record fields:

< firstName   :: Name -> String
< familyName  :: Name -> String

To get the first name from a 'Name' value, we can do this:

> fname1 :: String
> fname1 = firstName name1

To "modify" a field inside of the e.g., 'name1' and change the first name to
e.g. "Mark", while keeping the last name intact, we can use this syntax:

> name3 :: Name
> name3 = name1 { firstName = "Mark" }

Since we can't really directly "mutate" the state in Haskell, we are essentially
constructing a new name here that's based on the old one, while the old one
stays intact.

We can also nest records like this:

> data Person = Person
>   { name :: Name
>   , oib  :: String
>   } deriving ( Eq , Show )

> person1 :: Person
> person1 = Person { name = Name "John" "Doe" , oib = "12345678901" }

To retrieve the nested piece of data, like a person's first name, we can use
function composition or application operator, depending on what we're doing:

> getPersonFstName :: Person -> String
> getPersonFstName = firstName . name

> getPersonFamName :: Person -> String
> getPersonFamName p = familyName $ name $ p

We can also use pattern matching and deconstruction to extract the data from a
value:

> getPersonFullName :: Person -> String
> getPersonFullName Person{ name = ( Name fn ln ) } = fn ++ " " ++ ln

Notice how we need to put parentheses around the 'Name' constructor when we use
the "positional" syntax, while we don't need parentheses around the 'Person'
constructor when we use the "record" syntax.

=== EXERCISE 4 =================================================================

> data Ship = Ship
>   { shipName      :: String
>   , shipCoord     :: Coord
>   , shipPersonel  :: [ Person ]
>   } deriving ( Eq , Show )

> ship :: Ship
> ship = Ship "Titanic" ( Coord 6 7 )
>   [ person1
>   , Person name1 "237817"
>   , Person name2 "7309284"
>   , Person name3 "0128844"
>   ]

- 4.1.
  Get the first name of each person on a ship.

> getFirstNames :: Ship -> [ String ]
> getFirstNames = map ( firstName . name ) . shipPersonel

- 4.2.
  Change the first name of each person on a ship to "XXX".

> xxxFirstNames :: Ship -> Ship
> xxxFirstNames s = s
>   { shipPersonel
>     = map ( \ p -> p { name = ( name p ) { firstName = "XXX" } } )
>     ( shipPersonel s )
>   }

=== SUM OF PRODUCTS ============================================================

The full power of sum and product types comes from using them together:

> data Shape
>   = Circle { radius :: Double , posX :: Double , posY :: Double }
>   | Square { size :: Double , posX :: Double , posY :: Double }
>   deriving ( Eq , Show )

Here we've defined a type with two value constructors, 'Circle' and 'Square'.
This allows us to have a "mixed" list of 'Shape's:

> shapes :: [ Shape ]
> shapes = [ Circle 2 11 9 , Square 4 7 9 , Circle 1 0 0 , Square 2 1 1 ]

We can use pattern matching to check if a 'Shape' value is a 'Circle':

> isCircle :: Shape -> Bool
> isCircle ( Circle _ _ _ ) = True
> isCircle _ = False

And now we can get a list containing only 'Circle's:

> circles :: [ Shape ]
> circles = filter isCircle shapes

If we want to calculate the area of a shape, we can again use pattern matching
to select the appropriate formula for our specific shape:

> area :: Shape -> Double
> area ( Circle r _ _ ) = r ^ 2 * pi
> area ( Square s _ _ ) = s ^ 2

We can now calculate the total area of all shapes in a list of shapes:

> totalArea :: [ Shape ] -> Double
> totalArea = sum . map area

One issue with using field names in sums of products is that we might end up
with non-total functions. On top of that, fields with the same name in different
type constructors need to be of the same type; otherwise, Haskell will complain.

What would happen if we tried to run this code?:

< radius ( Square 1 2 3 )

=== PARAMETRIZED TYPES =========================================================

We've already seen lists and tuples, which are parametrized types. We can define
our own tuple like so:

> data Pair a b = PairConstructor a b
>   deriving ( Eq , Show )

Type parameters essentially allow us to make data structure "templates". You can
think of the 'Pair' as the type constructor and not a real / concrete type. It
only becomes a real type once we apply some arguments to it.

  Pair          -- Not a real type, but a type constructor
  Pair Int      -- Still not a real type, it's missing an argument
  Pair Int Bool -- A real concrete type
  Pair a b      -- Also a real type because we've applied type variables to it

To construct a value of type 'Pair RGB Bool', we can do the following:

> pair1 :: Pair RGB Bool
> pair1 = PairConstructor Red False

How many unique values of type 'Pair RGB Bool' can we construct?

=== MAYBE ======================================================================

'Maybe' is a parametrized data type that represents a possibly missing value.

< data Maybe a = Nothing | Just a

A value of type 'Maybe Int' will either be 'Nothing' or contain 'Just' some
'Int' value, e.g.:

> mInt1 :: Maybe Int
> mInt1 = Nothing

> mInt2 :: Maybe Int
> mInt2 = Just 53

We've seen that the 'head' function may throw an error on an empty list:

< head :: [ a ] -> a
< head [] = error "Empty list"
< head ( x : _ ) = x

The problem is that we don't know this without examining the implementation.
Ideally, we want to communicate such behaviour through types. By doing so, the
compiler can warn us of such edge cases if we forget to handle them.

> safeHead :: [ a ] -> Maybe a
> safeHead [] = Nothing
> safeHead ( x : _ ) = Just x

When we use the 'safeHead' function on a list, we'll be forced to explicitly
handle the possibility of an empty list if we want to add 1 to the head element:

> headPlus1 :: Num a => [ a ] -> a
> headPlus1 lst = case safeHead lst of
>   Nothing -> 0        -- if the list is empty and has no head, we return 0
>   Just el -> el + 1   -- otherwise we add 1 to it and return that value

As you can see, we can use pattern matching and deconstruction in the 'case'
expression.

As 'Maybe' is a frequently used data type, we also have an eliminator for it:

< maybe :: b -> ( a -> b ) -> Maybe a -> b
< maybe n _ Nothing = n
< maybe _ j ( Just a ) = j a

We could've implemented 'headPlus1' with it as well:

> headPlus1' :: Num a => [ a ] -> a
> headPlus1' = maybe 0 (+1) . safeHead

You can find other useful functions for working with 'Maybe' in the 'Data.Maybe'
module.

=== EITHER =====================================================================

'Either' represents possibility between values of two different (or same) types.

< data Either a b = Left a | Right b

The 'Left' value constructor represents the case where we have a value of type
'a', while the 'Right' value constructor represents the value of type 'b'.

We often use 'Either' to provide a more informative failure message instead of
just e.g. 'Nothing'. It is a convention to return the error message in the
'Left' constructor and the expected value in the 'Right' constructor.

Just like 'Maybe', 'Either' has an eliminator for its values:

< either :: ( a -> c ) -> ( b -> c ) -> Either a b -> c
< either fac _ ( Left a ) = fac a
< either _ fbc ( Right b ) = fbc b

=== EXERCISE 5 =================================================================

- 5.1.
  Define 'errorHead' that either returns an error message "Empty list" in case
  the list is empty, or it returns the first value of the list.

  NOTE: Do not use the 'error' function for this. Use the 'Either' data type.

> errorHead :: [ a ] -> Either String a
> errorHead [] = Left "Empty list"
> errorHead (x:_) = Right x

- 5.2.
  Implement a function that will return the total monthly salaries from a list of
  workers that may or may not be volunteers (they do not have a salary).

  NOTE: Try using the 'maybe' eliminator and the 'id' function.

> data Worker = Worker
>   { workerName :: Name
>   , workerMonthlySalary :: Maybe Float
>   } deriving ( Eq , Show )

> workers :: [ Worker ]
> workers =
>   [ Worker name1 Nothing
>   , Worker name2 ( Just 10 )
>   , Worker name3 ( Just 15 )
>   ]

> totalMonthlySalary :: [ Worker ] -> Float
> totalMonthlySalary = sum . map ( maybe 0 id . workerMonthlySalary )

=== ALGEBRAIC DATA TYPES =======================================================

One important insight from ADTs is that any two types with the same cardinality
are isomorphic / equivalent if we can write 'f : a -> b' and 'g : b -> a'
where 'g . f = id' and 'f . g = id'.

As it turns out, this means we can express any custom data type as a composition
of '()', 'Either a b', and '( a , b )'. These three types are considered the
canonical Unit, Sum, and Product types.

Being able to express any data type in this canonical form is the basis of the
automatic derivation mechanism in Haskell, as well as the 'Generic' type class
which enables us to use powerful generic programming techniques in Haskell.

=== NEXT =======================================================================

In the next lesson, we'll explore recursive data types, as well as a useful
pattern called 'fmap' that will make it easy to apply our ordinary functions to
values inside the parametrized data types.
