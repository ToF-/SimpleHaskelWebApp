--UploadServer.hs
{-# LANGUAGE OverloadedStrings #-}
import Control.Monad                      (msum)
import Happstack.Server                   ( Response, ServerPart, defaultBodyPolicy
                                          , decodeBody, dir, lookFile, nullConf, ok
                                          , simpleHTTP, toResponse )
import Text.Blaze                         as B
import Text.Blaze.Html4.Strict            as B hiding (map)
import Text.Blaze.Html4.Strict.Attributes as B hiding (dir, title)

main :: IO ()
main = simpleHTTP nullConf $ upload

upload :: ServerPart Response
upload =
    do decodeBody (defaultBodyPolicy "/tmp/" (10*10^6) 1000 1000)
       msum [ dir "post" $ post
            , uploadForm
            ]

uploadForm :: ServerPart Response
uploadForm = ok $ toResponse $
    html $ do
      B.head $ do
        title "Upload Form"
      B.body $ do
        form ! enctype "multipart/form-data" ! B.method "POST" ! action "/post" $ do
             input ! type_ "file" ! name "file_upload" ! size "40"
             input ! type_ "submit" ! value "upload"

post :: ServerPart Response
post =
   do r <- lookFile "file_upload"
      ok $ toResponse $
         html $ do
           B.head $ do
             title "Post Data"
           B.body $ mkBody r
    where
      mkBody (tmpFile, uploadName, contentType) = do
                p (toHtml $ "temporary file: " ++ tmpFile)
                p (toHtml $ "uploaded name:  " ++ uploadName)
                p (toHtml $ "content-type:   " ++ show contentType)