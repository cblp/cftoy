{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Codeforces.API as API
import qualified Codeforces.Types as T
import Control.Applicative
import Control.Monad.IO.Class
import Data.Text
import qualified Data.Text as Text
import Telegram.Bot.API
import Telegram.Bot.Simple
import Telegram.Bot.Simple.UpdateParser

type Handle = Text

data Model = Model {}

initialModel :: Model
initialModel = Model {}

data Action
  = Start
  | GetInfo Handle
  deriving (Show, Read)

todoBot3 :: BotApp Model Action
todoBot3 =
  BotApp
    { botInitialModel = initialModel,
      botAction = flip updateToAction,
      botHandler = handleAction,
      botJobs = []
    }
  where
    updateToAction :: Model -> Update -> Maybe Action
    updateToAction _ =
      parseUpdate $
        Start <$ command "start"
          <|> GetInfo <$> command "info"
          <|> callbackQueryDataRead

    handleAction :: Action -> Model -> Eff Action Model
    handleAction action model = case action of
      Start ->
        model <# do
          reply
            (toReplyMessage startMessage)
      GetInfo handle ->
        model <# do
          usr <- liftIO $ API.userInfo $ unpack handle
          replyText $ pack $ "User with handle " ++ T.handle usr ++ " has rating " ++ show (T.rating usr)
    startMessage =
      Text.unlines
        ["Hello! I am your Codeforces helper bot"]

run :: Token -> IO ()
run token = do
  env <- defaultTelegramClientEnv token
  startBot_ (conversationBot updateChatId todoBot3) env

main :: IO ()
main = do
  putStrLn "Please, enter Telegram bot's API token:"
  token <- Token . Text.pack <$> getLine
  run token
