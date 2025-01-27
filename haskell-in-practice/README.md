# Haskell in practice
## A simple banking app
You can find all resources and instructions are [here](/bank/README.md).

## Haskell examples from [Wasp](https://wasp-lang.dev/)
### The [`findWaspFile`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Project/WaspFile.hs#L30) function
Demonstrates
  - Effective pattern matching over two `Maybe`s
  - Working with `Either`
  - Declerative top-to-bottom coding style
  - Treating `IO` as a functor (`<$>`)
  - Treating `IO` as a monad (the `do` block)
  - Partial application and eta reduction (in some of the helper functions)
  - Working with a custom sum type (`WaspFilePath`, imported from another module)
## The [`validateSrcTsConfig`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Generator/ExternalConfig/TsConfig.hs#L41) function
Demonstrates (together with its helper functions):
  - Effective pattern matching with `Maybe` (in `validateFieldValue`)
  - Choosing the right order of arguments for partial applications (applies to `validateFieldValue` and other helpers)
  - Using list comprehensions for defining an empty list or a singleton list (in `validateFieldValue`)
  - Declerative top-to-bottom coding style (for the error messages in `validateFieldValue`)
## The [`nextBreakingChangeVersion`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/SemanticVersion/Version.hs#L50) function
Demonstrates:
  - The power of pattern matching and destructuring
  - The `LambdaCase` extension
  - Haskell's conciseness and expressiveness
  ## The [`Util` module](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Util.hs#L3)
This module is full of small textbook functions. Here are some of the intresting ones:
  - `kebabToCamelCase` - Eta-reduction, composition, custom recursion (custom recursion isn't necessary, feel free to improve it through a PR :))
  - `onFirst`, `toUpperFirst`, and `toLowerFirst` - Abstracting a common pattern using higher-order functions
  - `trim` - Composition, eta reduction
  - `secondsToMicroseconds` - Operator section, partial application
  - `findDuplicateElems` - Composition, eta reduction. This function is used to find duplicate declarations in the Wasp file
  - etc.
## The [`getWaspProjectPathHash`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/cli/src/Wasp/Cli/Command/Telemetry/Project.hs#L122) function
Demonstrates:
  - Using a custom `Command` monad with context (i.e., state)
  - Composition, eta reduction, the appliation operator (`$`)
## The [`reportInstallationProgress`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Generator/NpmInstall.hs#L144) function
Demonstrates:
  - Infinite recursion
  - Using `IO` as a monad (the `do` block)
  - Inifinite lists (`cycle`)
  - Operator section (`secToMicroSec`)
## The [`analyze`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Analyzer.hs#L142) function
This function demonstrates a long monadic pipeline (i.e., a sequence of all Wasp's compilation steps)
## The [`getUncoercableTypesErrorMsgAndCtxInfoAndParsingCtx`](https://github.com/wasp-lang/wasp/blob/1b24645cf94ace459416b87c34127f32660a674e/waspc/src/Wasp/Analyzer/TypeChecker/TypeError.hs#L123) function
Demonstrates:
  - Pattern matching
  - Custom recursion for constructing a nested compiler error message

