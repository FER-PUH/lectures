type User = (String, Int) -- Imagine this is a user

isVerified :: User -> Bool
isVerified = undefined

isPayingUser :: User -> Bool
isPayingUser = undefined

isFlagged :: User -> Bool
isFlagged = undefined

isUserEligible :: User -> Bool
isUserEligible user = and $ map ($ user) eligibilityChecks
  where
    eligibilityChecks =
      [ isVerified,
        isPayingUser,
        not . isFlagged
      ]

type Image = () -- Imagine this is a type for an image

blackAndWhite :: Image -> Image
blackAndWhite = undefined

gingham :: Image -> Image
gingham = undefined

juno :: Image -> Image
juno = undefined

lofi :: Image -> Image
lofi = undefined

imageFilters :: [Image -> Image]
imageFilters =
  [ blackAndWhite,
    gingham,
    juno,
    lofi
  ]

getFilteredVersions :: Image -> [Image]
getFilteredVersions image = map ($ image) imageFilters
