--ParameterServer.hs
{-# LANGUAGE FlexibleContexts #-}

module Main
where
import Happstack.Server (ServerPart, look, nullConf, simpleHTTP, ok)

helloPart :: ServerPart String
helloPart = 
  do greeting <- look "greeting"
     noun     <- look "noun"
     ok $ greeting ++ ", " ++ noun

main :: IO ()
main =  simpleHTTP nullConf $ helloPart