{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module Codeforces.Types where

import Data.Aeson
import GHC.Generics

data Contest = Contest {id :: Integer, name :: String} deriving (Show, Generic, FromJSON)

data User = User {handle :: String, rating :: Int} deriving (Show, Generic, FromJSON)
