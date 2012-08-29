-- ServerP.hs
{-# LANGUAGE FlexibleContexts #-}

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
import Control.Concurrent (MVar, newMVar, takeMVar, putMVar)
import qualified System.IO.Strict as S (readFile)
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response

token = True
fileName = "./bin/data.txt"

-- strict reading, because file will be written afterwards
readCounter :: IO Integer 
readCounter = do s <- S.readFile fileName 
                 return (read s)

updateCounter :: Integer -> IO ()
updateCounter c = writeFile fileName (show c)

getAndIncrement :: MVar Bool -> IO Integer
getAndIncrement var = do n <- takeMVar var -- another thread will have to wait
                         c <- readCounter
                         updateCounter (c+1)
                         putMVar var token -- freed for another thread to take
                         return c

response :: MVar Bool -> ServerPartT IO Response
response t = do c <- lift $ getAndIncrement t
                ok $ toResponse $ "Access count since server release: " ++ (show c)

main :: IO ()
main = do t <- newMVar token 
          simpleHTTP nullConf $ response t