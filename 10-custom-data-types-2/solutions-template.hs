module Exercises where

import Data.List (intercalate, nub, sort)



-- EXERCISE 1 --

-- Song examples:
song1 = Song {songTitle = "Bohemian Rhapsody", duration = 354, album = Just $ Album {albumTitle = "A Night at the Opera", releaseYear = 1975, trackCount = 12}}
song2 = Song {songTitle = "Imagine", duration = 183, album = Just $ Album {albumTitle = "Imagine", releaseYear = 1971, trackCount = 10}}
song3 = Song {songTitle = "Blinding Lights", duration = 200, album = Nothing} -- a single without an album

-- Album and Song definitions:
data Album = Album
  { albumTitle :: String
  , releaseYear :: Int
  , trackCount :: Int
  } deriving (Eq, Show)

type Seconds = Int

data Song = Song
  { songTitle :: String
  , duration :: Seconds
  , album :: Maybe Album
  } deriving (Eq, Show)


-- 1.1
getAlbumTitle :: Song -> Maybe String
getAlbumTitle = undefined

-- 1.2
getReleaseYear :: Song -> Maybe Int
getReleaseYear = undefined



-- EXERCISE 2 --

-- List examples:
listSeven = Cons 7 Empty
listOne = 1 `Cons` Empty
listOneTwoThree = Cons 1 (Cons 2 (Cons 3 Empty))
listTwoOneFiveTwo = Cons 2 (Cons 1 (Cons 5 (Cons 2 Empty)))

-- List definition:
data List a = Empty | Cons a (List a)
  deriving (Eq, Ord, Show, Read)


-- 2.1
listHead :: List a -> Maybe a
listHead = undefined

-- 2.2
listElem :: Eq a => a -> List a -> Bool
listElem = undefined

-- 2.3
listMap :: (a -> b) -> List a -> List b
listMap = undefined



-- EXERCISE 3 --

-- Tree example:
treeTwoFiveOne = Node 5 (Node 2 Null Null) (Node 1 Null Null)

--                      __5__
--                     /     \
--                    2       1
--                   / \     / \
--                  ●   ●   ●   ●

-- Tree definition:
data Tree a = Null | Node a (Tree a) (Tree a)
  deriving (Show, Eq)


-- 3.1
treeElem :: Eq a => Tree a -> Bool
treeElem = undefined

-- 3.2
treeToList :: Tree a -> [a]
treeToList = undefined



-- EXERCISE 4 --

-- sorted Tree example:
treeSorted = Node 50 (Node 25 (Node 12 Null Null) Null) (Node 75 (Node 62 Null Null) (Node 88 Null Null))

--                      ______50______
--                     /              \
--                  __25__          __75__
--                 /      \        /      \
--                12       ●      62      88
--               /  \            /  \    /  \
--              ●    ●          ●    ●  ●    ●

-- 4.1
sortedTreeInsert :: Ord a => a -> Tree a -> Tree a
sortedTreeInsert = undefined

-- 4.2
sortedTreeElem :: Ord a => a -> Tree a -> Bool
sortedTreeElem = undefined

-- 4.3
listToSortedTree :: Ord a => [a] -> Tree a
listToSortedTree = undefined

-- 4.4
sortAndNub :: Ord a => [a] -> [a]
sortAndNub = undefined



-- EXERCISE 5 --

-- Artist examples:
queen = Artist {artistId = 0, artistName = "Queen", collabs = [bowie]}
bowie = Artist {artistId = 1, artistName = "Bowie", collabs = [queen, mercury]}
mercury = Artist {artistId = 2, artistName = "Mercury", collabs = []}
mcCartney = Artist {artistId = 3, artistName = "McCartney", collabs = [lennon, jackson]}
lennon = Artist {artistId = 4, artistName = "Lennon", collabs = [mcCartney]}
jackson = Artist {artistId = 5, artistName = "Jackson", collabs = []}

-- Artist definition:
data Artist = Artist
  { artistId :: Int
  , artistName :: String
  , collabs :: [Artist]
  } deriving (Eq, Ord, Read)

-- 5.1
instance Show Artist where
  show = undefined


-- EXERCISE 6 --

-- 6.1
-- Make sure to remove the deriving Eq from the List definition above
-- and then implement the Eq instance manually.

-- instance Eq a => Eq (List a) where
--   (==) = undefined