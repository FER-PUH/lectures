University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2017/2018

LECTURE 9: Custom data types 1

v1.0

(c) 2017 Jan Šnajder

==============================================================================

> {-# OPTIONS_GHC -Wno-missing-fields #-}
>
> import Data.List
> import ExtraStuff

=== RECAP ====================================================================

In the first half of the course, we focused on functions: we learned how to
define them in various ways, how to define higher order functions, how to use
these to abstract useful functional patterns, and how to combine them into more
complex functions. However, we restricted ourselves to using standard built-in
types. In real-life scenarios, we will need to define more complex types, even
recursive types. Today, we start looking into custom data types.

=== DATA TYPES ===============================================================

--> data Tricolor = Red | Green | Blue

'Tricolor' is a new type. 'Red', 'Green', and 'Blue' are DATA CONSTRUCTORS
The names of types and data constructors are capitalized.

Let's try this out:

  ghci> :t Red

Data types like this one, in which we explicitly enumerate the possible values,
are called ALGEBRAIC DATA TYPES.

This is different from defining an alias for an existing type, which we do as
follows:

> type Word = [Char]
> type Coord = (Int, Int)

Up until now we've already seen a couple of data types:

  data Bool = True | False
  data Ordering = LT | EQ | GT

Let's recall:

  compare :: Ord a => a -> a -> Ordering

We can of course use our custom data types when we define new functions:

> warmColor :: Tricolor -> Bool
> warmColor Red = True
> warmColor _   = False

> myColor = Red

What happens if we try to evaluate the value of 'myColor' in ghci?

The value cannot be shown because its type is not a member of the 'Show' type
class. We can fix this easily:

> data Tricolor = Red | Green | Blue
>  deriving Show

This makes the 'Tricolor' type a member of the 'Show' type class (more
precisely, it automatically derives an instance of the 'Show' class for this
type).

IMPORTANT: Data constructors must be unique! The same data constructor cannot
be used to define different types. This won't work:

  data Tricolor = Red | Green | Blue
  data WarmColors = Red | Orange | Yellow

The constructors 'Red', 'Green', and 'Blue' are actually values. We call such
constructors NULLARY CONSTRUCTORS. A type that only contains nullary
constructors is similar to ENUMERATIONS in other programming languages.

But constructors can also be binary, ternary, etc. E.g., (example taken from
LYAHFGG):

> data Shape =
>     Circle Double Double Double
>   | Rectangle Double Double Double Double
>   deriving Show

'Circle' is a ternary constructor: it takes three real numbers (the coordinates
and the radius). 'Rectangle' is a quaternary constructor: it takes four numbers
(two pairs of coordinates).

This reveals that data constructors are actually functions. What is the type of
the 'Circle' constructor?

  Circle :: Double -> Double -> Double -> Shape

We can also pattern match against constructors with multiple arguments:

> isCircle :: Shape -> Bool
> isCircle (Circle _ _ _) = True
> isCircle _              = False

Btw., we could also have defined:

  data Shape =
      Circle (Float, Float) Float
    | Rectangle (Float, Float) (Float, Float)

Let's look at some examples of functions (and values) that use 'Circle' and
'Rectangle' types:

> myCircle = Circle 5 5 10
> myRectangle = Rectangle 10 10 100 200
> unitCircle x y = Circle x y 1

A function to compute the area of a shape:

> area :: Shape -> Double
> area (Circle _ _ r)          = r ^ 2 * pi
> area (Rectangle x1 y1 x2 y2) = (abs $ x1 - x2) * (abs $ y1 - y2)

Because data constructors 'Circle' and 'Rectangle' give values of the same
type, those values can be combined in a single list:

> myShapes = [myCircle, myRectangle, unitCircle 0 0, Rectangle 0 0 5 5]

This is actually how one circumvents the problem of not being able to construct
heterogeneous lists in Haskell.

We can now define:

> totalArea :: [Shape] -> Double
> totalArea = sum . map area

A somewhat better approach to define the above types:

> data Point = Point Double Double
>   deriving Show
> data Shape2 = Circle2 Point Double | Rectangle2 Point Point
>   deriving Show

Note that we use 'Point' as both a type name and a data constructor. This is
totally OK (and in fact common for types with only one data constructor).

> myCircle2 = Circle2 (Point 5 5) 10
> myRectangle2 = Rectangle2 (Point 10 10) (Point 10 10)

> area2 :: Shape2 -> Double
> area2 (Circle2 _ r) = r ^ 2 * pi
> area2 (Rectangle2 (Point x1 y1) (Point x2 y2)) =
>   (abs $ x1 - x2) * (abs $ y1 - y2)

=== EXERCISE 1 ===============================================================

1.1.
- Define a 'Date' structure with the appropriate fields.
- Define a function that shows a date in the DD.MM.YYYY format (without
  leading zeroes).
showDate :: Date -> String

1.2.
- Define a function
  translate :: Point -> Shape2 -> Shape2
  that translates a shape into the direction of vector (x,y).

1.3.
- Write a function 'inShape' that tests whether a point is contained within a
  given shape (or is on its border).
  inShape :: Shape2 -> Point -> Bool
- Write a function 'inShapes' that tests if the point is within any shape from
  the list of shapes.
  inShapes :: [Shape2] -> Point -> Bool

1.4.
- Define your type 'Vehicle' that can be a 'Car', 'Truck',
  'Motorcycle', or 'Bicycle'. The first three store a name of the manufacturer
  (String) and horsepower (Double).
- Write a function 'totalHorsepower' that adds up the horsepower of the
  vehicles, assuming that bicycle's horsepower is 0.2.

=== RECORDS ==================================================================

> data Level    = Bachelor | Master | PhD deriving (Show, Eq)
> data Student2 = Student2 String String String Level Double deriving Show

> firstName2 :: Student2 -> String
> firstName2 (Student2 f _ _ _ _) = f

> lastName2 :: Student2 -> String
> lastName2  (Student2 _ l _ _ _) = l

> studentId2 :: Student2 -> String
> studentId2 (Student2 _ _ i _ _) = i

This is somewhat tedious and long-winded. It is better to use RECORDS:

> data Student = Student
>  { firstName  :: String
>  , lastName   :: String
>  , studentId  :: String
>  , level      :: Level
>  , avgGrade   :: Double } deriving Show

This automatically gives us:

  firstName :: Student -> String
  lastName  :: Student -> String
  studentId :: Student -> String
  level     :: Student -> Level
  avgGrade  :: Student -> Double

We can now define a record like this:

> bestStudent = Student
>  { studentId = "0036491215"
>  , firstName = "John", lastName = "Doe"
>  , level = Master, avgGrade = 5.0 }

Let's define a function to show some data from the record:

> showStudent :: Student -> String
> showStudent s = studentId s ++ " " ++ firstName s ++ " " ++ lastName s

or

> showStudent2 :: Student -> String
> showStudent2 s = intercalate " " [studentId s, firstName s, lastName s]

We can also define it like this:

> showStudent3 :: Student -> String
> showStudent3 (Student {studentId=id, firstName=f, lastName=l}) =
>   intercalate " " [id, f, l]

Let's write a function to select students whose average grade is above a given
threshold:

> aboveStudents :: Double -> [Student] -> [Student]
> aboveStudents x = filter ((>= x) . avgGrade)

When we define a record, we need not define all fields. Those that we don't
define will be 'undefined'. The code will compile, but we'll get a warning.

> someStudent = Student { firstName = "Marko", avgGrade = 4.3 }

Will 'showStudent someStudent' work?

Will 'map firstName $ aboveStudents 4.0 [bestStudent, someStudent]' work?

We can modify field values in a record:

> bestStudent2 = bestStudent { avgGrade = 4.9 }
> someStudent2 = someStudent { lastName = "Markov", studentId = "0036365438" }

This is useful when we want to define default values:

> bachelorStudent = Student { level = Bachelor }
> masterStudent = Student { level = Master }
> phdStudent = Student { level = PhD }

> newStudent = bachelorStudent {
>   firstName = "Zoran", lastName = "Zoki",
>   studentId = "00364532350", avgGrade = 4.5 }

We can define a record in a shorter way, respecting the order of the fields:

> newStudent2 = Student "Petar" "Perić" "00364542345" Master 3.5

=== EXERCISE 2 ===============================================================

2.1.
- Define a function that increases the average grade of the student by 1.0,
  but not above 5.0.
  improveStudent :: Student -> Student

2.2.
- Write a function to compute the average grade of students for the different
  study levels.
  avgGradePerLevels :: [Student] -> (Double, Double, Double)

2.3.
- Write a function that returns a list of matriculation numbers for a given
  study level, sorted by average grade in descending order.
  rankedStudents :: Level -> [Students] -> [String]

2.4.
- Write a function
  addStudent :: Student -> [Student] -> [Student]
  that adds a student to a list of students. If a student with an identical
  matriculation number already exists in the list, the function should return an
  error.

=== PARAMETRIZED TYPES =======================================================

> data OldLevels  = Graduate | Doctorate deriving Show

> data GeneralStudent a = Student3 String String String a Double deriving Show

'GeneralStudent' has a type parameter 'a'. Depending on what type we choose for
'a', we will get different types:

> type BolognaStudent = GeneralStudent Level
> type FER1Student    = GeneralStudent OldLevels

We call such types, which take parameters as input, TYPE CONSTRUCTORS.

Parametrized data types are typically data containers of some sort. E.g.:

> data MyBox a = InBox a

So, 'MyBox' is a type constructor that we can use to define different types.
E.g.:

> type StringBox = MyBox String
> type IntBox    = MyBox Int

'InBox' is a data constructor that we can use to construct different values of
different types. Haskell will automatically determine the correct type:

> b1 = InBox 1.2
> b2 = InBox "Haskell"
> b3 = InBox (1, 3)

What are the types of these expressions?

A better way to accomplish the same:

> data Box a = Box { unbox :: a } deriving Show

A parametrized type can have multiple parameters:

> data MyPair a b = MyPair (a, b) deriving Show

So we can have:

  MyPair (1,1) :: MyPair Int Int
  MyPair ("bla",1.2) :: MyPair String Double

We can, for example, define:

> type IntMyPair = MyPair Int Int
> type MyPairType a = MyPair a String

A function to take the first element from 'MyPair':

> fstMyPair :: MyPair a b -> a
> fstMyPair (MyPair (x,_)) = x

=== MAYBE TYPE ===============================================================

Now, there is one very important parametrized type (defined in 'Data.Maybe'):

  data Maybe a = Nothing | Just a

For instance, we can have:

  Just 5 :: Maybe Int
  Just "bla" :: Maybe String
  Just (1,1) :: Maybe (Int, Int)

The 'Maybe' data type is used for situations in which
(1) a value is optional,
(2) an error can occur.

CASE 1: Optionality

> data Employee = Employee
>   { name   :: String
>   , salary :: Maybe Double } deriving Show

We can now define:

> showSalary :: Employee -> String
> showSalary e = case salary e of
>    Nothing -> "unknown"
>    Just n  -> show n ++ " kn"

A function to concatenate two 'Maybe String':

> concatMaybeStrings :: Maybe String -> Maybe String -> Maybe String
> concatMaybeStrings (Just s1)  (Just s2)  = Just $ s1 ++ s2
> concatMaybeStrings s@(Just _) Nothing    = s
> concatMaybeStrings Nothing    s@(Just _) = s
> concatMaybeStrings _          _          = Nothing

CASE 2: Error handling

> safeHead :: [a] -> Maybe a
> safeHead []    = Nothing
> safeHead (x:_) = Just x

Also useful is the 'Either' type:

  data Either a b = Left a | Right b

It is commonly used when we also want to return an error message.
We return 'Right b' is there was no error, otherwise we return 'Left a', where
'a' is typically a 'String' (the error message).

> safeHead2 :: [b] -> Either String b
> safeHead2 []    = Left "empty list"
> safeHead2 (x:_) = Right x

=== EXERCISE 3 ===============================================================

3.1.
- Define your own parametrized type 'MyTriplet' that contains the values of
  three different types. Do this using a record.
- Define a function
  toTriplet :: MyTriplet a b c -> (a, b, c)
  that converts a 'MyTriplet' value into an ordinary triplet.

3.2.
- Define a function (Employee - salary :: Maybe Double, name :: String) deriving Show
  totalSalaries :: [Employee] -> Double
  that sums the known salaries of employees (salaries that are not 'Nothing').

3.3.
- Write a function 'addStudent2' that works like 'addStudent' from problem 2.4
  but returns a 'Maybe' type instead of an error.
  addStudent2 :: Student -> [Student] -> Maybe [Student]
- Write 'addStudent3' that returns an 'Either'.

=== FMAP =====================================================================

Consider the following data structures:

> data Customer = Customer
>   { customerName    :: String
>   , customerAge     :: Int
>   , customerAddress :: Maybe Address }
>   deriving (Eq, Show)

> data Address  = Address
>   { streetName   :: String
>   , streetNumber :: Int
>   , zipCode      :: String
>   , city         :: String }
>   deriving (Eq, Show)

> c1 = Customer "Ivo" 22 (Just $ Address "Bauerova" 10 "10000" "Zagreb")
> c2 = Customer "Ana" 30 Nothing

Let's write a function that returns the city in which a customer lives,
provided the address is known:

> customerCity :: Customer -> Maybe String
> customerCity c = case customerAddress c of
>   Just a  -> Just $ city a
>   Nothing -> Nothing

Similarly, a function that returns a street name and number:

> customerStreet :: Customer -> Maybe (String, Int)
> customerStreet c = case customerAddress c of
>   Just (Address s n _ _) -> Just (s, n)
>   Nothing                -> Nothing

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

> customerCity2 :: Customer -> Maybe String
> customerCity2 = fmap city . customerAddress

> customerStreet2 :: Customer -> Maybe (String,Int)
> customerStreet2 =
>   fmap (\(Address s n _ _) -> (s, n)) . customerAddress

== NEXT =======================================================================

In the next lecture, we'll look further into types: we'll discuss recursive
types and how to define our own type class instances.
