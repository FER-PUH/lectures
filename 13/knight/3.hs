import Data.Complex

type Position = (Int, Int)

moveKnight :: Position -> [Position]
moveKnight (row, col) = filter onBoard $ map makeAMove moves
  where
    makeAMove (dRow, dCol) = (row + dRow, col + dCol)
    onBoard (row, col) = row `elem` [1 .. 8] && col `elem` [1 .. 8]
    moves = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]

-- We can interpret `moveKnight` as a non-deterministic function because the
-- same input has multiple possible results (represented by a list).
-- Non-deterministic functions have the type signature `a -> [b]` (or something
-- more specific).
--
-- In this case, both `a` and `b` are `Position`.

-- Task 1: Implement a function that checks whether a knight can reach a
-- destination in 3 moves. The first argument is the start position, the second
-- argument is the end position.
canReachIn3 :: Position -> Position -> Bool
canReachIn3 start end = end `elem` thirdMove
  where
    firstMove = moveKnight start
    secondMove = concatMap moveKnight firstMove
    thirdMove = concatMap moveKnight secondMove

-- Compositing non-deterministic functions is pretty cumbersome.
--
-- Task 2: Figure out the type signature and implement the `|>` opeartor. It
-- should give us a clean way to compose non-deterministic functions from left
-- to right.
-- We want it to bind to the left and as loosely as possible (i.e. it should
-- have the lowest precedence) to avoid having to use parentheses.
infixl 1 |>

(|>) :: [a] -> (a -> [b]) -> [b]
x |> f = concatMap f x

-- Task 3: Implement `canReachIn3` using the `|>` operator.
canReachIn3' :: Position -> Position -> Bool
canReachIn3' start end =
  end `elem` (moveKnight start |> moveKnight |> moveKnight)

-- Now we want to know which positions we can reach if we advance the knight
-- one field upwards after each move (i.e., as it were a pawn, but ignoring
-- special pawn moves).
moveLikeAPawn :: Position -> Position
moveLikeAPawn (row, col) = (row + 1, col)

-- To easily compose this function with `moveKnight`, we'll need to make its result
-- non-deterministic. How does it make sense to do that?
--
-- Task 4: Implement `wrap` to turn a deterministic value into a
-- non-deterministic value.
wrap :: a -> [a]
wrap = undefined

-- Task 5: Implement a function that checks whether a knight can reach a position
-- by:
--   - Performing 3 knight moves
--   - Moving like a pawn (one row upwards) after each of those moves
--
-- Use the `|>` operator and the `wrap` function.
canReachIn3WhileMovingUp :: Position -> Position -> Bool
canReachIn3WhileMovingUp = undefined

-- You can use this function to test your solution.
main :: IO ()
main = do
  print $ canReachIn3 (1, 1) (3, 2)
  print $ canReachIn3' (1, 1) (3, 2)
  print $ canReachIn3WhileMovingUp (1, 1) (3, 2)