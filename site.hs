--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc


--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "static/*/*" $ do
        route idRoute
        compile copyFileCompiler

    match (fromList ["about.md", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/page.html" siteCtx
            >>= loadAndApplyTemplate "templates/default.html" siteCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["projects.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let projectsCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Projects"            `mappend`
                    siteCtx

            makeItem ""
                >>= loadAndApplyTemplate "templates/projects.html" projectsCtx
                >>= loadAndApplyTemplate "templates/default.html" projectsCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    siteCtx

siteCtx :: Context String
siteCtx =
    constField "baseurl" "https://benedikt-mayer.github.io" `mappend`
    constField "site_description" "my beautiful page" `mappend`
    constField "github_username" "benedikt-mayer" `mappend`
    constField "linkedin_username" "benedikt-mayer-7ab235132" `mappend`
    defaultContext

config :: Configuration
config = defaultConfiguration
    { previewHost = "0.0.0.0"
    , previewPort          = 8080
    }