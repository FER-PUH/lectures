-- Tail-recursive version:

tailMaximum1 :: (Ord a, Num a) => [a] -> a
tailMaximum1 [] = error "empty list"
tailMaximum1 list = maximum list 0
  where
    maximum [] maxSoFar = maxSoFar
    maximum (current : rest) maxSoFar = maximum rest (max current maxSoFar)

-- There's actually no need to limit ourselves to the 'Num' typeclass here, so
-- let's give a slightly more generic definition:

tailMaximum2 :: (Ord a, Bounded a) => [a] -> a
tailMaximum2 [] = error "empty list"
tailMaximum2 list = maximum list minBound
  where
    maximum [] maxSoFar = maxSoFar
    maximum (current : rest) maxSoFar = maximum rest (max current maxSoFar)

-- Finally, an the best definition avoids using a bound altogether:

tailMaximum3 :: (Ord a) => [a] -> a
tailMaximum3 [] = error "empty list"
tailMaximum3 (first : rest) = maximum rest first
  where
    maximum [] maxSoFar = maxSoFar
    maximum (current : rest) maxSoFar = maximum rest (max current maxSoFar)

tailMaximumStrict :: (Ord a) => [a] -> a
tailMaximumStrict [] = error "empty list"
tailMaximumStrict (first : rest) = maximum rest first
  where
    maximum [] maxSoFar = maxSoFar
    maximum (current : rest) maxSoFar = maximum rest $! max current maxSoFar
