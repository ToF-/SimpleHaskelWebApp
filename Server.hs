-- Server.hs
{-# LANGUAGE FlexibleContexts #-}
module Main where
import Control.Monad.Trans
import Control.Concurrent.STM
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response


readAndUpdate :: TVar Integer -> IO Integer
readAndUpdate var = atomically $ do n <- readTVar var
                                    writeTVar var (n+1)
                                    return n


response :: TVar Integer -> ServerPartT IO Response
response counter = do c <- lift $ readAndUpdate counter
                      ok $ toResponse $ "Access count since server started: " ++ (show c)

main :: IO ()
main = do counter <- atomically $ newTVar 0
          simpleHTTP nullConf $ response counter