List Zipper
============

\begin{code}
module ListCursor where

import Data.List.NonEmpty (NonEmpty((:|)))
\end{code}

We implement a straightforward list zipper which allows us to go through an input stream

\begin{code}
data ListCursor a = ListCursor
    { prev :: [a]
    , curr :: a
    , next :: [a]
    } 
\end{code}

Constructing a list zipper from a list is really easy, but the list must be non empty!
\begin{code}
cursor :: NonEmpty a -> ListCursor a
cursor (x :| xs) = ListCursor [] x xs
\end{code}

We want predicates telling us whether there is more data:

\begin{code}
hasNext :: ListCursor a -> Bool
hasNext (ListCursor _ _ n) = not (null n)
\end{code}

We also want to move the cursor, be careful to first check if there is at least a next element!

\begin{code}
moveNext :: ListCursor a -> ListCursor a
moveNext (ListCursor p c n) = ListCursor (c : p) (head n) (tail n)
\end{code}

Finally, we are interested in getting the whole list before the current position:

(Remember that the previous elements are stored in reverse order in the prev list)

\begin{code}
prefix :: ListCursor a -> [a]
prefix (ListCursor p _ _) = reverse p
\end{code}
