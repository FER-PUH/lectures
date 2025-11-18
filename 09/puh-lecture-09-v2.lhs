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

So far we've mostly focused on functions, recursions, higher order functions
like 'map' and 'fold', how to compose them as well as some built-in data types.
This time, we'll learn how to define our own data types.

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

While this does convey the intent behind each argument, it doesn't prevent us
from making mistakes, as all of the types are interchangeable with 'String' and
each other. The following will execute successfully:

ghci> mkFullName' exName exSurname
"Peter Griffin"

And so will the case in which we swap the arguments:

ghci> mkFullName' exSurname exName
"Griffin Peter"

Type synonyms are actually more useful for a different purpose that we'll
explore later.

=== SUM TYPES ==================================================================

Haskell uses Algebraic Data Types or ADTs for short. As the name implies,
there's an algebra of types hiding behind them. Our primary focus will be on
the sum and product types. To start, let's take a look at the definition of a
sum type we already know very well:

   +- Keyword   +------+----- Values / inhabitants of the type
   |            |      |
< data Bool = False | True
        |
    Type name

As you can see, in Haskell boolean is not a primitive type and can be defined
by first writing the 'data' keyword, then the name for our custom data type
which have the FIRST UPPERCASE LETTER and after the equality symbol (=) we can
list all the names of our custom values that inhabit our type that also must
have the FIRST UPPERCASE LETTER, separated by the pipe (|) operator.

Let's remember another sum type we've seen before when we used the 'compare'
function:

< compare :: Ord a => a -> a -> Ordering

< data Ordering = LT | EQ | GT

As you can see, the 'Bool' type is inhabited by 2 values 'False' and 'True'
while the 'Ordering' type is inhabited by 3 values 'LT', 'EQ' and 'GT'.

We call the number of values that inhabit a specific type "cardinality". So
cardinalities of 'Bool' and 'Ordering' are 2 and 3. Or, if we substitute values
with 1 and pipes (|) with +, it becomes a little bit clearer why they are
called sum types:

  card Bool = 1 + 1 = 2
  card Ordering = 1 + 1 + 1 = 3

Moving on, in our functions we can use pattern matching on provided sum types
to explore the possibilities:

> yesno :: Bool -> String
> yesno False = "No!"
> yesno True  = "Yes!"

Let's define our first custom data type that represents the red, green and blue
colour:

> data RGB = Red | Green | Blue

We can define a constant 'red' of the type 'RGB' that has a value of 'Red':

> colourRed :: RGB -- type level
> colourRed = Red  -- value level

Granted, this is a very simple example, but notice the distinction between the
type, the value of the type and the constant we're storing the value under.

If we try to evaluate the 'colourRed' or just a plain value like 'Green' in the
GHCi we'll get the following response:

ghci> colourRed

<interactive>:14:1: error: [GHC-39999]
    • No instance for ‘Show RGB’ arising from a use of ‘print’
    • In a stmt of an interactive GHCi command: print it

This is just GHCi complaining that our custom data type is missing a 'Show'
type class instance so it doesn't know how to properly show this type. Since we
don't know how to write custom type class instances yet, we'll let the compiler
do it for us in our next data type:

> data UDT = Uno | Dos | Tres
>   deriving ( Eq , Ord , Show , Read )

We use the 'deriving' keyword below the data type, followed by parentheses
containing a comma separated list of type classes we want to have automatically
derived.

Only a few can be derived by default. They are: Eq, Ord, Enum, Ix, Bounded,
Read, and Show. There are ways to derive more, but for now, this should do.

As you can see, besides 'Show' type class, we've also derived a few others. The
'Eq' allows us to compare the two values of the same type. If we try to see if
e.g. 'Red' is equal to 'Red' we'll get the similar error as with 'Show':

ghci> Red == Red

<interactive>:17:5: error: [GHC-39999]
    • No instance for ‘Eq RGB’ arising from a use of ‘==’
    • In the expression: Red == Red
      In an equation for ‘it’: it = Red == Red

