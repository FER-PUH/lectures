import Data.List hiding ( insert )

{- EXERCISE 01 -}

data List a = Null | Cons a ( List a )
  deriving ( Eq , Ord , Show , Read )

-- listHead :: List a -> Maybe a

-- listFmap :: ( a -> b ) -> List a -> List b

{- EXERCISE 02 -}
data Tree a = Leaf | Node a ( Tree a ) ( Tree a )
  deriving ( Show )

-- empty :: Tree a

-- insert :: Ord a => a -> Tree a -> Tree a

-- toList :: Tree a -> [ a ]

-- sortList :: Ord a => [ a ] -> [ a ]

{- EXERCISE 03 -}

data Weekday =
  Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday
  deriving (Show,Enum)


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
