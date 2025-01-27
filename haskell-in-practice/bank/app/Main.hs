module Main where

import Core (Command (..), processCommand)
import Server (serve)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["serve"] -> serve
    _ -> executeDirectCommand args

executeDirectCommand :: [String] -> IO ()
executeDirectCommand args = case parseCommand args of
  Left errorMessage -> putStrLn errorMessage
  Right command -> processCommand command >>= putStrLn

parseCommand :: [String] -> Either String Command
parseCommand args = case args of
  ["deposit", name, amount] -> Right $ Deposit name (read amount)
  ["withdraw", name, amount] -> Right $ Withdraw name (read amount)
  ["balance", name] -> Right $ ShowBalance name
  ["accounts"] -> Right ShowAccounts
  _ -> Left $ "Invalid command or arguments: " ++ unwords args
