Lenses
=======

\begin{code}
{-# LANGUAGE Rank2Types #-}
module LensPack where

import Data.Functor.Const
import Data.Functor.Identity
\end{code}

We want to define a very minimal pack of tools for using lenses in our program.

It is going to be extremely minimal, becuase our needs are really minimal too.
In fact, we are only interested in accessing and modifying nested record types.

We use the famous van Laarhoven lens encoding.

\begin{code}
type Lens s t a b = forall f. (Functor f) => (a -> f b) -> s -> f t
\end{code}

Many times we will want a less polymorphic lens like `Lens s s a a`, so we define a type alias for it:

\begin{code}
type Lens' s a = Lens s s a a
\end{code}

Now we define a simple way to generate a Lens from a getter and a setter:

\begin{code}
lens :: (s -> a) -> (a -> s -> s) -> Lens' s a
lens getter setter = \cont obj ->
    (\v -> setter v obj) <$> cont (getter obj)
\end{code}

And now we define the operations to run lens as getters and setters on objects:

\begin{code}
view :: Lens s t a b -> s -> a
view l obj = getConst $ l Const obj

update :: Lens s t a b -> (a -> b) -> s -> t
update l f obj = runIdentity $ l (Identity . f) obj

set :: Lens s t a b -> b -> s -> t
set l newValue obj = update l (const newValue) obj
\end{code}

Note that van Laarhoven lenses automatically compose through usual function composition `(.)`,
so we do not need to define a `compose` function.

Finally let us define some operators for syntactic sugar (inspired by `lens` library)

\begin{code}
(&) :: a -> (a -> b) -> b
a & f = f a

(^.) :: s -> Lens s t a b -> a
s ^. l = view l s


(.~) :: Lens s t a b -> b -> s -> t
(.~) l v s = set l v s


(%~) :: Lens s t a b -> (a -> b) -> s -> t
(%~) l f s = update l f s

infixl 8 ^.
infixr 4 .~, %~
infixl 1 &

\end{code}
