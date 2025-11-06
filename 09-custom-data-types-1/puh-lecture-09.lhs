> {-# LANGUAGE RecordWildCards #-}
> {-# LANGUAGE OverloadedRecordDot #-}
> {-# LANGUAGE DuplicateRecordFields #-}

University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2025/2026

LECTURE 9: Custom data types 1

v1.0

(c) 2025 Luka Hadžiegrić

================================================================================

> module Lecture09 where

=== INTRODUCTION ===============================================================

So far we've mostly been focused on the basic language syntax, different types
of functions and ways to compose them, some useful patterns like map and fold,
and we've explored the lazy semantics and have mentioned purity. Besides a
different syntax, most of these concepts are perfectly applicable to many other
programming languages and are really nothing new. What makes Haskell really
stand out among it's peers is it's very expressive type system based on solid
theoretical principles.

In our previous lessons we've mostly stuck to the basic data types you may find
in other programming languages. They are so seemingly plain that some very
misguided people advocate against having any types at all.

During this lesson we'll see that there's so much more to types than initially
meets the eye.

=== DATA TYPES =================================================================

There's the data and then there are types of data. A string of bytes in memory,
without knowing what they represent, could be interpreted as pretty much
anything. Types are what communicates to us and the compiler the intended
interpretation of the data and what operations make sense on that data.

Types only exist during the compilation time. After the compilation we are just
left with appropriately placed machine instructions that transform the data in
certain ways.

Usually types are linked to sets, and the values that inhabit those types to
members of those sets. However, there's one key difference between the types and
the sets that makes the Hindley-Milner type system (used in Haskell) so powerful
and able to infer type of any expression (unless we intentionally weaken the
inference capabilities).

While sets uniquely determine their members, inhabitants of a type uniquely
determine the type.

In other words, when we look at a specific value, in the context of sets we
cannot uniquely determine which set the value belongs to, as it can be a member
of multiple sets, while in the context of types we immediately know which type a
specific value inhabits. This is not exactly true in practice as we'll see in a
bit, but it is a good piece of intuition to develop a better sense about how
Haskell's type inference works.

=== ALGEBRAIC DATA TYPES (ADTs) ================================================

One of the Haskell's killer feature are Algebraic Data Types. While they may not
seem like much initially, they allow for very efficient and effective data
modeling, as well as making the code more readable and safe.

And, as the name implies, they have algebra hiding behind them.

=== SUM TYPES ==================================================================

Sum types are the most basic way to define a custom type. They resemble enums
found in other languages.

We've already seen and worked with some predefined sum types:

  data () = ()
  data Bool = False | True
  data Ordering = LT | EQ | GT
  ( from 'compare :: Ord a => a -> a -> Ordering' )

To define a custom data type we start with the keyword 'data' followed by the
name of our custom type and after the sign '=' we list custom values that
inhabit the type separated with the '|' symbol.

We can define our own data type like so:

> data UDT = Uno | Dos | Tres

It is important to note that the names of custom types and values must begin
with an uppercase letter!

To confirm that we were indeed successful we can try to determine the type of
one of the values:

ghci> :t Uno
Uno :: UDT

If we enter 'False' into the GHCi and press enter, we'll get 'False' written out
to the console, however if we try to do the same with one of the 'UDT' values
we'll see this error:

ghci> Uno

<interactive>:7:1: error: [GHC-39999]
    • No instance for ‘Show UDT’ arising from a use of ‘print’
    • In a stmt of an interactive GHCi command: print it

This is because in order to display values, GHCi requires the type to implement
the 'Show' interface and the 'show' function. We don't know yet how to write an
instance of a type class, but we can write the following function:

> showUDT :: UDT -> String
> showUDT Uno = "Uno"
> showUDT Dos = "Dos"
> showUDT Tres = "Tres"

Easy! Now we can "show" our 'UDT' values in the GHCi:

ghci> showUDT Uno
"Uno"

Of course, this is a bit silly since it doesn't integrate with GHCi and the
broader ecosystem of functions in the 'Prelude' like 'read' and 'print'.

Fortunately, Haskell is smart, and it can derive those instances for us. Let's
do just that with our next equally imaginative type:

> data RGB = Red | Green | Blue
>   deriving ( Eq , Show , Read )

We can use the word 'deriving' followed by the parentheses with comma separated
list of supported type classes we want to have automatically derived. With these
we can now convert our value into a string, convert a string into our value and
check if the two values of our types are equal:

ghci> :t Red
Red :: RGB

ghci> Red
Red

ghci> show Red
"Red"

ghci> read "Red" :: RGB
Red

After all of this. Let's ask ourselves why are these types called the sum types?
It is because of the number of their inhabitants. We just sum them / add them
together. We call the number of inhabitants of a type cardinality.

With that in mind, we can determine the cardinality of types we've seen so far:

  card () = () = 1
  card Bool = False | True = 1 + 1 = 2
  card Ordering = LT | EQ | GT = 1 + 1 + 1 = 3

We'll see a bit later how this fits into the big picture.

One interesting thing about ADTs is that pattern matching didn't exist since
their conception. The original idea was that when you'd define a custom type
you'd also get a function to consume that type.

Those functions are called eliminators as they "eliminate" a value. One such
example is the 'bool' function from 'Data.Bool' module. Here's it's
implementation:

> bool :: a -> a -> Bool -> a
> bool f _ False = f
> bool _ t True  = t

They can be really convenient as, unlike pattern matching, we can partially
apply them and compose them with other functions.

As you can see, we choose the first or the second argument based on the concrete
value of the third argument. We have of course used pattern matching to
implement the function itself. But that's because the compiler doesn't provide
it automatically for us when we define the type.

=== EXERCISE 1 =================================================================

1.1.
- Write an eliminator for our RGB data type (write the type signature first).

> rgb = undefined

1.2.
- Implement the 'showRGB' function in terms of the 'rgb' eliminator.

> showRGB = undefined

=== PRODUCT TYPES ==============================================================

Dual to sum types are product types. As their name implies, their cardinality
somehow relates to products of cardinalities of other types. We've already seen
a canonical product type in the form of a tuple, but we'll explore them more
carefully a bit later.

For now, let's define our own specialized triple for holding a mix of three
colors.

> data Color = Color RGB RGB RGB
>   deriving ( Eq , Show , Read )

This is a slightly different from the sum types as we don't really have "static"
values that we can use immediately. Instead, we get a value constructor.

     Data Type       Field Types
         |            |   |   |
         v            v   v   v
  data Color = Color RGB RGB RGB
                 ^
                 |
         Value Constructor

It is a convention to name the value constructor the same name as the type, but
we could've named it anything we want.

In this case, the 'Color' value constructor is a function that takes three
'RGB' values and returns, or rather constructs, a value of type 'Color'.

ghci> :t Color
Color :: RGB -> RGB -> RGB -> Color

The cardinality of a product type boils down to a product of cardinalities of
it's component types. Concretely, our 'Color' data type has a cardinality of
3 * 3 * 3 = 18, or 18 values that inhabit this type.

Here are some concrete examples of values that inhabit the 'Color' type:

> cex1 :: Color
> cex1 = Color Red Red Red

> cex2 :: Color
> cex2 = Color Red Red Green

To consume these values we can again use pattern matching. Let's write three
functions that access the first, second and third field of the 'Color' data
type:

> getC1 :: Color -> RGB
> getC1 ( Color a _ _ ) = a

> getC2 :: Color -> RGB
> getC2 ( Color _ b _ ) = b

> getC3 :: Color -> RGB
> getC3 ( Color _ _ c ) = c

Besides just getting the data from the product types, we may want to update a
field. Remember that there are no mutations in Haskell. To "update" a value we
have to construct a new value based on the old one:

> setC1 :: Color -> RGB -> Color
> setC1 ( Color _ b c ) a = Color a b c

> setC2 :: Color -> RGB -> Color
> setC2 ( Color a _ c ) b = Color a b c

> setC3 :: Color -> RGB -> Color
> setC3 ( Color a b _ ) c = Color a b c

=== EXERCISE 2 =================================================================

2.1
- What should be the type for the 'Color' eliminator?

> color :: a

2.2
- Implement the 'Color' eliminator 'color'.

> color = undefined

2.3
- Implement the get and set functions in terms of the 'color' eliminator.

=== RECORDS ====================================================================

While pattern matching is a nice thing to have, often times we just want to
access or modify a piece of information within the product type. To do that,
we've defined getters and setters for our type, however, as you might have
noticed that's somewhat time consuming and repetitive. The kind of task that's
best left to a machine.

Haskell has a special syntax for defining custom data types exactly for that
purpose:

> data EUR = EUR Float
>   deriving ( Eq , Show , Read )

> data Address = Address
>   { addressStreet   :: String
>   , addressNumber   :: Int
>   , addressCity     :: String
>   , addressCountry  :: String
>   } deriving ( Eq , Show , Read )

> data User = User
>   { userUUID      :: Int
>   , userName      :: String
>   , userSurname   :: String
>   , userAddress   :: Address
>   , userAccounts  :: [ Account ]
>   } deriving ( Eq , Show , Read )

> data Account = Account
>   { accountUUID     :: Int
>   , accountBalance  :: EUR
>   } deriving ( Eq , Show , Read )

With this syntax we give labels to the fields and automatically get the getter
functions of the same name:

  addressStreet :: Address -> String
  addressNumber :: Address -> Int
  addressCity :: Address -> String
  addressCountry :: Address -> String

  userUUID :: User -> Int
  userName :: User -> String
  userSurname :: User -> String
  userAddress :: User -> Address
  userAccounts :: User -> [ Account ]

  accountUUID :: Account -> Int
  accountBalance  :: Account -> EUR

We can still construct the values without mentioning the fields and just relying
on the argument positioning (not recommended):

> acc01 :: Account
> acc01 = Account 5 ( EUR 50000 )

However, now we can also be precise about what each value we give actually is.
This is particularly important in case we ever swap the order of e.g. name and
surname in the type definition when refactoring.

> acc02 :: Account
> acc02 = Account { accountUUID = 3 , accountBalance = EUR (-6820) }

> adr01 :: Address
> adr01 = Address
>   { addressStreet   = "Unska"
>   , addressNumber   = 3
>   , addressCity     = "Zagreb"
>   , addressCountry  = "Hrvatska"
>   }

> usr01 :: User
> usr01 = User
>   { userUUID = 10
>   , userName = "Tony"
>   , userSurname = "Hawk"
>   , userAddress = adr01
>   , userAccounts = [ acc01 , acc02 ]
>   }

With this setup, it is now easy to get a value that's deeply nested within a
record. For example, if we're interested in 'addressNumber' of a 'User' we can
do the following:

ghci> ( addressNumber . userAddress ) usr01
3

Besides defining new values, records also have a syntax for "modifying" values.
Let's say we want to change the name, street and the city of 'usr01' at the same
time:

> usr02 :: User
> usr02 = usr01
>   { userName = "Jhonny"
>   , userAddress = ( userAddress usr01 )
>     { addressStreet = "Mate Balote"
>     , addressCity = "Rovinj"
>     }
>   }

With the record syntax, some extra pattern matching features are also available:

> getAccountUUID :: Account -> Int
> getAccountUUID Account{ accountUUID } = accountUUID

With this, we can bring only the selected labels into scope as variables instead
of functions.

> getAccountBalance :: Account -> EUR
> getAccountBalance Account{ accountBalance = bal } = bal

And this piece of syntax allows us to rename the variable to prevent polluting
the function scope with unwanted names.

=== EXERCISE 3 =================================================================

3.1
- Using function composition, write a function that returns a total of all
  'User' 'Account's.

> accountsTotal :: User -> Float
> accountsTotal = undefined

=== USEFUL LANGUAGE EXTENSIONS =================================================

Even with the record syntax, it can be quite annoying to work with deeply nested
records. This is why there are several language extensions that can help us with
that.

Language extensions can be considered "experimental" features that are still in
the testing phase and can be compiler specific. But, because the GHC is
basically the only Haskell compiler, it is pretty safe to use most of those
extensions without worrying about the compatibility.

We can enable language extensions by writing special comments interpreted by the
compiler (called pragmas) at the very top of a Haskell file:

{-# LANGUAGE RecordWildCards #-}

The RecordWildCards allows us to use wild card syntax to bring fields into scope
instead of listing them manually:

> getAccountUUID' :: Account -> EUR
> getAccountUUID' Account{..} = accountBalance

As well as construct values simply by having the variables with the same name as
the field labels in scope:

> acc03 :: Account
> acc03 = Account{..}
>   where
>    accountUUID = 5
>    accountBalance = EUR 15

{-# LANGUAGE OverloadedRecordDot #-}

Syntactic sugar that allows us to access deeply nested fields the same way we
would in "normal" programming languages:

> exAddrNumber :: Int
> exAddrNumber = usr01.userAddress.addressNumber

{-# LANGUAGE DuplicateRecordFields #-}

An extension that allows us to have two or more data types in the same module
that have fields with the same name, without the compiler complaining:

> data Ex01 = Ex01 { field01 :: String , field02 :: Int }

> data Ex02 = Ex02 { field01 :: Char   , field02 :: Bool }

=== SUM OF PRODUCTS ============================================================

We've seen sums, we've seen products, it's only logical that we can sum those
products.

> data Weird = WeirdNull | WeirdNum Int Bool | WeirdBool Bool
>   deriving ( Eq , Show , Read )

Cardinality of weird is as follows:

  card Weird = 1 + ( 2^64 * 2 ) + 2 = 36893488147419103000

Quite a number of inhabitants. As you can see, we can combine both products and
sums into what's called a tagged union.

We can write a simple function that specifies how to "add" two 'Weird' numbers:

> addWeird :: Weird -> Weird -> Weird
> addWeird WeirdNull          _               = WeirdNull
> addWeird (WeirdNum  n1 b1) (WeirdNum n2 b2) = WeirdNum (n1 + n2) (b1 && b2)
> addWeird (WeirdNum  n1 b1) (WeirdBool   b2) = WeirdNum n1 (b1 && b2)
> addWeird (WeirdBool b1   ) (WeirdNum n2 b2) = WeirdNum n2 (b1 && b2)
> addWeird (WeirdBool b1   ) (WeirdBool   b2) = WeirdBool (b1 && b2)
> addWeird _                 _                = WeirdNull

It is also possible to use the record syntax like this:

> data SumRec
>  = SRNull
>  | SRA { srFieldA :: Int }
>  | SRB { srFieldA :: Int , srFieldB :: String }
>  deriving ( Eq , Show , Read )

This however is not recommended as we now have partial functions:

  srFieldA :: SumRec -> Int
  srFieldB :: SumRec -> String

Notice that the 'SRNull' is also of type 'SumRec', therefore we get the
following result:

ghci> srFieldA SRNull
*** Exception: No match in record selector srFieldA

When using sums of products it is recommended avoiding the record syntax. It is
much better to simply define another type that you will then add to the tagged
union, e.g.:

> data SumRec2 = SRAddr Address | SRUser User
>   deriving ( Eq , Show , Read )

=== PARAMETRIZED TYPES =========================================================

We've already seen a few parametrized types. Namely lists and tuples. They have
a type parameter for the type of values they'll contain. For now we can think of
them as "container" types.

Lists we'll explore in the next lesson, but tuples are a canonical example of
a product type, and we can imagine it's definition is as follows:

  data ( a , b ) = ( a , b )

Besides those two, we have 'Maybe' and 'Either' data types:

  data Maybe a = Nothing | Just a

As you can see, 'Maybe' has two value constructors. One is 'Nothing' indicating
that there is no value of type 'a', while 'Just' is a constructor that indicates
a presence.

You can think of 'Maybe' as the alternative to 'null', except in Haskell,
unlike in many other programming languages, compiler will warn us in case we
haven't handled the 'null' possibility.

'Maybe', like 'Bool' has it's own eliminator 'maybe' that's imported by default.
You can also find some useful 'Maybe' utilities in the 'Data.Maybe' module.

Let's explore the 'Either' data type. 'Either' is the canonical example of a
sum type, and it's definition is as follows:

  data Either a b = Left a | Right b

It is quite similar to 'Maybe', except instead of 'Nothing' it has 'Left' that
can contain a value of type 'a'. Basically, it is a possibility of either one or
the other value.

It is often used to provide a custom and explicit error message.

One thing to note about all of these parametrized data types is that they are
not actually types. They are type constructors, meaning that they become actual
types only after all of their type arguments have been filled in.

What we haven't mentioned yet is that types also have types, and we call those
types "kinds". We can check the kind of a type by using the ':k' command in the
ghci.

ghci> :k Int
Int :: *

As you can see, the kind of 'Int' is '*'. The '*' is deprecated and will be
replaced by a more meaningful word 'Type' in the future versions of GHC.

So, what we see here is that the kind of type 'Int' is a 'Type'. But, what about
'Maybe'?

ghci> :k Maybe
Maybe :: * -> *

As you can see, it's kind is 'Type -> Type'. This indicates that for 'Maybe' to
be a "real" type, we first have to give it some other type. And if we take a
second look at this "kind signature", we'll notice that this also implies type
level functions. Can we execute functions on types? Setting this aside, here's
the kind signature of 'Either':

ghci> :k Either
Either :: * -> * -> *

As we can see, it expects two types before it becomes an actual type. If we
apply e.g. 'Int' to both 'Maybe' and 'Either' we get following:

ghci> :k Maybe Int
Maybe Int :: *

ghci> :k Either Int
Either Int :: * -> *

'Maybe Int' is now a concrete type, while 'Either' is missing one more 'Type'.

=== EXERCISE 4 =================================================================

4.1
- Define a safe head using 'Maybe'

> safeHead :: [ a ] -> Maybe a
> safeHead = undefined

4.2
- Define a function that takes in two lists of numbers and returns either an
  error message if either one of them is empty, or a sum of the first two
  elements.

> elaborateSum :: Num a => [ a ] -> [ a ] -> Either String a
> elaborateSum = undefined

=== THE BIG REVEAL =============================================================

Throughout the lesson we've been thinking about the cardinality of our types. By
now it should be obvious what the cardinality of e.g. 'Maybe Bool' or
'Either Char Int' is. But is calculating the number of inhabitants and pattern
matching all we can do with ADTs?

As it turns out, no! This idea goes much deeper. It turns out that if for any
two types we have functions 'f :: a -> b' and 'g :: b -> a' that are
bijections, these two types can be considered equal.

It is important to note the difference in meaning between the word "equal" and
the "same".

To be very precise, we can say these two types are isomorphic. We'll explore
this on 'Maybe' and 'Either'.

> m2e :: Maybe a -> Either () a
> m2e Nothing    = Left ()
> m2e ( Just a ) = Right a

> e2m :: Either () a -> Maybe a
> e2m ( Left _ ) = Nothing
> e2m ( Right a ) = Just a

This is a very important insight, because it tells us that we can express any
custom data type in terms of just two basic types. A sum or the 'Either a b'
type, and a product or a pair / '(a , b)'.

Being able to express any custom type in the canonical form opens us up to a
lot of advanced techniques like generic programming which is incredibly useful
when we want to operate on the data of certain "shape".

A shining example of generic programming in Haskell is the Aeson library which
allows us to easily convert our custom data types into JSON and back.

We won't be able to do this yet as we need TypeClasses to complete our
tool-set, however we can try and write a few canonical variants of our custom
types for fun.

=== EXERCISE 5 =================================================================

5.1.
- Let's remember our 'UDT' type from the beginning:

  data UDT = Uno | Dos | Tres

  Write the UDT type in terms of 'Either' and unit / '()'

> type UDT' = () -- replace with a new type

5.2.
- Express the 'Address' type in terms of 'Either' and tuple '(,)'. While it is
  certainly possible to express 'Int' and 'String' in such a way (and you will
  be doing something similar in one of your training exercises) you can leave
  them as is.

  data Address = Address
    { addressStreet   :: String
    , addressNumber   :: Int
    , addressCity     :: String
    , addressCountry  :: String
    } deriving ( Eq , Show , Read )

> type Address' = () -- replace with a new type

5.3.
- Write eliminators for 'UDT'' and 'Address''.

=== CONCLUSION =================================================================

We have barely scratched the surface of what types are capable in Haskell.
During our lectures we'll mostly cover the basics, but hopefully, those of you
interested in Haskell esoterica and more theoretical details have gotten a taste
of what's hiding underneath the surface.

During the course we'll try to provide some interesting extra materials and
lectures that demonstrate how data types can be expressed as functions, how to
prove things, type level programming and other interesting topics.
