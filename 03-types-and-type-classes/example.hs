isStrongPassword password = length password > 12

ratePassword password
  | isStrongPassword password = password ++ " is pretty strong!"
  | otherwise = password ++ " is horrible."

main = do
  putStrLn $ ratePassword "AsStrongAsItGets"
  putStrLn $ ratePassword "ninja"
