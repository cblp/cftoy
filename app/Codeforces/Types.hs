{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module Codeforces.Types where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data Contest = Contest {id :: Integer, name :: Text} deriving (Show, Generic, FromJSON)

data User = User {handle :: Text, rating :: Int} deriving (Show, Generic, FromJSON)
