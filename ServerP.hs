-- ServerP.hs
{-# LANGUAGE FlexibleContexts, OverloadedStrings #-}


{--

  ghc --make -threaded ServerP.hs -o bin/serverp
  to launch server: bin/serverp  
  bin/data.txt should contain the access count before launching
  echo "0" >bin/data.txt to reinitialize count                             
  to access server: http://localhost:8000
  refreshing the page increments the counter
  the counter persists between shutdowns
--}

module Main where
import Control.Monad.Trans (lift)
import Control.Monad (msum)
import Control.Concurrent (MVar, newMVar, takeMVar, putMVar)
import qualified System.IO.Strict as S (readFile)
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok, dir, serveDirectory, 
                         Browsing(DisableBrowsing))
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response
import Text.Blaze 
import qualified Text.Blaze.Html4.Strict as H
import qualified Text.Blaze.Html4.Strict.Attributes as A
import Text.Blaze.Renderer.Utf8 (renderHtml)

fileName = "./bin/data.txt"

-- strict reading, because file will be written afterwards
readCounter :: IO Integer 
readCounter = S.readFile fileName >>= return . read 

updateCounter :: Integer -> IO ()
updateCounter = (writeFile fileName) . show 

getAndIncrement :: MVar Bool -> IO Integer
getAndIncrement var = do n <- takeMVar var -- another thread will have to wait
                         c <- readCounter
                         updateCounter (c+1)
                         putMVar var True -- freed for another thread to take
                         return c

response :: MVar Bool -> ServerPartT IO Response
response t = do c <- lift $ getAndIncrement t
                ok $ toResponse $  mainPage c

mainPage :: Integer -> H.Html
mainPage c = H.html $ 
  do H.head $ do H.title "Access Counter"
                 H.link ! A.rel "stylesheet" ! A.type_ "text/css" ! A.href "static/css/main.css"
     H.body $ do H.div ! A.id "header" $ H.toMarkup (show c)
                 H.p "This is the number of access since server release."
main :: IO ()
main = do t <- newMVar True -- whatever value will do 
          simpleHTTP nullConf $ msum 
           [dir "main" $ response t
           ,dir "static" $ serveDirectory DisableBrowsing [] "static"
           ]
