import Browser
import Browser.Navigation exposing (load)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String
import Task
import Time




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
    { name : String, password : String, error : String, zone : Time.Zone, time : Time.Posix, tickCounter : Int, start : Bool, pressed : Bool, points : Int}


type Msg
    = NewName String -- Name text field changed
    | NewPassword String -- Password text field changed
    | GotLoginResponse (Result Http.Error String) -- Http Post Response Received
    | LoginButton -- Login Button Pressed
    | StartReset
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone


init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = ""
      , password = ""
      , error = ""
      , zone = Time.utc
      , time = (Time.millisToPosix 0)
      , tickCounter = 60
      , start  = False
      , pressed = True
      , points = 0
      }
      , Cmd.none
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
    , div [ class "container-contact100" ]
        [ div [ class "wrap-contact100" ]
            [ div []
                [ span [ class "contact100-form-title" ]
                    [ text "Type Racer" ]
                , div [ class "wrap-input100 validate-input" ]
                    [ input [ class "input100", name "word", placeholder "", type_ "text" ]
                        []
                    , span [ class "focus-input100" ]
                        []
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
                    [ text "Word:"
                    ]
                , div [ class "container"]
                    [
                     text (String.fromInt model.tickCounter)
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


loginPost : Model -> Cmd Msg
loginPost model =
    Http.post
        { url = rootUrl ++ "userauthapp/loginuser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotLoginResponse
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
            ({model | start = True, tickCounter = 60, pressed = False},Cmd.none)
          else
            ({model | pressed = not model.pressed, start = False, tickCounter = 60}, Cmd.none)


        NewName name ->
            ( { model | name = name }, Cmd.none )

        NewPassword password ->
            ( { model | password = password }, Cmd.none )

        LoginButton ->
            ( model, loginPost model )

        GotLoginResponse result ->
            case result of
                Ok "LoginFailed" ->
                    ( { model | error = "failed to login" }, Cmd.none )

                Ok _ ->
                    ( model, load (rootUrl ++ "static/userpage.html") )

                Err error ->
                    ( handleError model error, Cmd.none )

        Tick newTime ->
          if model.tickCounter > 0 then
            ( { model | time = newTime, tickCounter = model.tickCounter - 1 } , Cmd.none )
          else
            (model, Cmd.none)

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none ) --Command message will be fired to say times up





subscriptions : Model -> Sub Msg
subscriptions model =
  if model.start then
    Time.every 1000 Tick
  else
    Sub.none


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
