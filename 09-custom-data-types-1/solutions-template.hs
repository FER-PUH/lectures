{-# OPTIONS_GHC -Wincomplete-patterns #-}


-- EXERCISE 1

data Point = Point Double Double
    deriving (Show)
data Shape2 = Circle2 Point Double | Rectangle2 Point Point
    deriving (Show)

-- 1.1.
showDate = undefined

-- 1.2.
translate :: Point -> Shape2 -> Shape2
translate = undefined

-- 1.3.
inShape :: Point -> Shape2 -> Bool
inShape = undefined

inShapes :: Point -> [Shape2] -> Bool
inShapes = undefined

-- 1.4.
totalHorsepower = undefined



-- EXERCISE 2

data Level = Bachelor | Master | PhD deriving (Show, Eq)
data Student = Student
    { firstName :: String
    , lastName :: String
    , studentId :: String
    , level :: Level
    , avgGrade :: Double
    }
    deriving (Show)

-- 2.1.
improveStudent :: Student -> Student
improveStudent = undefined

-- 2.2.
avgGradePerLevels :: [Student] -> (Double, Double, Double)
avgGradePerLevels = undefined

-- 2.3.
rankedStudents :: Level -> [Student] -> [String]
rankedStudents = undefined

-- 2.4.
addStudent :: Student -> [Student] -> [Student]
addStudent = undefined



-- EXERCISE 3

data Employee = Employee
    { name :: String
    , salary :: Maybe Double
    }
    deriving (Show)

-- 3.1.
toTriplet = undefined

-- 3.2.
totalSalaries :: [Employee] -> Double
totalSalaries = undefined

-- 3.3.
addStudent2 :: Student -> [Student] -> Maybe [Student]
addStudent2 = undefined