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
serve = scotty 80 $ do
  get "/deposit" $ performUpdateOperation Deposit
  get "/withdraw" $ performUpdateOperation Withdraw
  get "/balance" queryBalance

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
    ("", Nothing) -> text "Name is empty and amount is invalid"
    (_, Nothing) -> text $ pack $ "Invalid amount: " ++ amountStr
    ("", _) -> text $ pack "Name is empty"
    (name, Just amount) -> do
      let command = update name amount
      result <- liftIO $ processCommand command
      log result
      text $ pack $ result ++ "\n"

log :: String -> ActionM ()
log message = liftIO $ do
  timestamp <- takeWhile (/= '.') . show <$> getCurrentTime
  putStrLn $ '[' : timestamp ++ "] " ++ message
