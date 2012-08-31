--FormServer.hs
{-# LANGUAGE OverloadedStrings #-}
module Main where
import Control.Monad (msum)
import Happstack.Server (ServerPart, Response, nullConf, simpleHTTP, decodeBody,
                         BodyPolicy(..), defaultBodyPolicy, dir, ok, toResponse,
                         Method(POST), look, methodM)
import Text.Blaze                         as B
import Text.Blaze.Html4.Strict            as B hiding (map)
import Text.Blaze.Html4.Strict.Attributes as B hiding (dir, label, title)


myPolicy :: BodyPolicy
myPolicy = (defaultBodyPolicy tempDir maxByteToSave maxByteRAM maxHeaderSize)
  where tempDir = "/tmp/"
        maxByteToSave = 0
        maxByteRAM    = 1000
        maxHeaderSize = 1000 

handlers :: ServerPart Response
handlers = 
  do decodeBody myPolicy
     msum [dir "hello" $ helloPart
          ,helloForm
          ]


helloForm :: ServerPart Response
helloForm = ok $ toResponse $ 
  B.html $ do
    B.head $ do
      B.title "Hello Form"
    B.body $ do
      B.form ! B.enctype "multipart/form-data" ! B.method "POST" ! action "/hello" $ do
         B.label "greeting: " >> input ! B.type_ "text" ! B.name "greeting" ! B.size "10"
         B.label "noun: "     >> input ! B.type_ "text" ! B.name "noun"     ! B.size "10"
         B.input ! B.type_ "submit" ! B.name "upload"


helloPart :: ServerPart Response 
helloPart = 
  do methodM POST
     greeting <- look "greeting"
     noun     <- look "noun"
     ok $ toResponse (greeting ++ ", " ++ noun)

main :: IO ()
main = simpleHTTP nullConf $ handlers


