module Core where

-- In production code, we'd only export Command and processCommand
-- to encapsualte our implementation.

import Control.DeepSeq (deepseq)
import Data.List (intercalate)
import qualified Data.Map as M
import Data.Maybe (fromMaybe)
import Numeric.Natural
import System.Directory (doesFileExist)

data Command
  = Deposit AccountName Amount
  | Withdraw AccountName Amount
  | ShowBalance AccountName
  | ShowAccounts

type AccountName = String

type Amount = Natural

type Accounts = M.Map AccountName Amount

processCommand :: Command -> IO String
processCommand command = do
  accounts <- loadAccounts
  case command of
    ShowAccounts -> return $ showAccounts accounts
    ShowBalance name ->
      return $ name ++ "'s balance is " ++ show (getBalance name accounts)
    Deposit name amount -> do
      -- We could have also used sequence (>>) instead of the do block
      saveAccounts (deposit name amount accounts)
      return (name ++ " deposited " ++ show amount)
    Withdraw name amount -> case withdraw name amount accounts of
      Left err -> return err
      Right updatedAccounts -> do
        saveAccounts updatedAccounts
        return (name ++ " withdrew " ++ show amount)
  where
    -- "DB functions" are local for encapsulation purposes, we don't want
    -- anyone except processCommand to temper with the database.
    saveAccounts :: Accounts -> IO ()
    saveAccounts accounts = writeFile accountsFile $ show accounts

    loadAccounts :: IO Accounts
    loadAccounts = do
      exists <- doesFileExist accountsFile
      if exists
        then do
          contents <- fmap read (readFile accountsFile)
          -- The deepseq is necessary becaus of Haskell's lazy IO.
          -- We want to read the entire file right away and release the lock.
          -- If we didn't do this, we couldn't later write into the same file.
          contents `deepseq` return contents
        else return M.empty

    accountsFile = "accounts.txt"

getBalance :: AccountName -> Accounts -> Amount
getBalance name = fromMaybe 0 . M.lookup name

withdraw :: AccountName -> Amount -> Accounts -> Either String Accounts
withdraw name amount accounts
  | currentBalance < amount = Left "Not enough money in the account"
  | otherwise = Right $ M.insert name (currentBalance - amount) accounts
  where
    currentBalance = getBalance name accounts

deposit :: AccountName -> Amount -> Accounts -> Accounts
-- Version 1: insertWith + full eta-reduction
deposit = M.insertWith (+)

-- Version 2: This is what we had in the lecture, it's more explicit
-- deposit name amount accounts =
--   M.insert name (currentBalance + amount) accounts
--   where
--     currentBalance = getBalance name accounts

showAccounts :: Accounts -> String
showAccounts accounts =
  unlines
    [title, separator, accountList, separator]
  where
    accountList = intercalate "\n" . map showAccount $ M.toList accounts
    title = "      Accounts      "
    separator = replicate 20 '='
    showAccount (name, amount) = name ++ ": " ++ show amount
