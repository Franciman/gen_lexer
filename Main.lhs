Lexical Analyzer Generator
==========================

\begin{code}
module Main where

import ListCursor

import qualified Data.Map.Strict as M
import Control.Monad.State.Strict
import Data.Maybe
import LensPack
\end{code}

We can model a lexer (short for Lexical Analyzer) as a finite state machine.
Finite state machines can be defined either as regular expressions or as automatas.

Now we want to write a small programming language that encodes the meaning of a finite state machine
(either deterministic or non deterministic).

Our language should be able to do actions based on the current character:
- accept the input
- report an error
- take different routes (multiway if)

We should also be able to express a very limited form of recursion, at the moment I have
difficulty understanding what the limit should be. Of course we could allow a powerful unlimited recursion,
but this would imply having a language that is more powerful than a finite state machine.
Anyways, we can still guarantee program termination by requiring the loop to consume at least one input character
at each iteration.

We also want our language to allow composability, therefore we also have functions, which represent smaller FSM,
so we can define bigger FSM by composing smaller pieces.

Nondeterminism
---------------

When writing finite state machines, it can be easier to write a non deterministic machine, so it could be
interesting to have a notion of non determinism in the language

Text encoding
--------------

To be defined better

Defining the language
=====================

Grammar
-------

```
step-separator := `;`
program := (stmt step-separator)*
expr := `look`
      | variable
      | expr `=` expr
      | expr `!=` expr
      | `count`
      | char-lit
      | string-lit
      | number-lit
      | `true`
      | `false`
      | expr `<` expr
      | expr `>` expr

stmt := let-stmt
      | fun-def-stmt
      | fun-call-stmt
      | match-stmt
      | if-stmt
      | loop-stmt
      | `noop`
      | `error` string-lit
      | `accept` string-lit
      | `log` string-lit
      | `regex` regular-expression
```

Abstract Syntax Tree
--------------------

The Abstract syntax tree representing a program is therefore encoded in the following types:

\begin{code}
data Pred = Equal | NotEqual | LessThan | GreaterThan
data Expression = Look
                | Var String
                | BinaryPredicate Pred Expression Expression
                | Count
                | CharLit Char
                | StringLit String
                | NumberLit Int
                | BoolLit Bool

data Statement = Let String Expression
               | FunDef String Program
               | FunCall String
               | If Expression Program Program
               | Loop Expression Program
               | NoOp
               | Error String
               | Accept String
               | Log String

type Program = [Statement]
\end{code}

The Parser
----------

TODO

Semantics
----------

The semantics of the language is specified in terms of an operational semantics
that shows how the described finite state machine evolves while reading input text.

One important thing to note is that in the language there is no `read-next` operation
that consumes the input string. Instead each statement represent a transition to a new state.

Note that in a `FSM` not all transitions consume input, in fact there are `epsilon`-transitions that
do not consume any input , similarly not all statements consume input and it will be specified which 
will do. 

In order to run our finite state machine, we need to keep the input string and some pointers
telling us where lexing started and where it got accepted.

\begin{code}

data EvalState = EvalState
    { _inputString :: String
    , _cursor      :: ListCursor Char
    }

inputString :: Lens' EvalState String
inputString = lens _inputString (\v s -> s { _inputString = v })

cursor :: Lens' EvalState (ListCursor Char)
cursor = lens _cursor (\v s -> s { _cursor = v })
\end{code}

We also want to keep an environment that binds each variable to its value

\begin{code}
data Binding = Value Expression
             | FunctionBody Program

type NameEnv = M.Map String Binding

envHasName :: String -> NameEnv -> Bool
envHasName name env = isJust $ M.lookup name env

addBinding :: String -> Binding -> NameEnv -> NameEnv
addBinding name binding env = M.insert name binding env
\end{code}

Now we can define the monad in which the interpreter runs:

\begin{code}
data InterpreterState = InterpreterState
    { _inputState :: EvalState
    , _env        :: NameEnv
    }

inputState :: Lens' InterpreterState EvalState
inputState = lens _inputState (\v s -> s { _inputState = v })

env :: Lens' InterpreterState NameEnv
env = lens _env (\v s -> s { _env = v })

type FiniteStateMachine a = State InterpreterState a
\end{code}

Basically the interpreter is a finite state machine, so let us define the primitive operations of this machine:


This action moves the input cursor one position ahead:

\begin{code}
consumeInput :: FiniteStateMachine ()
consumeInput = modify' (& inputState . cursor %~ moveNext)
\end{code}

This action queries the input to see if there is more to consume:

\begin{code}
hasMoreInput :: FiniteStateMachine Bool
hasMoreInput = do
    cursor <- gets (^. inputState . cursor)
    return (hasNext cursor)
\end{code}

Now we want to also query the current input character:

\begin{code}
currentInput :: FiniteStateMachine Char
currentInput = do
    cursor <- gets (^. inputState . cursor)
    return (curr cursor)
\end{code}

Finally, we are ready to specify the interpreter for the language.



Statements NOT consuming input
------------------------------

- let statement
- error statement
- log statement
- noop operation, it basically does nothing

These statements are mostly helpers to get interesting things

Statements consuming input
--------------------------

All the other statements do consume input.


\begin{code}
main :: IO ()
main = do
    putStrLn "Hello, Haskell!"
\end{code}
