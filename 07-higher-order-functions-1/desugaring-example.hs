-- ghc -ddump-ds -O1 desugaring-example.hs
add :: Num a => a -> a -> a
add x y = x + y


-- we will explain `main` later in the course
main = do
  print (add 3 4)
