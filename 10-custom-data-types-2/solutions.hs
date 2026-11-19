module Exercises where

import Data.List (intercalate, nub, sort)



-- EXERCISE 1 --

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
getAlbumTitle song = case album song of
    Nothing -> Nothing
    Just album -> Just $ albumTitle album

-- 1.2
getReleaseYear :: Song -> Maybe Int
getReleaseYear song = case album song of
    Nothing -> Nothing
    Just album -> Just $ releaseYear album





-- EXERCISE 2 --

data List a = Empty | Cons a (List a)
  deriving (Ord, Show, Read)


-- 2.1
listHead :: List a -> Maybe a
listHead Empty = Nothing
listHead (x `Cons` _) = Just x

-- 2.3
listElem :: Eq a => a -> List a -> Bool
listElem _ Empty = False
listElem x (y ` Cons` ys) = x == y || listElem x ys

-- 2.4
listMap :: (a -> b) -> List a -> List b
listMap _ Empty = Empty
listMap f (x `Cons` xs) = f x `Cons` listMap f xs





-- EXERCISE 3 --

data Tree a = Null | Node a (Tree a) (Tree a)
  deriving (Show, Eq)


-- 3.1
treeElem :: Eq a => a -> Tree a -> Bool
treeElem _ Null = False
treeElem x (Node current left right) = x == current || treeElem x left || treeElem x right


-- 3.2
treeToList :: Tree a -> [a]
treeToList Null = []
treeToList (Node current left right) = treeToList left ++ [current] ++ treeToList right


treeToList' :: Tree a -> [a]
treeToList' Null = []
treeToList' (Node current left right) = treeToList' left ++ current : treeToList' right








-- EXERCISE 4 --

-- 4.1
sortedTreeInsert :: Ord a => a -> Tree a -> Tree a
sortedTreeInsert x Null = Node x Null Null
sortedTreeInsert x tree@(Node current left right)
  | x < current = Node current (sortedTreeInsert x left) right
  | current < x = Node current left (sortedTreeInsert x right)
  | otherwise = tree

-- 4.2
sortedTreeElem :: Ord a => a -> Tree a -> Bool
sortedTreeElem _ Null = False
sortedTreeElem x (Node current left right)
  | x < current = sortedTreeElem x left
  | current < x = sortedTreeElem x right
  | otherwise = True

-- 4.3
listToSortedTree :: Ord a => [a] -> Tree a
listToSortedTree = foldr sortedTreeInsert Null

-- 4.4
sortAndNub :: Ord a => [a] -> [a]
sortAndNub = treeToList . listToSortedTree



-- EXERCISE 5 --

-- Artist examples:
queen = Artist {artistId = 0, artistName = "Queen", collabs = [bowie]}
bowie = Artist {artistId = 1, artistName = "Bowie", collabs = [queen, mercury]}
mercury = Artist {artistId = 2, artistName = "Mercury", collabs = []}
mcCartney = Artist {artistId = 3, artistName = "McCartney", collabs = [lennon, jackson]}
lennon = Artist {artistId = 4, artistName = "Lennon", collabs = [mcCartney]}
jackson = Artist {artistId = 5, artistName = "Jackson", collabs = []}

-- Definition:
data Artist = Artist
  { artistId :: Int
  , artistName :: String
  , collabs :: [Artist]
  } deriving (Eq, Ord, Read)

-- 5.1
instance Show Artist where
  show Artist { artistId, artistName = name, collabs } =
    "Artist { " ++ idSetter ++ ", " ++ nameSetter ++ ", " ++ collabsSetter ++ " }"
    where
      idSetter = "artistId = " ++ show artistId
      nameSetter = "artistName = " ++ show name
      collabsSetter = "collabs = [" ++ intercalate ", " (map artistName collabs) ++ "]"



-- EXERCISE 6 --

-- 6.1
instance Eq a => Eq (List a) where
  Empty == Empty = True
  (x `Cons` xs) == (y `Cons` ys) = x == y && xs == ys