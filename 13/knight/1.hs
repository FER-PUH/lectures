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
canReachIn3 = undefined

-- You can use this function to test your solution.
main :: IO ()
main = do
  print $ canReachIn3 (1, 1) (3, 2)