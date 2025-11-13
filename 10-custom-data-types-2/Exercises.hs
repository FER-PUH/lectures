module Exercises where

import Data.List (intercalate, nub, sort)

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


data List a = Empty | Cons a (List a)
  deriving (Eq, Ord, Show, Read)

-- 2.1
listHead :: List a -> Maybe a
listHead = undefined

-- 2.2
listFmap :: (a -> b) -> List a -> List b
listFmap = undefined


data Tree a = Null | Node a (Tree a) (Tree a)
  deriving (Show, Eq)

-- 3.1
treeMax :: Ord a => Tree a -> Maybe a
treeMax = undefined

-- 3.2
treeToList :: Tree a -> [a]
treeToList = undefined

-- 3.3
levelCut :: Int -> Tree a -> Tree a
levelCut = undefined


-- 4.1
treeInsert :: Ord a => a -> Tree a -> Tree a
treeInsert = undefined

listToTree :: Ord a => [a] -> Tree a
listToTree = undefined

-- 4.2
sortAndNub :: Ord a => [a] -> [a]
sortAndNub = undefined


data Artist = Artist
  { artistId :: Int
  , artistName :: String
  , collabs :: [Artist]
  } deriving (Eq, Ord, Read)

-- 5.1
instance Show Artist where
  show = undefined


-- 6.1
-- Make sure to remove the deriving Eq from the List definition above
-- and then implement the Eq instance manually.

-- instance Eq a => Eq (List a) where
--   (==) = undefined
