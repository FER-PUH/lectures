{-# LANGUAGE OverloadedStrings #-}

module Server where

import Core
import Data.Text.Lazy (pack)
import Data.Time.Clock (getCurrentTime)
import Numeric.Natural
import Text.Read (readMaybe)
import Web.Scotty
import Web.Scotty.Trans (ActionT)
import Prelude hiding (log)

serve :: IO ()
serve = scotty 3000 $ do
  get "/balance" queryBalance
  get "/deposit" $ performUpdateOperation Deposit
  get "/withdraw" $ performUpdateOperation Withdraw

queryBalance :: ActionM ()
queryBalance = do
  nameStr <- queryParam "name" :: ActionM String

  case nameStr of
    "" -> text "You must specify an account name."
    name -> do
      result <- liftIO $ processCommand $ ShowBalance name
      log result
      text $ pack result

performUpdateOperation :: (String -> Natural -> Command) -> ActionT IO ()
performUpdateOperation update = do
  nameStr <- queryParam "name" :: ActionM String
  amountStr <- queryParam "amount"

  case (nameStr, readMaybe amountStr) of
    ("", Nothing) ->
      respondWithText $ "The name is empty and the amount is not a valid number: " ++ amountStr
    (_, Nothing) ->
      respondWithText $ "The amount is not a valid number: " ++ amountStr
    ("", _) -> respondWithText "The name is empty"
    (name, Just amount) -> do
      let command = update name amount
      result <- liftIO $ processCommand command
      log result
      respondWithText result
  where
    respondWithText = text . pack

log :: String -> ActionM ()
log message = liftIO $ do
  timestamp <- takeWhile (/= '.') . show <$> getCurrentTime
  putStrLn $ "[" ++ timestamp ++ "] " ++ message