Our new 'UDT' type has the 'Eq' instance, therefore we can compare it's values:

ghci> Uno == Uno
True
ghci> Dos == Tres
False

=== EXERCISE 1 =================================================================

1.1.
- Define a custom sum type 'UpTo5' that represents numbers from 1 to 5. Since
  numerical symbols are already "taken" you can prefix the number with a letter
  'N'. For example 'N2'.

> data UpTo5 = N1 | N2 | N3 | N4 | N5
>   deriving ( Eq , Show )

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

Let's say we want to write a function that replaces every element of a list of
of 'Int's with a "yes" or "no" string based on them being less than 5. We can
do that in a few ways.

We could use our previously defined function 'yesno' or define a similar helper
in the 'where' clause.

> lessThanFive1 :: [ Int ] -> [ String ]
> lessThanFive1 = map yesno . map (<5)

We could use a case expression and pattern matching, or 'if then else' in a
lambda:

> lessThanFive2 :: [ Int ] -> [ String ]
> lessThanFive2 = map (\ b -> case b of False -> "no"; True -> "yes") . map (<5)

Pattern matching, while useful, doesn't compose nicely, and defining a helper
function every time we want to react to 'True' or 'False' can be cumbersome.

Luckily, for every algebraic data type we can define an eliminator. Eliminators
are functions that allow us to consume / do anything with values of a type that
we could do with pattern matching. Eliminator for 'Bool' looks like this:

< bool :: a -> a -> Bool -> a
< bool f _ False = f
< bool _ t True  = t

It is a predefined function that can be found in the 'Data.Bool' module.

It takes values 'f' and 't' of the same type and returns one of them based on
what value of 'Bool' it has received. In other words, it allows us to prepare
the appropriate responses based on all possible values of 'Bool'. We can now
easily define variants of 'lessThanFive':

> lessThanFive3 :: [ Int ] -> [ String ]
> lessThanFive3 = map ( bool "no" "yes" ) . map (<5)

> lessThanFive4 :: [ Int ] -> [ String ]
> lessThanFive4 = map ( bool "greater or equal to 5" "less than 5" ) . map (<5)

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
- Define 'showRGB', without pattern matching, only using the previously defined
  eliminator.

> showRGB' :: RGB -> String
> showRGB' = rgb "Red" "Green" "Blue"

=== PRODUCT TYPES ==============================================================

Right now sum types may not seem that conceptually different from classical
enums. Before we unlock their full potential we'll take a look at some product
types first. They are the most similar to structs from C as they are just
"containers" for (possibly multiple) values of other types.

         Value constructor
                 |

> data Coord = Coord Int Int

         |            |   |
     Type name        +---+----- Types of value constructor fields.

>   deriving ( Eq , Show )

The 'Coord' data type represents a pair of discrete coordinates for the game of
sinking ships.

Notice that we use the same name for both the type name and the value
constructor. This is a common convention when we have only one value constructor
and it is perfectly fine as the type name lives on the "type level" while the
value constructor lives on the "value level" and the compiler will not confuse
the two.

If we look at the type of 'Coord' value constructor in the GHCi, we'll see the
following:

ghci> :t Coord
Coord :: Int -> Int -> Coord

The value constructor 'Coord' is actually a function that takes two integers and
produces a value of type 'Coord'. It essentially just wrapps two integers into
a tagged data structure so we know their pairing represents some coordinates.

We can now construct a list of 'Coord'inates that represents positions ships
in the game of sinking ships:

> ships :: [ Coord ]
> ships = [ Coord 1 3 , Coord 5 5 , Coord (-1) 2 , Coord 11 (-3) ]

This list contains 4 values of type 'Coord' that we have constructed by storing
two 'Int's in each value constructor.

The reason 'Coord' is a product type is because the number of unique values that
we can construct corresponds to the product of two 'Int' cardinalities. In
other words:

  card Coord = card Int * card Int = 2^64 * 2^64

