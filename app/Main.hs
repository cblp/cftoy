{-# LANGUAGE DisambiguateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Codeforces.API qualified as API
import Codeforces.Types (Handle)
import Codeforces.Types qualified
import Control.Applicative (asum)
import Control.Monad.IO.Class (liftIO)
import Data.Text qualified as Text
import Telegram.Bot.API
  ( Token (Token),
    Update,
    defaultTelegramClientEnv,
    updateChatId,
  )
import Telegram.Bot.Simple
  ( BotApp (BotApp),
    Eff,
    conversationBot,
    replyText,
    startBot_,
    (<#),
  )
import Telegram.Bot.Simple qualified
import Telegram.Bot.Simple.UpdateParser
  ( callbackQueryDataRead,
    command,
    parseUpdate,
  )

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
        asum
          [ Start <$ command "start",
            GetInfo <$> command "info",
            callbackQueryDataRead
          ]

    handleAction :: Action -> Model -> Eff Action Model
    handleAction action model = case action of
      Start -> model <# replyText startMessage
      GetInfo handle ->
        model <# do
          usr <- liftIO $ API.userInfo handle
          replyText $
            "User with handle "
              <> usr.handle
              <> " has rating "
              <> Text.pack (show usr.rating)

    startMessage = "Hello! I am your Codeforces helper bot"

run :: Token -> IO ()
run token = do
  env <- defaultTelegramClientEnv token
  startBot_ (conversationBot updateChatId todoBot3) env

main :: IO ()
main = do
  putStrLn "Please, enter Telegram bot's API token:"
  token <- Token . Text.pack <$> getLine
  run token
