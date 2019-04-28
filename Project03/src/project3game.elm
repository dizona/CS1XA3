import Browser
import Browser.Navigation exposing (load)
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Encode as JEncode
import String
import Task
import Time
import Maybe
import List exposing (head, tail)
import Random.List exposing (shuffle)
import Random exposing (generate)




-- TODO adjust rootUrl as needed


rootUrl =
    "http://mac1xa3.ca/e/dizona/"



-- rootUrl = "https://mac1xa3.ca/e/macid/"


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



{- -------------------------------------------------------------------------------------------
   - Model
   --------------------------------------------------------------------------------------------
-}


type alias Model =
    { name : String, password : String, error : String, zone : Time.Zone, time : Time.Posix, tickCounter : Int, start : Bool, pressed : Bool
    , points : Int, userWord : String, wordList : List String, word : String, originalList : List String, uname : String, save : String, yourScore : String}


type Msg
    = NewName String -- Name text field changed
    | NewPassword String -- Password text field changed
    | GotLoginResponse (Result Http.Error String) -- Http Post Response Received
    | StartReset --Start/Reset button
    | Tick Time.Posix --Tick used from time
    | AdjustTimeZone Time.Zone --Adjusts the time zone
    | Character Char --For when a character on the keyboard is pushed
    | Control String --When anything except and letter or number is pushed
    | ShuffledList (List String) --Shuffles the list
    | GotUserName (Result Http.Error String) --For getting the username
    | GotScore (Result Http.Error String) --For getting the score of the user
    | Logout --Logout button
    | PostScore --For the post score button
    | SaveResponse (Result Http.Error String) --Checks if the score posted was saved


init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = ""
      , password = ""
      , error = ""
      , zone = Time.utc
      , time = (Time.millisToPosix 0)
      , tickCounter = 30
      , start  = False
      , pressed = True
      , points = 0
      , userWord = ""
      , originalList = ["BABOON", "INFORMATION", "CLIENT","PROBLEM","EDUCATION","HYPOTHESIS","GHOST","MACHINERY","ROCKET","SALVATION","CONTROL","CRISIS","JACKET","DENIAL","DECIMAL","CRITICISM","GRADUAL","CONSIDERATION","VICTORY","SUPPLY"
                        ,"GLORY","HOROSCOPE","GLACIER","PREDICT","BASKETBALL","FOOTBALL","PROFILE","HIGH","GRAVEL","CATCH","CANDIDATE","PILOT","GENERAL","SHOCK","SOLUTION","WORTH","JUSTIFY","MYSTERY","RANGE","EXPRESSION","PARDON","ADMISSION"
                        ,"MORALE","CAREER","AMBITION","APPOINT","ASSIGNMENT","LEAF","MEDIUM","NORTH","PHOTOGRAPHY","SECURITY","LEARN","PREACH","PROSECUTION","ORBIT","COMMENT","CULTURE","EXCEED","BRACKET","TWILIGHT","CREDIBILITY","WEIRD"
                        ,"ACCOMMODATE","CEMETERY","CONSCIENCE","RHYTHM","HANDKERCHIEF","SMILE"]
      , wordList = [""]
      , word = "EGG"
      , uname = ""
      , save = ""
      , yourScore = ""
      }
      , getUserInfo
    )



{- -------------------------------------------------------------------------------------------
   - View
   --------------------------------------------------------------------------------------------
-}

