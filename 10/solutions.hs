import Data.List hiding ( insert )

{- PRELUDE -}

{- EXERCISE 01 -}

data List a = Null | Cons a ( List a )
  deriving ( Ord , Show , Read )

listHead :: List a -> Maybe a
listHead Null = Nothing
listHead ( Cons h _ ) = Just h

listFmap :: ( a -> b ) -> List a -> List b
listFmap _ Null = Null
listFmap f ( Cons a as ) = Cons ( f a ) $ listFmap f as

{- EXERCISE 02 -}
data Tree a = Leaf | Node a ( Tree a ) ( Tree a )
  deriving ( Show )

empty :: Tree a
empty = Leaf

insert :: Ord a => a -> Tree a -> Tree a
insert a Leaf = Node a Leaf Leaf
insert a ( Node n l r )
  | a < n = Node n ( insert a l ) r
  | otherwise = Node n l ( insert a r )

toList :: Tree a -> [ a ]
toList Leaf = []
toList ( Node n l r ) = toList l ++ [ n ] ++ toList r

sortList :: Ord a => [ a ] -> [ a ]
sortList = toList . foldr insert empty

{- EXERCISE 03 -}

data Weekday =
  Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday
  deriving (Show,Enum)

instance Eq Weekday where
  Saturday == _ = False
  Sunday == _ = False
  _ == Saturday = False
  _ == Sunday = False
  _ == _ = True

data Person = Person
  { pid :: Int
  , name :: String
  , friends :: [ Person ]
  } deriving ( Eq , Ord , Read )

ana    = Person 0 "Ana"    [ mateja ]
luka   = Person 1 "Luka"   [ marko , mateja ]
marko  = Person 2 "Marko"  []
matija = Person 3 "Matija" [ ana , luka ]
mateja = Person 4 "Mateja" [ ana ]
petar  = Person 5 "Petar"  []

instance Show Person where
  show ( Person i n fs ) = concat
    [ "data Person { pid = " , show i
    , ", name = " , show n
    , ", friends = ["
    , intercalate ", " ( fmap (show . name) fs )
    , "]" ]


{- EXERCISE 04 -}

instance Eq a => Eq ( List a ) where
  Null == Null = True
  Cons a _ == Cons b _ = a == b
  _ == _ = False

instance Eq a => Eq ( Tree a ) where
  tas == tbs = let as = toList tas ; bs = toList tbs in and
    [ all ( `elem` bs ) as
    , all ( `elem` as ) bs
    ]
