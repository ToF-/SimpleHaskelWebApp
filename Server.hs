-- Server.hs
{-# LANGUAGE FlexibleContexts #-}

{--

  ghc --make -threaded Server.hs -o bin/server
  to launch server: bin/server                             
  to access server: http://localhost:8000
  refreshing the page increments the counter
  
--}
module Main where
import Control.Monad.Trans (lift)
import Control.Concurrent (MVar, newMVar, takeMVar, putMVar)
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response


readAndIncrement :: MVar Integer -> IO Integer
readAndIncrement var = do n <- takeMVar var  -- wait for it
                          putMVar var (n+1)  -- have other threads wait for it
                          return n


response :: MVar Integer -> ServerPartT IO Response
response counter = do c <- lift $ readAndIncrement counter
                      ok $ toResponse $ "Access count since server started: " ++ (show c)

main :: IO ()
main = do counter <- newMVar 0
          simpleHTTP nullConf $ response counter