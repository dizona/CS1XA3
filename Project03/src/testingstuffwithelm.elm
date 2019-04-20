module Login exposing (main)

import Browser
import Browser.Navigation exposing (load)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String



-- TODO adjust rootUrl as needed


rootUrl =
    "http://localhost:8000/e/dizona/"



-- rootUrl = "https://mac1xa3.ca/e/macid/"


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



{- -------------------------------------------------------------------------------------------
   - Model
   --------------------------------------------------------------------------------------------
-}


type alias Model =
    { name : String, password : String, error : String, newUser : String, newPass : String, confirmPass : String}


type Msg
    = NewName String -- Name text field changed
    | NewPassword String -- Password text field changed
    | GotLoginResponse (Result Http.Error String) -- Http Post Response Received
    | LoginButton -- Login Button Pressed
    | RegisterName String -- Regster username
    | RegisterPassword String --Register password
    | RegisterPasswordConf String --Register password
    | GotRegisterResponse (Result Http.Error String)
    | RegisterButton -- Register button pressed



init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = ""
      , password = ""
      , error = ""
      , newUser = ""
      , newPass = ""
      , confirmPass = ""
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
        [ node "link" [ href "css/style.css", rel "stylesheet" ]
            []
        , div [ class "login-wrap" ]
            [ div [ class "login-html" ]
                [ input [ attribute "checked" "", class "sign-in", id "tab-1", name "tab", type_ "radio" ]
                    []
                , label [ class "tab", for "tab-1" ]
                    [ text "Sign In" ]
                , input [ class "sign-up", id "tab-2", name "tab", type_ "radio" ]
                    []
                , label [ class "tab", for "tab-2" ]
                    [ text "Sign Up" ]
                , div [ class "login-form" ]
                    [ div [ class "sign-in-htm" ]
                        [ div [ class "group" ]
                            [ viewInput "text" "Name" model.name NewName
                            , viewInput "password" "Password" model.password NewPassword
                            ]
                        , div [ class "group" ]
                            [ button [ Events.onClick LoginButton ] [ text "Login" ]
                            , text model.error
                            ]
                        , div [ class "hr" ]
                            []
                        ]
                    , div [ class "sign-up-htm" ]
                        [ div [ class "group" ]
                            [ label [ class "label", for "user" ]
                                [ text "Username" ]
                            , input [ class "input", id "user", type_ "text" ]
                                []
                            ]
                        , div [ class "group" ]
                            [ label [ class "label", for "pass" ]
                                [ text "Password" ]
                            , input [ class "input", attribute "data-type" "password", id "pass", type_ "password" ]
                                []
                            ]
                        , div [ class "group" ]
                            [ label [ class "label", for "pass" ]
                                [ text "Repeat Password" ]
                            , input [ class "input", attribute "data-type" "password", id "pass", type_ "password" ]
                                []
                            ]
                        , div [ class "group" ]
                            [ input [ class "button", type_ "submit", value "Sign Up" ]
                                []
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


loginPost : Model -> Cmd Msg
loginPost model =
    Http.post
        { url = rootUrl ++ "loginapp/loginuser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotLoginResponse
        }

registerPost : Model -> Cmd Msg
registerPost model =
    Http.post
        { url = rootUrl ++ "loginapp/adduser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotLoginResponse --Change this message to register
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
        NewName name ->
            ( { model | name = name }, Cmd.none )

        NewPassword password ->
            ( { model | password = password }, Cmd.none )

        LoginButton ->
            ( model, loginPost model )

        RegisterName newUser ->
            ( { model | newUser = newUser }, Cmd.none )

        RegisterPassword newPass ->
            ( { model | newPass = name }, Cmd.none )

        GotLoginResponse result ->
            case result of
                Ok "LoginFailed" ->
                    ( { model | error = "failed to login" }, Cmd.none )

                Ok _ ->
                    ( model, load ("https://google.ca") )

                Err error ->
                    ( handleError model error, Cmd.none )



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
