University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2017/2018

LECTURE 12: Input/output operations

v1.1

(c) 2017 Jan Šnajder

==============================================================================

> import Control.Exception
> import Data.Char
> import Data.List
> import qualified Data.Map as M
> import Control.Monad
> import System.IO
> import System.Directory
> import System.IO.Error
> import System.Environment
> import System.FilePath
> import System.Random
> import System.FilePath

== IO ACTIONS ================================================================

Most programming we've done so far was PURE FUNCTIONAL programming. What
doesn't fit this bill are the IO operations. These are different because they
*must* result in a side effect. Input functions (e.g., reading from a keyboard)
cannot always return the same value, while output functions (e.g., writing to a
screen) must be able to change the system state. We refered to such IO
operations as ACTIONS. We've also seen that actions are of the following type:

  IO a

where 'a' is the type of action's return value. E.g.:

  IO String
  IO Int
  IO (Int, String)
  IO ()

The last type is for actions that return nothing. The '()' type is called UNIT.
It is actually an empty tuple type (a "0-ary tuple"). An empty tuple (the
value) is also written as '()'. So, value '()' is of type '()', in other words:
'() :: ()'.

'IO' is actually a type constructor of '* -> *' kind. We can think of it as a
"box" that stores actions that are not functionally pure.

In Haskell, we pay a lot attention to separating the purely functional (non-IO)
code from impure (IO) code. As a matter of fact, because all impure actions are
wrapped up into the 'IO' type, this separation occurs naturally.

