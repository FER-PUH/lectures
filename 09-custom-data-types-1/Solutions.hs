module Solutions where

{- * EXERCISE 1 ---------------------------------------------------------------}

data RGB = Red | Green | Blue
  deriving ( Eq , Show , Read )

{-
  1.1.
  - Write an eliminator for our RGB data type (write the type signature first).
-}
rgb :: a -> a -> a -> RGB -> a
rgb a b c rgb = case rgb of
  Red   -> a
  Green -> b
  Blue  -> c


{-
  1.2.
  - Implement the 'showRGB' function in terms of the 'rgb' eliminator.
-}

showRGB :: RGB -> String
showRGB = rgb "Red" "Green" "Blue"


{- * EXERCISE 2 ---------------------------------------------------------------}

data Color = Color RGB RGB RGB
  deriving ( Eq , Show , Read )

cex1 :: Color
cex1 = Color Red Red Red

cex2 :: Color
cex2 = Color Red Red Green

{-
  2.1
  - What should be the type for the 'Color' eliminator?
-}

color :: ( RGB -> RGB -> RGB -> a ) -> Color -> a

{-
  2.2
  - Implement the 'Color' eliminator 'color'.
-}

color f ( Color a b c ) = f a b c

{-
  2.3
  - Implement the get and set functions in terms of the 'color' eliminator.
-}

getC1 :: Color -> RGB
getC1 = color ( \ a _ _ -> a )

getC2 :: Color -> RGB
getC2 = color ( \ _ b _ -> b )

getC3 :: Color -> RGB
getC3 = color ( \ _ _ c -> c )

setC1 :: Color -> RGB -> Color
setC1 col a = color ( \ _ b c -> Color a b c ) col

setC2 :: Color -> RGB -> Color
setC2 col b = color ( \ a _ c -> Color a b c ) col

setC3 :: Color -> RGB -> Color
setC3 col c = color ( \ a b _ -> Color a b c ) col


{- * EXERCISE 3 ---------------------------------------------------------------}

data EUR = EUR Float
  deriving ( Eq , Show , Read )

data Address = Address
  { addressStreet   :: String
  , addressNumber   :: Int
  , addressCity     :: String
  , addressCountry  :: String
  } deriving ( Eq , Show , Read )

data User = User
  { userUUID      :: Int
  , userName      :: String
  , userSurname   :: String
  , userAddress   :: Address
  , userAccounts  :: [ Account ]
  } deriving ( Eq , Show , Read )

data Account = Account
  { accountUUID     :: Int
  , accountBalance  :: EUR
  } deriving ( Eq , Show , Read )

acc01 :: Account
acc01 = Account 5 ( EUR 50000 )

acc02 :: Account
acc02 = Account { accountUUID = 3 , accountBalance = EUR (-6820) }

adr01 :: Address
adr01 = Address
  { addressStreet   = "Unska"
  , addressNumber   = 3
  , addressCity     = "Zagreb"
  , addressCountry  = "Hrvatska"
  }

usr01 :: User
usr01 = User
  { userUUID = 10
  , userName = "Tony"
  , userSurname = "Hawk"
  , userAddress = adr01
  , userAccounts = [ acc01 , acc02 ]
  }

usr02 :: User
usr02 = usr01
  { userName = "Jhonny"
  , userAddress = ( userAddress usr01 )
    { addressStreet = "Mate Balote"
    , addressCity = "Rovinj"
    }
  }

{-
3.1
- Using function composition, write a function that returns a total of all
  'User' 'Account's.
-}

accountsTotal :: User -> Float
accountsTotal = sum . map ( ( \ ( EUR e ) -> e ) . accountBalance ) . userAccounts


{- * EXERCISE 4 ---------------------------------------------------------------}

{-
  4.1
  - Define a safe head using 'Maybe'
-}

safeHead :: [ a ] -> Maybe a
safeHead [] = Nothing
safeHead ( x : _ ) = Just x

{-
  4.2
  - Define a function that takes in two lists of numbers and returns either an
    error message if either one of them is empty, or a sum of the first two
    elements.
-}

elaborateSum :: Num a => [ a ] -> [ a ] -> Either String a
elaborateSum [] [] = Left "Both lists are empty"
elaborateSum []  _ = Left "Left list is empty"
elaborateSum _  [] = Left "Right list is empty"
elaborateSum (x:_) (y:_) = Right $ x + y


{- * EXERCISE 5 ---------------------------------------------------------------}

data UDT = Uno | Dos | Tres

{-
5.1.
- Let's remember our 'UDT' type from the beginning:
  Write the UDT type in terms of 'Either' and unit / '()'
-}

type UDT' = Either () ( Either () () )

{-
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
-}

type Address' = ( String , ( Int , ( String , String ) ) )

{-
  5.3.
  - Write eliminators for 'UDT'' and 'Address''.
-}
udt' :: a -> a -> a -> UDT' -> a
udt' a b c u = case u of
  ( Left _ ) -> a
  ( Right ( Left _ ) ) -> b
  ( Right ( Right _ ) ) -> c


address' :: ( String -> Int -> String -> String -> a ) -> Address' -> a
address' f ( street , ( number , ( city , country ) ) )
  = f street number city country
