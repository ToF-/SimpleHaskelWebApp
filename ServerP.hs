-- ServerP.hs
{-# LANGUAGE FlexibleContexts #-}

{--

  ghc --make -threaded ServerP.hs -o bin/serverp
  echo "0" >bin/data.txt
  to launch server: bin/serverp                              
  to access server: http://localhost:8000
  refreshing the page increments the counter
  the counter persists between shutdowns
  
--}
module Main where
import Control.Monad.Trans (lift)
import Control.Concurrent (MVar, newMVar, takeMVar, putMVar)
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response


readAndUpdateCounter :: MVar Integer -> IO Integer
readAndUpdateCounter var = do n <- takeMVar var
                              putMVar var (n+1)
                              return n


response :: MVar Integer -> ServerPartT IO Response
response token = do c <- lift $ readAndUpdateCounter token
                    ok $ toResponse $ "Access count since server started: " ++ (show c)

main :: IO ()
main = do token <- newMVar 0 
          simpleHTTP nullConf $ response token