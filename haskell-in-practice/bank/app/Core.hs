module Core where

import Control.DeepSeq (deepseq)
import Data.List (intercalate)
import qualified Data.Map as M
import Data.Maybe (fromMaybe)
import Numeric.Natural
import System.Directory (doesFileExist)

type AccountName = String

type Amount = Natural

type Accounts = M.Map AccountName Amount

data Command
  = Deposit AccountName Amount
  | Withdraw AccountName Amount
  | ShowBalance AccountName
  | ShowAccounts

getBalance :: AccountName -> Accounts -> Amount
getBalance name = fromMaybe 0 . M.lookup name

processCommand :: Command -> IO String
processCommand command = do
  accounts <- loadAccounts
  case command of
    ShowBalance name ->
      return $ name ++ "'s balance is " ++ show (getBalance name accounts)
    ShowAccounts -> return $ showAccounts accounts
    Deposit name amount ->
      saveAccounts (deposit name amount accounts)
        >> return (name ++ " deposited " ++ show amount)
    Withdraw name amount -> case withdraw name amount accounts of
      Right updatedAccounts ->
        saveAccounts updatedAccounts
          >> return (name ++ " withdrew " ++ show amount)
      Left err -> return err

accountsFile :: String
accountsFile = "accounts.txt"

saveAccounts :: Accounts -> IO ()
saveAccounts accounts = do
  content <- writeFile accountsFile (show accounts)
  content `deepseq` return content

loadAccounts :: IO Accounts
loadAccounts = do
  exists <- doesFileExist accountsFile
  if exists
    then do
      contents <- fmap read (readFile accountsFile)
      contents `deepseq` return contents
    else return M.empty

withdraw :: AccountName -> Amount -> Accounts -> Either String Accounts
withdraw name amount accounts
  | currentBalance < amount = Left "Not enough money in the accounts"
  | otherwise = Right $ M.insert name (currentBalance - amount) accounts
  where
    currentBalance = getBalance name accounts

deposit :: AccountName -> Amount -> Accounts -> Accounts
deposit name amount accounts =
  M.insert name (currentBalance + amount) accounts
  where
    currentBalance = getBalance name accounts

showAccounts :: Accounts -> String
showAccounts accounts =
  unlines
    [title, delimiter, accountList, delimiter]
  where
    accountList = intercalate "\n" . map showAccount $ M.toList accounts
    title = "      Accounts      "
    delimiter = replicate 20 '='
    showAccount (name, amount) = name ++ ": " ++ show amount
