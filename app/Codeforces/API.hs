{-# LANGUAGE OverloadedStrings #-}

module Codeforces.API where

import Codeforces.Types
import Control.Monad.IO.Class
import Data.Aeson
import Data.Aeson.KeyMap qualified as Km
import Data.Vector qualified as V
import Network.HTTP.Req

userInfo :: String -> IO User
userInfo usr = runReq defaultHttpConfig $ do
  r <-
    req
      GET
      (http "codeforces.com" /: "api" /: "user.info")
      NoReqBody
      jsonResponse
      (queryParam "handles" $ Just usr)
  let user = checkUser usr $ fromJSON $ V.head $ valToArr $ checkObj $ Km.lookup "result" (responseBody r :: Object)
  liftIO $ return user
  where
    checkUser h (Error _) = User {handle = h, rating = 0}
    checkUser _ (Success a) = a
    checkObj :: Maybe Value -> Value
    checkObj Nothing = Null
    checkObj (Just v) = v
    valToArr :: Value -> Array
    valToArr (Array a) = a
    valToArr _ = V.empty
