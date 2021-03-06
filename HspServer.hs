--HspServer.hs

{-# LANGUAGE FlexibleContexts, OverlappingInstances #-}
{-# OPTIONS_GHC -F -pgmF trhsx #-}

module Main where

import Control.Applicative ((<$>))
import Control.Monad.Identity (Identity(runIdentity))
import Data.String (IsString(fromString))
import Data.Text (Text)
import qualified HSX.XMLGenerator as HSX
import Happstack.Server.HSP.HTML
import Happstack.Server (Request(rqMethod), ServerPartT, askRq, nullConf, simpleHTTP)
import HSP.Identity () -- instance (XMLGen Identity)

hello :: ServerPartT IO XML
hello = unXMLGenT
  <html>
    <head>
      <title>Hello, HSP!</title>
    </head>
    <body>
      <h1>Hello HSP!</h1>
      <p>We can insert Haskell expression such as this: <% sum [1 .. (10::Int)] %></p>
      <p>We can use the ServerPartT monad too. Your request method was: <% getMethod %></p>
      <hr/>
      <p>We don't have to escape & or >. Isn't that nice?</p>
      <p>If we want <% "<" %> then we have to do something funny.</p>
      <p>But we don't to worry about escaping <% "<p>a string like this</p>" %></p>
      <p>We can also nest <% <span>like <% "this." %> </span> %></p>
    </body>
  </html>
    where getMethod :: XMLGenT (ServerPartT IO) String
          getMethod = show . rqMethod <$> askRq

main :: IO ()
main = simpleHTTP nullConf $ hello