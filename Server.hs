-- Server.hs
{-# LANGUAGE FlexibleContexts #-}
module Main where
import Control.Monad.Trans
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response

readCounter :: IO Integer
readCounter = do s <- readFile "counter.txt"
                 let c = (read s)
                 return c

response :: ServerPartT IO Response
response = do c <- lift $ readCounter  -- execute readCounter in the wrapped IO monad
              ok $ toResponse $ "Access Counter: " ++ (show c)

main :: IO ()
main = do
  simpleHTTP nullConf $ response