(Remark: the 'IO' type is actually a MONAD. More precisely: the 'IO' type is an
instance of the 'Monad' type class. We often simply say "the IO monad". But
let's forget this for now.)

Finally, here you have "Hello, world!" in Haskell:

> main1 = putStrLn "Hello, world!"

This is an action. What is it's type? What is the type of the 'putStrLn'
function?

  main :: IO ()
  putStrLn :: String -> IO ()

Function 'putStrLn' takes a string and returns an action (that outputs the
string to the screen).

You can compile the above program (using 'ghc --make') and run it. Every
program that has a 'main' function can be compiled (and linked). You must have
no more than one 'main' function. When the program is run, the 'main' function
is executed.

The 'main' function can invoke other functions that also do some actions. E.g.,
we could have had:

  main = sayHelloToTheWorld
  sayHelloToTheWorld = putStrLn "Hello, world!"

Now, doing a single action is rarely enough. If we need to execute many
actions, we need to sequence them into one action. We do this using a special
language construct 'do':

> main2 = do
>   putStrLn "here"
>   putStrLn "we"
>   putStrLn "go"

All statements in a do block must be aligned one below the other. The 'main2'
function executes three actions, but these are tied into a single action, so
it's type is again 'IO ()'. The actions within a do block are executed
sequentially, from top to bottom, as in imperative languages.

Another example:

> main3 = do
>   putStrLn "Enter you lucky number"
>   number <- getLine
>   putStrLn $ "I guess your lucky number is " ++ number

What is the type of 'getLine'?

The '<-' operator takes an action on its right side and a variable on its left
side and stores the return value of the action into the variable. Otherwise
said, the '<-' operator unwraps the return value of type 'IO a' from an action
into a value type of 'a'. This can only be done within a do block of a function
whose type is 'IO a'.

Will the following work?

  foo = "Your name is " ++ getLine

Or this:

  main4 = do
    putStrLn "Enter your lucky number"
    putStrLn $ "Your lucky number is " ++ getLine

Function 'putStrLn' expects a string. Similarly, function (++) expects a
string. But function 'getLine' is not of type 'String' but of type 'IO String'.
To get to the string, we need to unwrap it using the '<-' operator.

Here's something that will work:

> askNumber :: IO String
> askNumber = do
>   putStrLn "Enter your lucky number"
>   getLine

> main5 :: IO ()
> main5 = do
>   number <- askNumber
>   putStrLn $ "Your lucky number is " ++ number

The return value of a the whole do block is the return value of the last
action. This is why the return value of 'askNumber' is a string returned by the
'getLine' action.

Every action results in a value that we can store. But we don't necessarily
need to store it. For example:

> main6 :: IO ()
> main6 = do
>   putStrLn "Enter your lucky number"
>   getLine
>   putStrLn "Thanks!"

The result of the 'putStrLn' action is '()', so it doesn't make sense to store
it. The result of the 'getLine' action is a string but we chose not to store it
(this makes sense if want the user to press any key before we continue).

== EXERCISE 1 =================================================================

1.1.
- Define a 'main' function that reads in two strings and prints them out
  concatenated and reversed.

1.2.

- Write a function 'threeNumbers' that reads in three numbers and prints out
  their sum.
- Call this function from within a 'main' function, then compile and run the
  program.

== RETURN =====================================================================

What if we wish to modify a string taken from the input, before we return if
from the action? We can do this as follows:

> askNumber2 :: IO String
> askNumber2 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   return $ number ++ "0"

The function 'return :: a -> IO a' gets a value and turns into an action
result.

'return' need not be the last action. It can appear anywhere in a
do block. 'return' does not cause a return from a function -- it just wraps up
a value into a 'IO' type (or, more generally, into a Monad). E.g.:

> askNumber3 :: IO String
> askNumber3 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   return $ number ++ "0"
>   getLine

The code above doesn't make a lot of sense but illustrates the point. The
return value of a 'do' block is the return value of the last action, regardless
whether a 'return' function has appeared before that. So, it is nothing like a
return in an imperative function (it does not really return from the function)!

(Obviously, "return" is not the best choice for the name of this function. A
name like "wrap" or "inject" would have been a better choice, but now it's too
late.)

We can of course branch the control flow within an action:

> askNumber4 :: IO String
> askNumber4 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   if number == "" then return "7"
>     else return number

What is important is that both branches return an action of the same type,
which turns an 'if-then-else' into an action. In the above example, because
if-then-else is the last action in a 'do' block, its type must be 'IO String',
as specified by the type signature.

We can also write the above function like this:

> askNumber5 :: IO String
> askNumber5 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   return $ if number == "" then "7" else number

Would the following work?

 askNumber6 :: IO String
 askNumber6 = do
   putStrLn "Enter your lucky number"
   number <- getLine
   if number == "" then "7" else number

And why is this no good?
  
  main7 :: IO ()
  main7 = do
    putStrLn "Enter your lucky number"
    number <- getLine
    return number

We can, of course, use recursion in IO actions:

> askNumber7 :: IO String
> askNumber7 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   if number == "" then askNumber7 else return number 

This is alright because both branches are actions. 

Now, what if we want to execute more than one action in one of the branches? We
again need to sequence them into a single action using a 'do' block:

> askNumber8 :: IO String
> askNumber8 = do
>   putStrLn "Enter your lucky number"
>   number <- getLine
>   if number == "" then do
>     putStr "No input! "
>     askNumber8 
>   else return number 

== EXERCISE 2 =================================================================

2.1.
- Define a function 'threeStrings' that reads in three strings and outputs them
  to the screen as one string, while it returns its total length.
  treeStrings :: IO Int

2.2.
- Define a function 'askNumber9' that reads in a number and returns that number
  converted into an 'Int'. Input should be repeated until the user enters a
  number (a string containing only digits).
    askNumber9 :: IO Int
- Define a function 'main' that calls 'askNumber9' and outputs the number to
  the screen.
- Build and run the program.

2.3.
- Define a function 'askUser m p' that returns an action that prints out 'm',
  reads in a string from the input, repeats the input until the input
  string satisfies the function 'p', and then returns the input string.
    askUser :: String -> (String -> Bool) -> IO String
- Generalize this function to
    askUser' :: Read a => String -> (String -> Bool) -> IO a
- Define a 'main' function that prints out the read-in value to the screen.
- Build and run the program.

2.4.
- Define a function that reads in strings until the user inputs an empty
  string, and then returns a list of strings received as input.
    inputStrings :: IO [String]

== WHERE & LET ===============================================================

Within IO actions, we can use the 'let' command to assign values to variables:

> askName1 :: IO String
> askName1 = do
>   s1 <- getLine
>   s2 <- getLine
>   let forename = map toUpper s1
>       lastname = map toUpper s2
>   return $ forename ++ " " ++ lastname

Note that the expression on the RHS of 'let' must be pure (non-IO). In other
words, it cannot be wrapped up in an 'IO' type. If we want to assign to a
variable a value that is the return of an action, we need to use '<-'.

So, this is wrong:

  askName2 :: IO String
  askName2 = do
    s1 <- getLine
    s2 <- getLine
    forename <- map toUpper s1
    lastname <- map toUpper s2
    return $ s1 ++ " " ++ s2

As is this:
  
 askName3 :: IO String
 askName3 = do
   let s1 = getLine
       s2 = getLine
       forename = map toUpper s1
       lastname = map toUpper s2
   return $ s1 ++ " " ++ s2

You can also use a 'where' block, but it has to be placed outside of a 'do'
block:

> askName4 :: IO String
> askName4 = do
>   s1 <- getLine
>   s2 <- getLine
>   return $ upperCase s1 ++ " " ++ upperCase s2
>   where 
>     upperCase = map toUpper

== COMMON IO FUNCTIONS ========================================================

  putStr :: String -> IO ()
  putStrLn :: String -> IO ()
  putChar :: Char -> IO ()
  print :: Show a => a -> IO ()

For example, 'putStr' implemented using 'putChr':

> putStr1 :: String -> IO ()
> putStr1 [] = return ()
> putStr1 (x:xs) = do
>   putChar x
>   putStr1 xs

The difference between 'print' and 'putStr' is that the former can be applied
to any type that is a member of the 'Show' type class. Actually, 'print' is
defined as 

  print = putStrLn . show

As a consequence, if we apply print on a string, it will be printed with
quotes:

  print "Hello, world!"

In the 'Control.Monad' module you will find a number of functions for managing
actions:

  when :: Applicative f => Bool -> f () -> f ()
  sequence :: Monad m => [m a] -> m [a]
  mapM :: Monad m => (a -> m b) -> [a] -> m [b]
  forever :: Monad m => m a -> m b

(Actually, the types for 'sequence' and 'mapM' are a bit more generic.)

Here, 'm' is any type that is a member of the 'Monad' type class. We've already
said that 'IO' is a member of this class, so all the above functions will work
with IO actions. The 'f' is a type of the 'Applicative' type class, which also
includes they IO type.

The 'when' function executes the given action if the condition is met,
otherwise it executes 'return ()'.
  
> main8 = do
>   input <- getLine
>   when (input == "") $ 
>     putStrLn "Input is empty"

which is the same as:

> main9 = do
>   input <- getLine
>   if input == "" then 
>     putStrLn "Input is empty"
>   else return ()

The 'sequence' function takes a list of actions and returns a single action
that runs these actions in sequence and returns a list of their return values.

On other words, this:

> action1 = sequence [getLine, getLine] 

is the same as

> action2 = do
>   x1 <- getLine
>   x2 <- getLine
>   return [x1, x2]

> main10 = do
>   putStrLn "Introducir tres números"
>   xs <- sequence [getLine, getLine, getLine]
>   putStrLn $ "Gracias. Ha introducido " ++ unwords xs

What about this?

  main11 = do
     xs <- sequence [putStrLn "Introducir tres números", 
                     getLine, getLine, getLine]
     putStrLn $ "Gracias. Ha introducido " ++ unwords (tail xs)

'sequence' is useful for mapping an IO action over a list:

> main12 = do
>   sequence $ map print [1..10]

or, more succinctly (because we only have one action):

> main13 = sequence $ map print [1..10]

What is the type of the above function?

Since we don't really care about the result of the function, we can re-define
the function like this:

> main14 = do
>   sequence $ map print [1..10]
>   return ()

Is the following ok?

> main15 = do
>   sequence $ map (putStrLn . show) [1..10]
>   return ()

Because 'sequence $ map' is required quite often, there is a standard function
'mapM' that does exactly that:

> main16 = mapM print [1..10]

If we don't want to collect the results of the individual actions, but only
care about their side effects, we use the function 'mapM_' instead:

> main17 = mapM_ print [1..10]

The difference between 'mapM' and 'mapM_' is visible from their signatures:

  mapM  :: Monad m => (a -> m b) -> [a] -> m [b]
  mapM_ :: Monad m => (a -> m b) -> [a] -> m ()

There's a function similar to 'mapM' called 'forM'. It is the same as 'mapM',
but with flipped arguments, so that the list comes first and the action comes
second. This is reminiscent of "foreach" loops in imperative languages.

> main18 = forM [1..10] print

There's also a 'forM_' version that discards the resulting values:

> main19 = forM_ [1..10] print

Often you will find yourself using 'forM' in combination with a lambda
expression, like here:

> main20 = do
>   ys <- forM [1..10] $ \x -> do
>     putStrLn $ "Input " ++ show x ++ "th number"
>     y <- getLine
>     return $ read y
>   putStrLn $ "The sum is " ++ show (sum ys)

Function that repeats an action a given number of times:

  replicateM :: Monad m => Int -> m a -> m [a]
  replicateM_ :: Monad m => Int -> m a -> m ()

Another interesting function is 'forever':

> main21 = forever $
>   putStrLn "Forever young"

Take a quiet moment to think about the type of this function.

== EXERCISE 3 =================================================================

3.1.
- Define a function that reads in a number, then reads in that many
  strings, and finally prints these strings in reverse order.

3.2.
- Give recursive definitions for 'sequence' and 'sequence_'.

3.3.
- Give a recursive definitions for 'mapM' and 'mapM_'.

3.4.
- Define a function that prints out the Pythagorean triplets whose all sides
  are <=100. Every triplet should be in a separate line.

== READING FROM STREAMS ======================================================

Up until now we read from the standard input line by line ('getLine' function).
We can also read character by character ('getChar' function). For example, a
program that reads in characters from standard input, converts to upper case,
and outputs them to standard output:

> main22 :: IO ()
> main22 = do
>   c <- getChar
>   putChar $ toUpper c
>   eof <- isEOF
>   if eof then return () else main22

We can do the same line by line:

> main23 :: IO ()
> main23 = do
>   l <- getLine
>   putStrLn $ map toUpper l
>   eof <- isEOF
>   unless eof main23

In situations like these, when we eventually want to read in all the data from
standard input (or a file), it's better to work with STREAMS right away. A
stream is actually a string that contains the whole input. However, because
Haskell is lazy, the whole string won't be read in at once. It is only when new
elements of the stream (characters or lines) are required that these will
actually be read into the string. On the other hand, when an element of the
stream (a character or a line) is no longer needed, it will be removed from the
memory by the garbage collector.

For reading streams from standard input we use the function:

  getContents :: IO String

For instance, a program that reads in a text from standard input and converts
all letters into uppercase:

> main24 :: IO ()
> main24 = do
>   s <- getContents
>   putStr $ map toUpper s

This will read in at most 10 characters:

> main25 :: IO ()
> main25 = do
>   s <- getContents
>   putStr . take 10 $ map toUpper s

And this at most 10 lines:

> main26 :: IO ()
> main26 = do
>   s <- getContents
>   putStr . unlines . take 10 . lines $ map toUpper s

A function that reads lines from standard input and outputs all non-empty
lines:

> main27 :: IO ()
> main27 = do
>   s <- getContents
>   putStr . unlines . filter (not . null) $ lines s

Often we need to read some data from standard input, transform them, and print
to standard output. We can accomplish that succinctly using 'interact':

  interact :: (String -> String) -> IO ()
  interact f = do s <- getContents
                  putStr (f s)

For example, we could have defined the above functions like this:

> main28 :: IO ()
> main28 = interact (map toUpper)

> main29 :: IO ()
> main29 = interact (unlines . filter (not . null) . lines)

== EXERCISE 4 ================================================================

4.1.
- Define a function that removes from standard input every second line and
  prints the result to standard output.
    filterOdd :: IO ()

4.2.
- Define a function that prefixes each line from standard input with a line
  number (number + space).
    numberLines :: IO ()

4.3.
- Define a function to remove from standard input all words from a given set of
  words.
    filterWords :: Set String -> IO ()

== WORKING WITH FILES ========================================================

We've been using functions from 'System.IO' that work with standard input and
output. The same module also provides similar functions to work with files:

  hPutStr :: Handle -> String -> IO ()
  hPutStrLn :: Handle -> String -> IO ()
  hGetLine :: Handle -> IO String
  hGetChar :: Handle -> IO Char
  hGetContents :: Handle -> IO String

These function take a file handle (a value of type 'Handle') that contains all
the relevant OS information about the file. We get a handle by opening a file:

  openFile :: FilePath -> IOMode -> IO Handle

'FilePath' is a synonym for 'String'. 'IOMode' is defined as follows:

  data IOMode =  ReadMode | WriteMode | AppendMode | ReadWriteMode

After we're finished with the file, we need to close it:

  hClose :: Handle -> IO ()

E.g., a function that opens a given file and prints its content:

> cat1 :: FilePath -> IO ()
> cat1 f = do
>   h <- openFile f ReadMode
>   printLines h
>   hClose h
>
> printLines :: Handle -> IO () 
> printLines h = do 
>   l <- hGetLine h
>   putStrLn l
>   eof <- hIsEOF h
>   if eof then return () else printLines h

A genuine Haskeller will write this in a neater way using streams:

> cat2 :: FilePath -> IO ()
> cat2 f = do
>   h <- openFile f ReadMode
>   s <- hGetContents h
>   putStr s
>   hClose h

Let's ginger the output with line numbers:

> cat3 :: String -> IO ()
> cat3 f = do
>   h <- openFile f ReadMode
>   s <- hGetContents h
>   forM_ (zip [0..] (lines s)) $ \(i,l) -> 
>     putStrLn $ show i ++ ": " ++ l
>   hClose h

or

> cat4 :: String -> IO ()
> cat4 f = do
>   h <- openFile f ReadMode
>   s <- hGetContents h
>   putStr . unlines . zipWith (\i l -> show i ++ ": " ++ l) [0..] $ lines s
>   hClose h

This situation (opening a file, processing it, and closing it) is quite common,
hence there's a special function that makes this easier:

  withFile :: FilePath -> IOMode -> (Handle -> IO a) -> IO a

This function also takes care that the file is closed if an error occurs.

Printing the content of a file with line numbers:

> cat5 :: String -> IO ()
> cat5 f = withFile f ReadMode $ \h -> do
>  s <- hGetContents h
>  putStr . unlines . zipWith (\i l -> show i ++ ": " ++ l) [0..] $ lines s

For standard input and output there are predefined handles (which need not be
opened nor closed): 'stdin', 'stdout' i 'stderr'.

IO function on standard input/output are actually defined as follows:

  getLine = hGetLine stdin
  putStr = hPutStr stdout
  putStrLn = hPutStrLn stdout
  getContents = hGetContents stdin 
  ...

A couple of other useful functions from 'System.IO':

  hFileSize :: Handle -> IO Integer
  hSeek :: Handle -> SeekMode -> Integer -> IO ()
  hTell :: Handle -> IO Integer
  hFlush :: Handle -> IO ()
  hIsEOF :: Handle -> IO Bool

== EXERCISE 5 ================================================================

5.1.
- Define a function
  wc :: FilePath -> IO (Int, Int, Int)
  that counts the number of characters, words, and lines in a file.
- NB: This function will probably misbehave. If this happens, learn more about
  why it happened here: https://tinyurl.com/y9xobdyd .
  Even 'seq' won't do the trick; you'll need 'deepseq' from Control.DeepSeq.

5.2. 
- Define a function
  copyLines :: [Int] -> FilePath -> FilePath -> IO ()
  that copies given lines from the first file into the second.

==============================================================================

Reading from a stream (using 'hGetContents') and writing to it (using
'hPutStr') is a common pattern, hence there are functions that make this
easier, without the need to explicitly open a file and maintain a handle:

  readFile  :: FilePath -> IO String
  writeFile :: FilePath -> String -> IO ()

> cat6 :: String -> IO ()
> cat6 f = do
>  s <- readFile f
>  putStr . unlines . zipWith (\i l -> show i ++ ": " ++ l) [0..] $ lines s

> uppercaseFile :: FilePath -> IO ()
> uppercaseFile f = do
>   s <- readFile f
>   putStr $ map toUpper s

> interlaceFiles :: FilePath -> FilePath -> FilePath -> IO ()
> interlaceFiles f1 f2 f3 = do
>   s1 <- readFile f1
>   s2 <- readFile f2
>   writeFile f3 . unlines $ interlace (lines s1) (lines s2)
>   where interlace xs ys = concat $ zipWith (\x1 x2 -> [x1,x2]) xs ys

Serialization of a data structure (dumping it to disk) and deserialization
(reading it from disk) can be accomplished in a straightforward manner using
'readFile' and 'writeFile', respectively, in a combination with 'read' and
'show', respectively. For example, serialization of a list:

> main30 :: IO ()
> main30 = do 
>   let l = [(x, y) | x <- [0..100], y <- [x..100]]
>   writeFile "list.txt" $ show l

Deserialization:

> main31 :: IO ()
> main31 = do
>   s <- readFile "list.txt" 
>   let l = read s :: [(Int, Int)]
>   print l

As always when we use 'read', we must specify the type of the value to be read
and we must take care that whatever is in the string really parses accordingly
(otherwise we get a "no parse" error).

NOTE: The examples above do textual serialization, which is inefficient for
large data structures. For binary serialization, use of of the binary
serialization packages, such as binary, cereal, or beamable:
http://hackage.haskell.org/package/binary
http://hackage.haskell.org/package/cereal-plus
http://hackage.haskell.org/package/beamable

EXAMPLE: We maintain a word translation dictionary, implemented as 'Data.Map',
which we store in a file. We make queries to the dictionary via the keyboard.
For words which don't exists in the dictionary, we can provide translations
that are added to the dictionary and stored before exiting.

> type Dict = M.Map String String
> dictFile = "dict.txt"

> main11b :: IO ()
> main11b = do
>   d1 <- readDict
>   d2 <- useDict d1
>   writeFile dictFile $ show d2

> readDict :: IO Dict
> readDict = do
>   e <- doesFileExist dictFile
>   if e then do
>     s <- readFile dictFile
>     return $ read s
>   else return M.empty

> useDict :: Dict -> IO Dict
> useDict d = do
>   putStrLn "Enter term: "
>   w1 <- getLine
>   if null w1 then return d else
>     case M.lookup w1 d of
>       Just w2 -> do
>         putStrLn w2
>         useDict d
>       Nothing -> do
>         putStrLn $ "No entry. How would you translate " ++ w1 ++ "?"
>         w2 <- getLine 
>         useDict $ M.insert w1 w2 d

REMARK: It is generally a bad idea to open a file using 'readFile' and then
write to the same file using 'writeFile'. This, however, is possible only if
the whole stream is consumed before writing to the file. This is indeed the
case in the above example, as the 'lookup' function forces the whole string to
be read in from the file (why?).

In contrast, this won't work:

> main32 :: IO ()
> main32 = do
>   d1 <- readDict
>   writeFile "dict.txt" $ show d1

Occasionally we need to be able to create a temporary file, for example when
changing an existing file. Use the following function for this:

  openTempFile :: FilePath -> String -> IO (FilePath, Handle)

The function takes a path and a file name, and returns a unique name of a newly
created temporary file and its handle. After using the file, you have to close
it using 'hClose'.

E.g., a function that sorts alphabetically the lines in a given file:

> sortFile :: FilePath -> IO ()
> sortFile f = do
>   (ft, ht) <- openTempFile "" f
>   s <- readFile f
>   hPutStr ht . unlines . sort $ lines s
>   hClose ht
>   renameFile ft f

REMARK: In most cases it is better to write the altered content to the standard
output than to change the original file. This enables the user to check the
output and do with it what she wants.

== EXERCISE 6 =================================================================

6.1.
- Define a function
    wordTypes :: FilePath -> IO Int
  to compute the number of distinct words in the given file.

6.2.
- Define a function 
    diff :: FilePath -> FilePath -> IO ()
  that takes two file names, compares their corresponding lines, and then
  outputs to standard output all lines in which the files differ. Lines should 
  be printed one below the other, prefixed with "<" for the first and ">" for
  the second file.

6.3.
- Define a function
    removeSpaces :: FilePath -> IO () 
  that removes trailing spaces from all lines in the given file.
  The function should change the original file.

== EXCEPTION HANDLING =========================================================

IO actions can cause exceptions. Exceptions can be handled but only within an
IO monad. There are no specific syntax constructs for handling exceptions.
Instead they are handled using functions from the 'Control.Exception':

  try :: Exception e => IO a -> IO (Either e a)
  catch :: Exception e => IO a -> (e -> IO a) -> IO a

NOTE: Functions for exception handing specifically for IO operations reside in
the 'System.IO.Error' module. However, we'll be using 'Control.Exception'
because it's more general in that it can be used to catch other kinds of
exceptions (pure code exceptions and asynchronous exceptions, such as stack
overflow). Note, however, that even these other kind of exceptions can only be
caught within an IO monad.

'try' takes an action and returns 'IO (Right a)' if everything turned out ok,
otherwise it returns 'Left e' if an exception occurred.

For example:

> cat7 :: String -> IO ()
> cat7 f = do
>  r <- try $ cat6 f
>  case r of 
>    Left e  -> putStrLn $ "Error: " ++ ioeGetErrorString e
>    _       -> return ()

'catch' takes two actions: one that can cause an exception and another that
handles it. For example:

> cat8 :: String -> IO ()
> cat8 f = catch (cat6 f) $ \e ->
>   if isDoesNotExistError e then putStrLn "Error: someone stole the file"
>   else ioError e  -- rethrowing the exception

'try' and 'catch' functions take care that the program recovers from an
exception. If we only want to clean up after an exception occurred (e.g., close
the open files), we use the following function from 'Control.Exception':

  bracket :: IO a -> (a -> IO b) -> (a -> IO c) -> IO c

The function 'bracket' takes three actions: action 'IO a' acquires a resource,
action 'a -> IO b' releases it, while action 'a -> IO c' actually does some
processing with the resource. If an exception occurs, the action that releases
the resource will be executed, and the exception will be rethrown. A typical
use of this pattern is as follows:

 bracket (openFile f ReadMode) hClose (\h-> do ...)

The 'withFile' function, which we introduced earlier, is actually defined as:

  withFile f mode = bracket (openFile f mode) hClose

For example, you might define a 'withTempFile' function as this:

> withTempFile :: FilePath -> String -> ((FilePath, Handle) -> IO c) -> IO c
> withTempFile path f = bracket
>   (openTempFile path f)
>   (\(f, h) -> do hClose h; removeFile f)

== ENVIRONMENT VARIABLES ======================================================

Arguments can be passed to a program via a command line. The following
functions from the 'System.Environment' module retrieve these arguments:

  getProgName :: IO String
  getArgs :: IO [String]
  
> main33 :: IO ()
> main33 = do
>   xs <- getArgs
>   x <- getProgName
>   putStrLn $ "Program " ++ x ++ " is invoked with arguments " ++ show xs

You can use the 'withArgs' function to supply arguments to this function, or
you can rename the function to 'main' and then run ':main' in ghci. Of course,
you can also build the program and run it from the command line.

  withArgs ["arg1", "arg2"] main13
  :main arg1 arg2

Example: 'sort' that opens a file (if it exists, otherwise it takes the
standard input), sorts it, and prints to standard output:

> main666 :: IO ()
> main666 = do
>   xs <- getArgs
>   h <- case xs of
>     (f:_) -> do e <- doesFileExist f
>                 if e then openFile f ReadMode else return stdin
>     []    -> return stdin
>   s <- hGetContents h
>   putStr . unlines . sort $ lines s

REMARK: For a more sophisticated (unixoidal) command line argument processing you
should be using functions from the 'System.Console.GetOpt' module:
'System.Console.GetOpt'.
http://www.haskell.org/ghc/docs/latest/html/libraries/base/System-Console-GetOpt.html
or one of the modules that builds on top of it, such as:
http://hackage.haskell.org/package/parseargs
https://hackage.haskell.org/package/optparse-applicative

== EXERCISE 7 =================================================================

7.1.
- Define a function
    fileHead :: IO ()
  that prints the first 'n' lines from a file. The name of the file and the
  number of lines are specified at the command line, e.g.:
    filehead -5 input.txt
  If the number of lines is missing, default to 10. If file name is missing,
  read from the standard input. If the file doesn't exist, print an error
  message and exit with failure using 'exitFailure' from 'System.Exit'.

7.2.
- Define a function
    sortFiles :: IO ()
  that sorts lines from multiple files and prints them to standard output.
  File names are provided at the command line.
  "sortFiles file1.txt file2.txt file3.txt"
  If any of the files does not exist, print an error message.

== FILE SYSTEM OPERATIONS =====================================================

Module 'System.Directory' contains a set of functions for interacting with a
file system. The most important ones are:

  copyFile :: FilePath -> FilePath -> IO ()
  createDirectory :: FilePath -> IO ()
  doesDirectoryExist :: FilePath -> IO Bool
  doesFileExist :: FilePath -> IO Bool
  removeFile :: FilePath -> IO ()
  renameFile :: FilePath -> FilePath -> IO ()
  getDirectoryContents :: FilePath -> IO [FilePath]

Functions for operations on file paths reside in the 'System.FilePath' module.
The most important ones are:

  (</>) :: FilePath -> FilePath -> FilePath
  takeBaseName :: FilePath -> String
  takeDirectory :: FilePath -> FilePath
  takeExtension :: FilePath -> String
  takeFileName :: FilePath -> FilePath

== RANDOM NUMBER GENERATOR ===================================================

Module 'System.Random' provides functions for generating (pseudo)random numbers
within the IO monad.

The main (and most general) function is

  random :: (RandomGen g, Random a) => g -> (a, g)

'Random' is a type class for types whose values can be randomly generated,
while 'RandomGen' is a type class for the various implementations of random
number generators (actually a random generator API).

In most cases you will want to use the standard random number generator called
'StdGen', which is an instance of the 'RandomGen' class. To create a standard
random number generator, use the function

  mkStdGen :: Int -> StdGen

which takes a seed value and returns the standard RNG initialized with this
seed.

> g = mkStdGen 13
> (r1, g2) = random g :: (Int, StdGen)
> (r2, g3) = random g2 :: (Int, StdGen)
> (r3, g4) = random g3 :: (Int, StdGen)

  randoms :: (RandomGen g, Random a) => g -> [a]

> xs = randoms g :: [Float]
> fiveCoins = take 5 $ randoms g :: [Bool]

To generate random numbers from within an interval, use

  randomR :: (RandomGen g, Random a) => (a, a) -> g -> (a, g)
  randomRs :: (RandomGen g, Random a) => (a, a) -> g -> [a]

> fiveDice = take 5 $ randomRs (1, 6) g :: [Int]

The obvious problem is that, because Haskell is pure, we need to drag around
the last instance of the RNG. Another problem is that we must specify the seed.
Both problems disappear if we use an RNG in the IO monad. To create an RNG in
the IO monad, use

  getStdGen :: IO StdGen

> main35 :: IO ()
> main35 = do
>   g <- getStdGen
>   putStrLn $ take 10 (randomRs ('a', 'z') g)
>   g2 <- getStdGen
>   putStrLn $ take 10 (randomRs ('a', 'z') g2)

The problem here is that we don't get different values every time we run the
RNG, despite calling 'getStdGen' twice. We need to "split" the RNG using
'newStdGen':

> main36 :: IO ()
> main36 = do
>   g <- getStdGen
>   putStrLn $ take 10 (randomRs ('a','z') g)
>   g2 <- newStdGen
>   putStrLn $ take 10 (randomRs ('a','z') g2)

A shorter way to accomplish the same:

  getStdRandom :: (StdGen -> (a, StdGen)) -> IO a

> main37 :: IO ()
> main37 = do
>   x <- getStdRandom (randomR (0,100)) :: IO Int
>   print x

NOTE: You can also use the 'Control.Monad.Random' module, which provides a more
flexible framework for random number generation:
http://hackage.haskell.org/package/MonadRandom

== EXERCISE 8 =================================================================

8.1.
- Define your own implementation of
    randoms' :: (RandomGen g, Random a) => g -> [a]

8.2.
- Define a function
    randomPositions :: Int -> Int -> Int -> Int -> IO [(Int,Int)]
  that returns a list of randomly generated integer coordinates from within a
  given interval.
    randomPositions 0 10 0 10 => [(2,1),(4,3),(7,7),...

