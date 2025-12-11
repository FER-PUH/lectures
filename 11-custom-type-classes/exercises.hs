import Data.List
import qualified Data.Map as M
import qualified Data.Set as S

data Sex = Male | Female deriving (Show, Read, Eq, Ord)

data Person = Person
  { idNumber :: String,
    forename :: String,
    surname :: String,
    sex :: Sex,
    age :: Int,
    partner :: Maybe Person,
    children :: [Person]
  }
  deriving (Show, Read, Eq, Ord)

class Ageing a where
  currentAge :: a -> Int
  maxAge :: a -> Int
  makeOlder :: a -> a

instance Ageing Person where
  currentAge = age
  makeOlder p = p {age = age p + 1}
  maxAge _ = 123

data Breed = Beagle | Husky | Pekingese deriving (Eq, Ord, Show, Read)

data Dog = Dog
  { dogName :: String,
    dogBreed :: Breed,
    dogAge :: Int
  }
  deriving (Eq, Ord, Show, Read)

instance Ageing Dog where
  currentAge = dogAge
  makeOlder d = d {dogAge = dogAge d + 1}
  maxAge d = case dogBreed d of
    Husky -> 29
    _ -> 20

-- Exercises 1

{-
1.1.
- Define a function
    compareRelativeAge :: (Ageing a, Ageing b) => a -> b -> Ordering 
  that compares the ages relative to the maximum age, so that, say, a 10-year
  old dog is considered older than a 20-year old human.
-}
compareRelativeAge :: (Ageing a, Ageing b) => a -> b -> Ordering
compareRelativeAge = undefined

john =
  Person
    { idNumber = "123",
      forename = "John",
      surname = "Doyle",
      sex = Male,
      age = 30,
      partner = Nothing,
      children = []
    }

fido =
  Dog
    { dogName = "fido",
      dogBreed = Husky,
      dogAge = 25
    }

{-
1.2.
- Define a class 'Nameable' with function
    name :: a -> String
  Define 'Person' and 'Dog' as instances of this class. For a person, return
  "<Name> <Surname>", while for a dog return "<Name> the Dog".
-}


-- Exercises 2

data Tree a = Null | Node a (Tree a) (Tree a) deriving (Show, Eq)

{-
2.1.
- Define a 'Takeable' class with a function
    takeSome :: Int -> t a -> [a]
- Define '[]' and 'Tree' as instances of 'Takeable'. Take elements from the
  tree using in-order traversal.
-}


{-
2.2.
- Define a 'Headed' class with functions
    headOf  :: t a -> a      -- takes the head of the structure
    headOff :: t a -> t a    -- removes the head and returns the rest
- Define '[]', 'Tree', and 'Maybe' as instances of this type class.
  (The head of 'Maybe' type is the value wrapped into 'Just', while the rest is
  'Nothing'.)
-}


-- Exercises 3

instance Functor Tree where
  fmap _ Null = Null
  fmap f (Node x l r) = Node (f x) (fmap f l) (fmap f r)

{-
3.1.
- Using 'fmap' define 'mapOnTreeMaybe' that will apply 'f' to each element of
  a tree of the 'Tree (Maybe a)' type. For example:
    tr = Node (Just 1) (Node (Just 2) Null Null) (Node Nothing Null Null)
    mapOnTreeMaybe (+1) tr =>
    Node (Just 2) (Node (Just 3) Null Null) (Node Nothing Null Null)
-}
mapOnTreeMaybe :: (a -> b) -> Tree (Maybe a) -> Tree (Maybe b)
mapOnTreeMaybe = undefined

{-
3.2.
- Define a 'RoseTree' type for trees in which each node can have a number of
  subtrees (a forest). As data constructors, use 'RoseTree' and 'RoseEmpty'.
- Make this type an instance of the 'Functor' class.
-}


-- Exercises 4

{-
4.1.
- Using 'foldr' from 'Foldable' class define a function
    sumPositive :: (Foldable t, Num a, Ord a) => t a -> a
  that sums the positive elements in a structure of a 't a' type.
-}
sumPositive :: (Foldable t, Num a, Ord a) => t a -> a
sumPositive = undefined

{-
4.2.
- Using 'foldr' define a function 'size' that returns the size of any structure
  whose type is 'Foldable':
    size :: Foldable t => t a -> Int
    size intTree   => 3
    size [1,5..99] => 25
    size (Just 5)  => 1
-}
size :: Foldable t => t a -> Int
size = undefined

{-
4.3.
- Define a function 'eqElems' that tests whether all elements of a structure 
 't a' are equal to each other.
    eqElems :: (Foldable t, Eq a) => t a -> Bool
-}
eqElems :: (Foldable t, Eq a) => t a -> Bool
eqElems = undefined

{-
4.4.
- Define a 'Foldable' instance for 'RoseTree'.
-}


-- Exercises 5

{-
5.1.
- Define a function for turning any 'Foldable' type into a 'Set' type:
    toSet :: (Foldable t, Ord a) => t a -> S.Set a
-}
toSet :: (Foldable t, Ord a) => t a -> S.Set a
toSet = undefined

{-
5.2.
- Define a function 'indexWords' that indexes the positions of words in a text
  and returns an index (a dictionary). The keys are the words, while the values
  are the list of indices (positions at which the word appears in text).
    indexWords :: String -> M.Map String [Int]
    indexWords "to be or not to be" => 
    fromList [("be",[1,5]),("not",[3]),("or",[2]),("to",[0,4])]
  (Hint: use 'insertWith'.)
-}
indexWords :: String -> M.Map String [Int]
indexWords = undefined