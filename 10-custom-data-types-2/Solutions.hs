module Solutions where

import Data.List (intercalate)

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
getAlbumTitle s = case album s of
  Just a  -> Just $ albumTitle a
  Nothing -> Nothing

-- Alternative using fmap:
getAlbumTitle' :: Song -> Maybe String
getAlbumTitle' = fmap albumTitle . album

-- 1.2
getReleaseYear :: Song -> Maybe Int
getReleaseYear s = case album s of
  Just a  -> Just $ releaseYear a
  Nothing -> Nothing

-- Alternative using fmap:
getReleaseYear' :: Song -> Maybe Int
getReleaseYear' = fmap releaseYear . album


data List a = Empty | Cons a (List a)
  deriving (Ord, Show, Read)

-- 2.1
listHead :: List a -> Maybe a
listHead Empty = Nothing
listHead (Cons x _) = Just x

-- 2.2
listFmap :: (a -> b) -> List a -> List b
listFmap _ Empty = Empty
listFmap f (Cons x xs) = Cons (f x) (listFmap f xs)


data Tree a = Null | Node a (Tree a) (Tree a)
  deriving (Show, Eq)

-- 3.1
treeMax :: Ord a => Tree a -> Maybe a
treeMax Null = Nothing
treeMax (Node x ltree rtree) = maximum [Just x, treeMax ltree, treeMax rtree]

-- 3.2
treeToList :: Tree a -> [a]
treeToList Null = []
treeToList (Node x left right) = treeToList left ++ [x] ++ treeToList right

-- 3.3
levelCut :: Int -> Tree a -> Tree a
levelCut _ Null = Null
levelCut 0 _ = Null
levelCut n (Node x left right) = Node x (levelCut (n-1) left) (levelCut (n-1) right)


-- 4.1
treeInsert :: Ord a => a -> Tree a -> Tree a
treeInsert x Null = Node x Null Null
treeInsert x tree@(Node y ltree rtree)
  | x < y     = Node y (treeInsert x ltree) rtree
  | x > y     = Node y ltree (treeInsert x rtree)
  | otherwise = tree

listToTree :: Ord a => [a] -> Tree a
listToTree = foldr treeInsert Null

-- 4.2
sortAndNub :: Ord a => [a] -> [a]
sortAndNub = treeToList . listToTree


data Artist = Artist
  { artistId :: Int
  , artistName :: String
  , collabs :: [Artist]
  } deriving (Eq, Ord, Read)

-- 5.1
instance Show Artist where
  show (Artist aid name collab) =
    "Artist {artistId = " ++ show aid ++
    ", artistName = " ++ show name ++
    ", collabs = [" ++ intercalate ", " (map artistName collab) ++ "]}"


-- 6.1
instance Eq a => Eq (List a) where
  Empty == Empty = True
  (Cons x _) == (Cons y _) = x == y
  _ == _ = False
