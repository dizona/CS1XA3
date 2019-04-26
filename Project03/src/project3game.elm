import Browser
import Browser.Navigation exposing (load)
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String
import Task
import Time
import Json.Decode as Decode
import Maybe
import List exposing (head, tail)
import Random.List exposing (shuffle)
import Random exposing (generate)




-- TODO adjust rootUrl as needed


rootUrl =
    "http://localhost:8000/e/macid/"



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
    , points : Int, userWord : String, wordList : List String, word : String, originalList : List String, uname : String}


type Msg
    = NewName String -- Name text field changed
    | NewPassword String -- Password text field changed
    | GotLoginResponse (Result Http.Error String) -- Http Post Response Received
    | LoginButton -- Login Button Pressed
    | StartReset
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | Character Char
    | Control String
    | ShuffledList (List String)
    | GotUserName (Result Http.Error String)


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
      text ("LOGGED IN AS " ++ model.uname)
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
                    [ button [ class "contact100-form-btn"] --Add an Events.onClick Msg
                        [ span []
                            [ i [ attribute "aria-hidden" "true", class "fa fa-paper-plane-o m-r-6" ]
                                []
                            , text "POST SCORE"
                          ]
                        ]
                    ]

                ]
            ]
        ]
    ]


viewInput : String -> String -> String -> (String -> Msg) -> Html Msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, Events.onInput toMsg ] []



{- -------------------------------------------------------------------------------------------
   - JSON Encode/Decode
   -   passwordEncoder turns a model name and password into a JSON value that can be used with
   -   Http.jsonBody
   --------------------------------------------------------------------------------------------
-}


passwordEncoder : Model -> JEncode.Value
passwordEncoder model =
    JEncode.object
        [ ( "username"
          , JEncode.string model.name
          )
        , ( "password"
          , JEncode.string model.password
          )
        ]

--
-- loginPost : Model -> Cmd Msg
-- loginPost model =
--     Http.post
--         { url = rootUrl ++ "userauthapp/loginuser/"
--         , body = Http.jsonBody <| passwordEncoder model
--         , expect = Http.expectString GotLoginResponse
--         }

getUserInfo : Cmd Msg
getUserInfo =
  Http.get
      { url = rootUrl ++ "userauthapp/getuserinfo/"
      , expect = Http.expectString GotLoginResponse
      }

getUserName : Cmd Msg
getUserName =
  Http.get
      { url = rootUrl ++ "userauthapp/getusername/"
      , expect = Http.expectString GotUserName
      }


{- -------------------------------------------------------------------------------------------
   - Update
   -   Sends a JSON Post with currently entered username and password upon button press
   -   Server send an Redirect Response that will automatically redirect to UserPage.html
   -   upon success
   --------------------------------------------------------------------------------------------
-}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartReset ->
          if model.pressed then
            ({model | start = True, tickCounter = 30, pressed = False, userWord = "",points = 0, wordList = model.originalList, word = "EGG"}, generate ShuffledList (shuffle model.originalList))
          else
            ({model | pressed = not model.pressed, start = False, tickCounter = 30, userWord = "",points = 0, wordList = model.originalList, word = "EGG"}, generate ShuffledList (shuffle model.originalList))

        ShuffledList shuffledList ->
            ({model | wordList = shuffledList}, Cmd.none)


        NewName name ->
            ( { model | name = name }, Cmd.none )

        NewPassword password ->
            ( { model | password = password }, Cmd.none )

        LoginButton ->
            ( model, loginPost model )

        GotUserName result ->
          case result of
              Ok username ->
                  ({ model | uname = username}, Cmd.none )

              Err error ->
                  ( {model | uname = "ERROR"}, Cmd.none )

        GotLoginResponse result ->
            case result of
                Ok "Authenticated" ->
                    (model, getUserName)

                Ok "NotAuthenticated" ->
                    (model,load ("https://google.ca"))

                Ok _ ->
                    ( model, load (rootUrl ++ "static/userpage.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        Tick newTime ->
          if model.tickCounter > 0 then
            ( { model | time = newTime, tickCounter = model.tickCounter - 1 } , Cmd.none )
          else
            ({model | start = False}, Cmd.none)

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none ) --Command message will be fired to say times up

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

        Control string ->
            if string == "Backspace" then
              ({model | userWord = String.slice 0 ((String.length model.userWord)-1) model.userWord},Cmd.none) -- Remove last element of the list
            else
              (model,Cmd.none)



getHead : List String -> String
getHead xs =
  case head xs of
    Just x -> x
    Nothing -> ""

getTail : List String -> List String
getTail list =
  case tail list of
    Just xs -> xs
    Nothing -> [""]



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
-- put error message in model.error_response (rendered in view)


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
