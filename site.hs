--------------------------------------------------------------------------------



{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid
import           Control.Monad                  ( filterM )
import           Hakyll
import           Text.Pandoc


--------------------------------------------------------------------------------


main :: IO ()
main = hakyllWith config $ do
  -- css, js, images

  match "static/*/*" $ do
    route idRoute
    compile copyFileCompiler

  -- main pages: index, about, contact

  match "markdown-pages/*" $ do
    route $ gsubRoute "markdown-pages/" (const "") `composeRoutes` setExtension
      "html"

    compile $ do
      postList <- loadAll ("projects/*" .&&. hasVersion "meta")
      let projectsCtx =
            listField "projects" siteCtx (return postList) <> siteCtx
      getResourceBody
        >>= applyAsTemplate projectsCtx
        >>= renderPandoc
        >>= loadAndApplyTemplate "templates/page.html"    projectsCtx
        >>= loadAndApplyTemplate "templates/default.html" projectsCtx
        >>= relativizeUrls

  -- project pages for index and project sites like radio, thesis, ...

  match "projects/*" $ version "meta" $ do
    route idRoute
    compile getResourceBody

  match "projects/*" $ do
    route $ gsubRoute "projects/" (const "") `composeRoutes` setExtension "html"

    compile $ do
      postList <- loadAll ("projects/*" .&&. hasVersion "meta")
      let projectsCtx =
            listField "projects" siteCtx (return postList) <> siteCtx

      getResourceBody
        >>= applyAsTemplate projectsCtx
        >>= renderPandoc
        >>= loadAndApplyTemplate "templates/page.html"    projectsCtx
        >>= loadAndApplyTemplate "templates/default.html" projectsCtx
        >>= relativizeUrls

  -- templates to construct everything else

  match "templates/*" $ compile templateCompiler

{- match "posts/*" $ do

  route $ setExtension "html"

  compile

    $   pandocCompiler

    >>= loadAndApplyTemplate "templates/post.html"    postCtx

    >>= loadAndApplyTemplate "templates/default.html" postCtx

    >>= relativizeUrls -}

{-   create ["index.html"] $ do

    route idRoute

    compile $ do

      projects <- recentFirst =<< loadAll "projects/*"

      let projectsCtx =

            listField "projects" siteCtx (return projects)

              <> constField "title" "Hi!"

              <> siteCtx



      makeItem ""

        >>= loadAndApplyTemplate "templates/gallery.html" projectsCtx

        >>= loadAndApplyTemplate "templates/default.html" projectsCtx

        >>= relativizeUrls -}


{-   match "index.html" $ do

      route idRoute

      compile $ do

          posts <- recentFirst =<< loadAll "posts/*"

          let indexCtx =

                  listField "posts" postCtx (return posts) <>

                  -- constField "title" "Home"                <>

                  siteCtx

          getResourceBody

              >>= applyAsTemplate indexCtx

              >>= loadAndApplyTemplate "templates/default.html" indexCtx

              >>= relativizeUrls -}




--------------------------------------------------------------------------------


-- post context with date field

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" <> siteCtx

-- normal site context - used for all pages as of now.

siteCtx :: Context String
siteCtx =
  constField "baseurl" "http://localhost:35730"
    <> constField "site_description"  "benedikt mayer | portfolio"
    <> constField "site_title"        "benedikt mayer | portfolio"
    <> constField "github_username"   "benedikt-mayer"
    <> constField "linkedin_username" "benedikt-mayer-7ab235132"
    <> constField "email_username"    "benedikt_mayer"
    <> constField "email_domain"      "outlook"
    <> constField "email_tld"         "de"
    <> defaultContext

-- configuration for display

config :: Configuration
config = defaultConfiguration { previewHost = "0.0.0.0", previewPort = 35729 }