Basically, for every concrete integer we put in the first field of the 'Coord'
we can choose any integer to put into the second field.

In order to do something useful with 'Coord' we can use pattern matching to
deconstruct the value constructor and pull out the values we have stored inside
of it's fields.

> isOnMainDiagonal :: Coord -> Bool
> isOnMainDiagonal ( Coord x y ) = x == y

This function deconstructs the 'Coord' value on the left side, assigns the 'x'
and 'y' label to the first and the second field of the constructor and then it
checks if the 'x' and 'y' are equal.

We can define a couple of utility functions that will help us get the specific
data inside the 'Coord'.

> getCX :: Coord -> Int
> getCX ( Coord x _ ) = x

> getCY :: Coord -> Int
> getCY ( Coord _ y ) = y

As well as some that will help us modify the data inside the 'Coord':

> setCX :: Int -> Coord -> Coord
> setCX newX ( Coord oldX oldY ) = Coord newX oldY

> setCY :: Int -> Coord -> Coord
> setCY newY ( Coord oldX oldY ) = Coord oldX newY

Remember that data structures in Haskell are generally immutable. In order to
"modify" a field basically have to create a new data structure and copy the
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

The 'Coord' was a fairly simple data type. For any more complex product data
type, writing getters and setters, as well as relaying on the positions of the
fields in the constructor can be unwieldy. To address that, we can use the
record syntax which makes product types look more like a simple struct:

> data Name = Name
>   { firstName   :: String
>   , familyName  :: String
>   } deriving ( Eq , Show )

With this we can explicitly state which field we want to assign the value to
without relying on the position of the arguments in the constructor:

> name1 :: Name
> name1 = Name { familyName = "Griffin" , firstName = "Peter" }

We can still rely on the position of the fields to construct a new name:

> name2 :: Name
> name2 = Name "Peter" "Parker"

However, if we change the order of fields in the 'Name' definition we'll the
interpretation of what "Peter" and what "Parker" are will change.

Besides that, while using the record syntax we also get getter functions for
free. They have the same name as our record fields:

< firstName   :: Name -> String
< familyName  :: Name -> String

To get the first name from a 'Name' value we can do this:

> fname1 :: String
> fname1 = firstName name1

To "modify" a field inside of the e.g. 'name1' and change the first name to e.g.
"Mark" while keeping the last name intact, we can use this syntax:

> name3 :: Name
> name3 = name1 { firstName = "Mark" }

Since we can't really directly "mutate" the state in Haskell, we are essentially
constructing a new name here that's based on the old one while the old one stays
intact.

We can also nest records like this:

> data Person = Person
>   { name :: Name
>   , oib  :: String
>   } deriving ( Eq , Show )

> person1 :: Person
> person1 = Person { name = Name "John" "Doe" , oib = "12345678901" }

To retrieve the nested piece of data like a person's first name we can use
function composition or application operator depending on what we're doing:

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

Here we've defined a type with two value constructors 'Circle' and 'Square'.
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

One issue with using field names in sums of products it that we might end up
with non total functions. On top of that, fields with the same name in different
type constructors need to be of the same type, otherwise Haskell will complain.

What would happen if we try to run this code?:

< radius ( Square 1 2 3 )

=== PARAMETRIZED TYPES =========================================================

We've already seen lists and tuples which are parametrized types. We can define
our own tuple like so:

> data Pair a b = PairConstructor a b
>   deriving ( Eq , Show )

With type parameters we've essentially made a data structure "template". You can
think of the 'Pair' as the type constructor and not a real / concrete type. It
only becomes a real type once we apply some arguments to it.

  Pair          -- Not a real type but a type constructor
  Pair Int      -- Still not a real type, it's missing an argument
  Pair Int Bool -- A real concrete type
  Pair a b      -- Also a real type because we've applied type variables to it

To construct a value of type 'Pair RGB Bool' we can do the following:

> pair1 :: Pair RGB Bool
> pair1 = PairConstructor Red False

