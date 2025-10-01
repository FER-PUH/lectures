concat3 s1 s2 s3 = s1 ++ (if length s2 < 2 then "" else s2) ++ s3

wish firstName lastName age
  | age >= 50 = "Happy birthday, Mr. " ++ lastName
  | otherwise = "Happy birthday, " ++ firstName

wish' firstName lastName age =
  "Happy birthday, " ++ (if age >= 50 then "Mr. " ++ lastName else firstName)
