import Data.List (intercalate, sort, sortOn)
import Data.Maybe (mapMaybe)
import Data.Ord (Down (Down))

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

-- 1.1
type Year = Int
type Month = Int
type Day = Int
data Date = Date Year Month Day

showDate :: Date -> String
showDate (Date year month day) = intercalate "." $ map show [day, month, year]

-- 1.2
translate :: Point -> Shape2 -> Shape2
translate (Point x' y') (Circle2 (Point x y) r) =
    Circle2 (Point (x + x') (y + y')) r
translate (Point x' y') (Rectangle2 (Point x1 y1) (Point x2 y2)) =
    Rectangle2
        (Point (x1 + x') (y1 + y'))
        (Point (x2 + x') (y2 + y'))

-- 1.3
inShape :: Point -> Shape2 -> Bool
inShape (Point x' y') (Circle2 (Point x y) r) =
    (x' - x) ^ 2 + (y' - y) ^ 2 <= r ^ 2
inShape (Point x' y') (Rectangle2 (Point x1 y1) (Point x2 y2)) =
    let [left, right] = sort [x1, x2]
        [bottom, top] = sort [y1, y2]
     in (left <= x' && x' <= right)
            && (bottom <= y' && y' <= top)

inShapes :: Point -> [Shape2] -> Bool
inShapes point = any (point `inShape`)

-- 1.4
type Manufacturer = String
type HP = Double
data Vehicle
    = Car Manufacturer HP
    | Truck Manufacturer HP
    | Motorcycle Manufacturer HP
    | Bicycle

totalHorsepower :: [Vehicle] -> HP
totalHorsepower = sum . map horsepower

horsepower :: Vehicle -> HP
horsepower (Car _ hp) = hp
horsepower (Truck _ hp) = hp
horsepower (Motorcycle _ hp) = hp
horsepower Bicycle = 0.2

-- 2.1
improveStudent :: Student -> Student
improveStudent student@Student{avgGrade = oldAvg} =
    student{avgGrade = min (oldAvg + 1) 5}

-- 2.2
avgGradePerLevels :: [Student] -> (Double, Double, Double)
avgGradePerLevels students =
    ( avgGrades $ filter ((== Bachelor) . level) students
    , avgGrades $ filter ((== Master) . level) students
    , avgGrades $ filter ((== PhD) . level) students
    )

avgGrades :: [Student] -> Double
avgGrades = average . map avgGrade

average :: (Fractional a) => [a] -> a
average xs = sum xs / fromIntegral (length xs)

-- 2.3
rankedStudents :: Level -> [Student] -> [String]
rankedStudents level' = map studentId . sortOn (Down . avgGrade) . filter ((== level') . level)

-- 2.4
addStudent :: Student -> [Student] -> [Student]
addStudent student@Student{studentId = id} students
    | id `elem` map studentId students = error "Student already exists"
    | otherwise = student : students

-- 3.1
data MyTriplet a b c = MyTriplet {first :: a, second :: b, third :: c}

toTriplet :: MyTriplet a b c -> (a, b, c)
toTriplet MyTriplet{first, second, third} = (first, second, third)

-- 3.2
totalSalaries :: [Employee] -> Double
totalSalaries = sum . mapMaybe salary

-- 3.3.
addStudent2 :: Student -> [Student] -> Maybe [Student]
addStudent2 student@Student{studentId = id} students
    | id `elem` map studentId students = Nothing
    | otherwise = Just $ student : students

addStudent3 :: Student -> [Student] -> Either String [Student]
addStudent3 student@Student{studentId = id} students
    | id `elem` map studentId students = Left "Student Already exists"
    | otherwise = Right $ student : students
