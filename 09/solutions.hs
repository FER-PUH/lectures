data Point = Point Double Double
    deriving (Show)
data Shape2 = Circle2 Point Double | Rectangle2 Point Point
    deriving (Show)

data Level = Bachelor | Master | PhD deriving (Show, Eq)
data Student = Student
    { firstName :: String
    , lastName :: String
    , studentId :: String
    , level :: Level
    , avgGrade :: Double
    }
    deriving (Show)

data Employee = Employee
    { name :: String
    , salary :: Maybe Double
    }
    deriving (Show)
