Generating and serving random dice throws
\begin{code}
{-# LANGUAGE FlexibleContexts, OverloadedStrings #-}
\end{code}

\begin{code}
module Main where
import Control.Monad
import Control.Monad.Random
import Control.Monad.Trans
import Happstack.Server (ServerPart, Response, nullConf, simpleHTTP, look, ok, toResponse)
import Text.Blaze                         as H
import Text.Blaze.Html4.Strict            as H hiding (map)
import Text.Blaze.Html4.Strict.Attributes as A hiding (dir, label, title)
\end{code}

\begin{code}
die :: (RandomGen g) => Rand g Int
die = getRandomR (1,6)
\end{code}


\begin{code}
dice :: (RandomGen g) => Int -> Rand g [Int]
dice n = sequence (replicate n die)
\end{code}


\begin{code}
dicePage :: [Int] -> Html
dicePage ds = H.html $
   do H.head $ do H.title "Dice"
                  H.link ! A.rel "stylesheet" ! A.type_ "text/css" ! A.href "static/css/dice.css"
      H.body $ do H.div ! A.id "dice" $ H.toMarkup (show ds)
                  H.p "This are the dice throws you asked for." 
\end{code}


 
\begin{code}
handler :: ServerPart Response
handler = do n <- look "throws"
             ds <- lift $ evalRandIO (dice (read n))
             ok $ toResponse $ dicePage ds
\end{code}

\begin{code}
main :: IO ()
main = simpleHTTP nullConf handler
\end{code}
 