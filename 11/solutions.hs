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

-- Exercise 1
compareRelativeAge :: (Ageing a, Ageing b) => a -> b -> Ordering
compareRelativeAge x y = compare (currentAge x `ratio` maxAge x) (currentAge y `ratio` maxAge y)
  where
    ratio :: Int -> Int -> Float
    ratio a b = fromIntegral a / fromIntegral b

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

-- 1.2
class Nameable a where
  name :: a -> String

instance Nameable Person where
  name p = forename p ++ " " ++ surname p

instance Nameable Dog where
  name d = dogName d ++ " the Dog"

-- Exercise 2

data Tree a = Null | Node a (Tree a) (Tree a) deriving (Show, Eq)

-- 2.1
class Takeable t where
  takeSome :: Int -> t a -> [a]

instance Takeable [] where
  takeSome = take

instance Takeable Tree where
  takeSome n t = take n $ treeToListInOrder t

treeToListInOrder :: Tree a -> [a]
treeToListInOrder Null = []
treeToListInOrder (Node x l r) = treeToListInOrder l ++ [x] ++ treeToListInOrder r

-- 2.2
class Headed t where
  headOf :: t a -> a -- takes the head of the structure
  headOff :: t a -> t a -- removes the head and returns the rest

instance Headed [] where
  headOf = head
  headOff = tail

instance Headed Tree where
  headOf Null = error "no head"
  headOf (Node a _ _) = a

  headOff Null = Null
  headOff (Node a l _) = l

instance Headed Maybe where
  headOf (Just a) = a
  headOf Nothing = error "got nothing"

  headOff _ = Nothing

-- Exercise 3

instance Functor Tree where
  fmap _ Null = Null
  fmap f (Node x l r) = Node (f x) (fmap f l) (fmap f r)

-- 3.1.
mapOnTreeMaybe :: (a -> b) -> Tree (Maybe a) -> Tree (Maybe b)
-- mapOnTreeMaybe f tr = fmap (fmap f) tr
-- mapOnTreeMaybe f = fmap $ fmap f
mapOnTreeMaybe = fmap . fmap

-- mapOnTreeMaybe = fmap <$> fmap -- To extra confuse students

-- 3.2.
data RoseTree a = RoseEmpty | RoseTree a [RoseTree a]

instance Functor RoseTree where
  fmap f RoseEmpty = RoseEmpty
  fmap f (RoseTree a trees) = RoseTree (f a) (map (fmap f) trees)

-- Exercise 4

-- 4.1.
sumPositive :: (Foldable t, Num a, Ord a) => t a -> a
sumPositive = foldr (\t acc -> if t > 0 then acc + t else acc) 0

-- 4.2.
size :: Foldable t => t a -> Int
size = foldr (\_ acc -> acc + 1) 0

-- 4.3.
eqElems :: (Foldable t, Eq a) => t a -> Bool
eqElems ts = all (== head asList) asList
  where
    asList = foldr (:) [] ts

-- 4.4
instance Foldable RoseTree where
  foldr f z RoseEmpty = z
  foldr f z (RoseTree t subtrees) = f t (foldr (\st acc -> foldr f acc st) z subtrees)

-- Exercise 5

-- 5.1.
toSet :: (Foldable t, Ord a) => t a -> S.Set a
toSet = foldr S.insert S.empty

-- 5.2.
indexWords :: String -> M.Map String [Int]
indexWords sentence = foldl' insertIntoMap M.empty indexedWords
  where
    indexedWords = zip [0 ..] (words sentence)
    insertIntoMap m (idx, word) = M.insertWith (flip (++)) word [idx] m