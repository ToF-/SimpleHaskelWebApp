-- ServerT.hs
{-# LANGUAGE OverloadedStrings #-}
module Main where
import Control.Monad
import Happstack.Server
import Text.Blaze 
import qualified Text.Blaze.Html4.Strict as H
import qualified Text.Blaze.Html4.Strict.Attributes as A
import Text.Blaze.Renderer.Utf8 (renderHtml)

hello :: H.Html
hello = H.html $ do H.head $ do H.title "Introduction page."
                    H.link ! A.rel "stylesheet" ! A.type_ "text/css" ! A.href "static/css/screen.css"
                    H.body $ do H.div ! A.id "header" $ "Html rendering"
                                H.p "This is a very simple example of a page written with HtmlBlaze."
                                H.ul $ forM_ [1, 2, 3] (H.li . toMarkup . show)
main :: IO ()
main = do simpleHTTP nullConf 
          $ msum [dir "hello" $ ok $ toResponse $ hello
                 ,dir "static" $ serveDirectory DisableBrowsing [] "static"
                                     ]