How many unique values of type 'Pair RGB Bool' can we construct?

=== MAYBE ======================================================================

One important predefined parametrized data type is 'Maybe'. It is used to
represent a possibility of value not existing:

< data Maybe a = Nothing | Just a

A value of type 'Maybe Int' will either be 'Nothing' or contain 'Just' some
'Int' value, e.g.:

> mInt1 :: Maybe Int
> mInt1 = Nothing

> mInt2 :: Maybe Int
> mInt2 = Just 53

While using the 'head' function before, we've seen that it throws an error in
case of an empty list:

< head :: [ a ] -> a
< head [] = error "Empty list"
< head ( x : _ ) = x

This is not desirable as this behaviour is hidden from us, and just looking at
the type signature we don't know that the function can "fail". By using 'Maybe'
we can define the 'safeHead' which will make the possibility of not having the
value explicit in the type, and it will also allow the compiler to warn us in
case we forgot to handle the failure.

> safeHead :: [ a ] -> Maybe a
> safeHead [] = Nothing
> safeHead ( x : _ ) = Just x

Now if we want to e.g. get the head of a list and add 1 to it we'll be forced to
explicitly handle the possibility that the list is empty:

> headPlus1 :: Num a => [ a ] -> a
> headPlus1 lst = case safeHead lst of
>   Nothing -> 0        -- if the list is empty and has no head, we return 0
>   Just el -> el + 1   -- otherwise we add 1 to it and return that value

As you can see, we can use pattern matching and deconstruction in the 'case'
expression.

As 'Maybe' is frequently used data type we also have an eliminator for it:

< maybe :: b -> ( a -> b ) -> Maybe a -> b
< maybe n _ Nothing = n
< maybe _ j ( Just a ) = j a

We could've implemented 'headPlus1' with it as well:

> headPlus1' :: Num a => [ a ] -> a
> headPlus1' = maybe 0 (+1) . safeHead

You can find other useful functions for working with 'Maybe' in the 'Data.Maybe'
module.

=== EITHER =====================================================================

Another often used predefined data type is 'Either'. While 'Maybe' represents a
possibility of 'Nothing' and an arbitrary value of type 'a', 'Either'
represents a possibility of two arbitrary values and is defined as:

< data Either a b = Left a | Right b

The 'Left' value constructor represents the case where we have a value of type
'a' while the 'Right' value constructor represents value of type 'b'.

We often use 'Either' to provide a more informative failure message instead of
just e.g. 'Nothing'.

Just like 'Maybe', 'Either' has an eliminator for it's values:

> either :: ( a -> c ) -> ( b -> c ) -> Either a b -> c
> either fac _ ( Left a ) = fac a
> either _ fbc ( Right b ) = fbc b

=== EXERCISE 5 =================================================================

- 5.1.
  Define 'errorHead' that either returns an error message "Empty list" in case
  the list is empty, or it returns the first value of the list.

  NOTE: Do not use 'error' function for this. Use the 'Either' data type.

> errorHead :: [ a ] -> Either String a
> errorHead [] = Left "Empty list"
> errorHead (x:_) = Right x

- 5.2.
  Implement a function that will return total monthly salaries from a list of
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

We've seen that we can calculate the number of inhabitants of ADTs. This is not
just a nice trick, but a very useful property from which it follows that any two
types with the same number of inhabitants are isomorphic or equivalent to
each other. From this it follows that any custom data type can be expressed by
composing just three basic types. A unit, sum and product type. These types
correspond to '()', 'Either' and '(a, b)'.

The ability to express any custom data type in terms of just these three data
types is the basis of automatic derivation mechanism as well as the 'Generic'
type class which allows us to write generic functions that work for any data
type helping us to reduce the boiler plate.

=== NEXT =======================================================================

In the next lesson we'll explore recursive data types, as well as a useful
pattern called 'fmap' that will make it easy to apply our ordinary functions to
values inside of the parametrized types.