view : Model -> Html Msg
view model =
    div []
    [ node "link" [ href "css2/main.css", rel "stylesheet", type_ "text/css" ]
        []
    , div [class "container"]
    [
      text ("LOGGED IN AS: " ++ model.uname)
    ]
    , div [ class "container-contact100" ]
        [ div [ class "wrap-contact100" ]
            [ div []
                [ span [ class "contact100-form-title" ]
                    [ text "Speed Typer" ]
                , div [ class "container" ]
                    [
                      text "What you type will appear below:"
                    ]
                , div [ class "wrap-input100 validate-input" ]
                    [
                      text model.userWord
                    ]
                , div [ class "container-contact100-form-btn" ]
                    [ button [ class "contact100-form-btn" , Events.onClick StartReset]
                        [ span []
                            [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o m-r-6" ]
                                []
                            , text "Start/reset Timer"
                          ]
                        ]
                    ]
                , div [ class "container" ]
                    [
                      text ("Word:     " ++ model.word)
                    ]
                , div [ class "container" ]
                    [ text ("Points:     " ++ (String.fromInt model.points))
                    ]
                , div [ class "container"]
                    [
                     text ("Time remaining:    " ++ (String.fromInt model.tickCounter))
                    ]
                , div [ class "container-contact100-form-btn" ]
                    [ button [ class "contact100-form-btn", Events.onClick PostScore]
                        [ span []
                            [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o m-r-6" ]
                                []
                            , text "POST SCORE"
                          ]
                        ]
                    ]
                , div [ class "container" ]
                  [
                    text model.save
                  ]
                , div [ class "container" ]
                [
                  text ("Your Highscore: " ++ model.yourScore)
                ]
                ,div [ class "container"]
                [
                  text " "
                ]
                ,div [class "container"]
                [ button [ class "contact100-form-btn" , Events.onClick Logout]
                    [ span []
                        [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o m-r-6" ]
                            []
                        , text "Logout"
                      ]
                    ]
                ]

                ]
            ]
        ]
    ]



{- -------------------------------------------------------------------------------------------
   - JSON Encode/Decode
   -   passwordEncoder turns a model name and password into a JSON value that can be used with
   -   Http.jsonBody
   --------------------------------------------------------------------------------------------
-}


-- passwordEncoder : Model -> JEncode.Value
-- passwordEncoder model =
--     JEncode.object
--         [ ( "username"
--           , JEncode.string model.name
--           )
--         , ( "password"
--           , JEncode.string model.password
--           )
--         ]

--Checks if the user is authenticated before opening up the webpage
getUserInfo : Cmd Msg
getUserInfo =
  Http.get
      { url = rootUrl ++ "loginapp/getuserinfo/"
      , expect = Http.expectString GotLoginResponse
      }

--Retrieves the username of the user logged in
getUserName : Cmd Msg
getUserName =
  Http.get
      { url = rootUrl ++ "loginapp/getusername/"
      , expect = Http.expectString GotUserName
      }

--Retrieves the highest score the user got
getHighscore : Cmd Msg
getHighscore =
  Http.get
     { url = rootUrl ++ "loginapp/getscore/"
     , expect = Http.expectString GotScore
     }

--Logs the user out of the system
logoutUser : Cmd Msg
logoutUser =
  Http.get
      { url = rootUrl ++ "loginapp/logoutuser/"
      , expect = Http.expectString GotLoginResponse
      }

--Posts the score the user gets and saves it into the database
postScore : Model -> Cmd Msg
postScore model =
  Http.post
      { url = rootUrl ++ "loginapp/postscore/"
      , body = Http.jsonBody <| scoreEncoder model
      , expect = Http.expectString SaveResponse
      }

--Encodes the score when it sends it to the database
scoreEncoder : Model ->JEncode.Value
scoreEncoder model =
  JEncode.object
    [ ("score"
      , JEncode.int model.points
      )
    ]

-- getLeaderboard : Cmd Msg
-- getLeaderboard =
--   Http.get
--       { url = rootUrl ++ "loginapp/leaderboard/"
--       , expect = Http.expectString ShowLeaderboard
--       }


