import Browser
import Html exposing (Html, Attribute, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

main =
 Browser.sandbox { init = init, update = update, view = view }

-- Model
type alias Model = { content1 : String, content2 : String}
type Msg = Content1 String | Content2 String

init : Model
init = { content1 = "" , content2 = ""}

-- View
view : Model -> Html Msg
view model =
  div []
 [
   input [ placeholder "String 1", value model.content1, onInput Content1 ] [],
   input [ placeholder "String 2", value model.content2, onInput Content2 ] [],
   div [] [ text model.content1, text ":" , text model.content2 ]
 ]

-- Update
update : Msg -> Model -> Model
update msg model =
  case msg of
    Content1 newContent1 -> { model | content1 = newContent1 }
    Content2 newContent2 -> { model | content2 = newContent2 }
