import Data.List (length)

-- Try compiling with ghc
-- ghc evaluate.hs -o normal
-- ghc -O evaluate.hs -o optimized
-- ./normal
-- ./optimizied
main = do
  putStrLn "Creating l"
  let l = [1 .. 120000000]
  putStrLn "l created"

  print $ length l
  print $ length l
  print $ length l

  putStrLn "Creating g"
  let g = [1 .. 120000000]
  putStrLn "g created"

  print $ length g
  print $ length g

  putStrLn "Saving length of g"
  let len = length g
  print len
  print len
  print len
  print len
  print len
  print len

-- ghc evaluate.hs -o normal
-- ghc -O evaluate.hs -o optimized