{- -------------------------------------------------------------------------------------------
   - Update
   --------------------------------------------------------------------------------------------
-}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --The start/reset button that will reset everything and start/restart the game
        StartReset ->
          if model.pressed then
            ({model | start = True, tickCounter = 30, pressed = False, userWord = "",points = 0, wordList = model.originalList, word = "EGG",save=""}, generate ShuffledList (shuffle model.originalList))
          else
            ({model | pressed = not model.pressed, start = False, tickCounter = 30, userWord = "",points = 0, wordList = model.originalList, word = "EGG",save =""}, generate ShuffledList (shuffle model.originalList))

        --Shuffles the list of words
        ShuffledList shuffledList ->
            ({model | wordList = shuffledList}, Cmd.none)

        NewName name ->
            ( { model | name = name }, Cmd.none )

        NewPassword password ->
            ( { model | password = password }, Cmd.none )

        --Assigns uname to the username of the user and calls on the getHighscore function
        GotUserName result ->
          case result of
              Ok username ->
                  ({ model | uname = username}, getHighscore )

              Err error ->
                  ( handleError model error, Cmd.none )

        --Called form the getHighscore function and assigns the highest score of the user to yourscore
        GotScore result ->
          case result of
            Ok score ->
                  ({model | yourScore = score}, Cmd.none)
            Err error ->
                  ({model | yourScore = "Could not retrieve"}, Cmd.none)

        --Checks if the user is authenticated, when they logout, and if their score is saved
        GotLoginResponse result ->
            case result of
                Ok "Authenticated" ->
                    (model, getUserName)

                Ok "NotAuthenticated" ->
                    ({ model | error = "Not Authenticated"},load("project3.html"))

                Ok "Logout" ->
                    ({ model | error = "Logout"}, load("project3.html"))

                Ok "ScoreSaved" ->
                    ({ model | save = "Score Saved"}, Cmd.none)

                Ok "NotSaved" ->
                    ({model | save = "Score not saved. You have a better score!"}, Cmd.none)

                Ok _ ->
                    ( model, getUserName )

                Err error ->
                    ( handleError model error, Cmd.none )

        --Msg that fires informing the user that if their score saved or not
        SaveResponse result ->
          case result of
            Ok "ScoreSaved" ->
                ({ model | save = "Score Saved"}, Cmd.none)

            Ok "NotSaved" ->
                ({model | save = "Score not saved. You have a better score!"}, Cmd.none)

            Ok _ ->
                ( model, getUserName )

            Err error ->
                ( handleError model error, Cmd.none )

        --Triggers with every Tick and will decrements the tickCounter
        Tick newTime ->
          if model.tickCounter > 0 then
            ( { model | time = newTime, tickCounter = model.tickCounter - 1 } , Cmd.none )
          else
            ({model | start = False}, Cmd.none)

        --Assigns zone the timezone
        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none ) --Command message will be fired to say times up

        --Triggers when a letter is pressed. Tracks the keys and assigns it to userWord. It walso checks if the words match and if they do, points is incremented and a new word is chosen
        Character char ->
            if model.start then
              ({model | userWord = let
                                      a = model.word
                                      b = model.userWord ++ (String.toUpper (String.fromChar char))
                                    in if (a == b) then "" else model.userWord ++ String.toUpper (String.fromChar char)
              , points = let
                           a = model.word
                           b = model.userWord ++ (String.toUpper (String.fromChar char))
                          in if (a == b) then model.points + 1 else model.points
              , word = let
                           a = model.word
                           b = model.userWord ++ (String.toUpper (String.fromChar char))
                          in if (a == b) then (getHead model.wordList) else model.word
              , wordList = let
                              a = model.word
                              b = model.userWord ++ (String.toUpper (String.fromChar char))
                             in if (a == b) then (getTail model.wordList) else model.wordList}, Cmd.none)

            else
              (model, Cmd.none)

        --Checks when anything other than a letter is pressed. When "Backspace" is pressed, the laster letter in userWord is deleted
        Control string ->
            if string == "Backspace" then
              ({model | userWord = String.slice 0 ((String.length model.userWord)-1) model.userWord},Cmd.none) -- Remove last element of the list
            else
              (model,Cmd.none)

        --Triggers when the user clicks the logout button
        Logout ->
          (model, logoutUser)

        --Triggers when the post score button is pressed
        PostScore ->
          (model, postScore model)

--Retrieves the head of the list
getHead : List String -> String
getHead xs =
  case head xs of
    Just x -> x
    Nothing -> ""

--Retrieves the tail of the list
getTail : List String -> List String
getTail list =
  case tail list of
    Just xs -> xs
    Nothing -> [""]


--Checks for time and keyboard events
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [
  if model.start then
    Time.every 1000 Tick
  else
    Sub.none
  ,  Browser.Events.onKeyDown keyDecoder
  ]

-- Decodes the key code from the keyboard
keyDecoder : Decode.Decoder Msg
keyDecoder =
  Decode.map toKey (Decode.field "key" Decode.string)

-- Takes the char of the key which represents what was pressed on the keyboard
toKey : String -> Msg
toKey string =
    case String.uncons string of
        Just ( char, "" ) ->
            Character char

        _ ->
            Control string


--Handles error messages and associates it with the correct response
handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }

        Http.Timeout ->
            { model | error = "timeout" }

        Http.NetworkError ->
            { model | error = "network error" }

        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "bad body " ++ body }
