{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DisambiguateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}

module Codeforces.API where

import Codeforces.Types (User)
import Control.Lens ((.~), (^.))
import Data.Aeson (FromJSON)
import Data.Function ((&))
import Data.Maybe (fromMaybe, listToMaybe)
import Data.Text (Text)
import GHC.Generics (Generic)
import Network.Wreq (asJSON, defaults, getWith, param, responseBody)

newtype UserInfoResponse = UserInfoResponse {result :: [User]}
  deriving anyclass (FromJSON)
  deriving stock (Generic, Show)

userInfo :: Text -> IO User
userInfo usr = do
  resp <-
    getWith
      (defaults & param "handles" .~ [usr])
      "https://codeforces.com/api/user.info"
      >>= asJSON
  let user =
        resp ^. responseBody
          & result
          & listToMaybe
          & fromMaybe (error "Must be at list one user")
  pure user
