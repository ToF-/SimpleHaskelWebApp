-- Server.hs
{-# LANGUAGE FlexibleContexts #-}
module Main where
import Happstack.Server (nullConf, simpleHTTP, toResponse, ok)
import Happstack.Server.Internal.Types
import Happstack.Server.Internal.Monads
import Happstack.Server.Response


response :: ServerPartT IO Response
response = do let c = 4807
              ok $ toResponse $ "Access Counter: " ++ (show c)

main :: IO ()
main = do
  simpleHTTP nullConf $ response