Generating and serving random dice throws

We have a function throwing dice, yielding a list of int in 
the RandomGen context.

We render the list through a html list

Serving the main page consists in looking for the parameter "throws" 
in the request, interpret the parameter value, call the generator, 
and render the page. 

build:
 ghc --make -threaded DiceServer.lhs -o bin/diceserver

run:
 bin/diceserver

example:
 http:/localhost:8000/dice?throws=3
 
\begin{code}
{-# LANGUAGE FlexibleContexts, OverloadedStrings #-}

module Main where

import Control.Monad
import Control.Monad.Random
import Control.Monad.Trans
import Happstack.Server (ServerPart, Response, nullConf, simpleHTTP, look, ok, 
                         toResponse, serveDirectory, dir, Browsing(DisableBrowsing))
import Text.Blaze                         as H
import Text.Blaze.Html4.Strict            as H hiding (map)
import Text.Blaze.Html4.Strict.Attributes as A hiding (dir, label, title)

throws :: (RandomGen g) => Int -> Rand g [Int]
throws n = sequence (replicate n (getRandomR(1,6)))

renderThrows :: [Int] -> Html
renderThrows ts = H.div ! A.id "throws" $ mapM_ (H.ul . H.toMarkup) ts

styleSheet :: AttributeValue -> Html
styleSheet s = H.link ! A.rel "stylesheet" ! A.type_ "text/css" ! A.href s

renderDice :: [Int] -> Html
renderDice ts = H.html $
   do H.head $ do H.title "Dice"
                  styleSheet "static/css/dice.css"
      H.body $ do renderThrows ts
                  H.p "These are the dice throws you asked for." 

serveMainPage :: ServerPart Response
serveMainPage = do arg  <- look "throws"
                   let number = case reads arg of
                                  [(n,_)] -> n
                                  []      -> 1
                   ts <- lift $ evalRandIO (throws number)
                   ok $ toResponse $ renderDice ts

handler :: ServerPart Response
handler = msum 
           [dir "dice" $ serveMainPage
           ,dir "static" $ serveDirectory DisableBrowsing [] "static"
           ]

main :: IO ()
main = simpleHTTP nullConf handler

\end{code}