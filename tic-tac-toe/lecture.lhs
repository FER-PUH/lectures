University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2024/2025

LECTURE: Tic Tac Toe

(c) 2022 Martin Sosic

==============================================================================



> import Data.Text (Text)
> import Debug.Trace (trace)
> import Control.Monad (replicateM, replicateM_, join, liftM, liftM2)




== OVERVIEW ========================================================

In this lecture we are going to be implementing a Tic-Tac-Toe game together (group programming!) in Haskell!



== Let's do a project together! ===========================

== Setup of a project: GHCup and Cabal

GHCup
  -> ghc   (analogous to: gcc)
  -> cabal (analogous to: npm, cargo, Maven/Gradle, ...)
  -> hls   (IDE)

NOTE: Show output of `ghcup tui`, make sure we all have the same settings.

Let's create new project with Cabal:
  > mkdir tictactoe
  > cd tictactoe
  > cabal init

Choose all the default options.

Let's run it:

  > cabal run

TIP: Very useful are also `cabal build` and `cabal test`.

TIP: Cabal recognizes three types of project "components" and you can have as many of those as you want:
 - exe
 - library
 - tests

We will stick to just a single exe for now to keep it simple.



== Implementing Tic Tac Toe

Goals of the project:
  - ASCII graphics
  - two human players
  - game always starts with X (this is actual standard)
  - single game
  - don't allow illegal moves
  - pronounce winner
  - if there is extra time left:
    - introduce AI player (naive one)
    - show how to write tests

Notes for lecturer:
  - Lecturer leads the programming, but constantly asks students on advice how to do next step, what
    would they do next, how would they do something, what exactly would they write next.  Then
    discusses and decides what to do, while ensuring proper tempo an driving project in the healthy
    direction.
  - Find an opportunity to demonstrate Haskell modules and how they are used.
  - Try at home implementing tictactoe once or twice alone before you do it in class.
  - It is probably best to advise students not to program on their machines in parallel, because
    they will have trouble following me. Instead, we are programming on the project screen all
    together and I am typing, and they are focused. That said, they can do it if they want of
    course, this is just advice, and often they will.

  - Tips for actual implementation:
    - Ask them how they want to start. They will suggest defining types first, and some functions on
      them. Say that is great, because it is, but potentially push different direction, where we
      start with empty main and fill its do block with actions. Have them figure out steps like
      "askForMove", "performMove", "printGame", "checkGameResult", ... . This way we avoid
      overengineering, plus we get them to think a bit differently and we show how we can write
      something that makes sense without implementing anything.
    - Don't implement anything yet, just define functions with signatures but `undefined` or
      `error "TODO"` as implementation, and define types as `data Move = Move`, `data Game = Game`,
      and so on, minimal to get compiler to pass. This is cool technique that we want to show.
      Go like this as far as you can go without implementing anything.
    - Also don't neccesarily push for the game loop immediatelly, we can have just one pass in do
      block and then we will later make it a loop.
    - Push in the direction of having `Game = [Move]`, instead of some kind of matrix.
      It is very elegant way to represent the game state. Offers cool stuff like undo!
    - When parsing move, you can use Either's Monad instance to combine parsing of two coordinates
      in a nice way.
    - To ensure we have enough time to get something running in terminal, leave `determineGameResult
      :: Game -> Maybe Outcome` function for the last, and in the meantime just set it to always
      return `Nothing`. This way we can play tic tac toe without having that done, although it will
      never end.
    - Implement Move as `data Move = Move Int Int`, but emphasize that it could be better typed by
      doing something like `data Row = R1 | R2 | R3` and `data Col = C1 | C2 | C3` and then `data
      Move = Move Row Col`.
