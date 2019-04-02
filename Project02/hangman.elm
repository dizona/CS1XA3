--Import statements
import Browser
import String exposing (toUpper, contains, map, filter)
import Browser.Navigation exposing (Key(..))
import Browser.Events
--Json.Decode used to decode the keys from the keyboard
import Json.Decode as Decode
--import Html exposing (..)
--import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Http
import Url
import List exposing (head, tail)
import Set exposing (Set,insert,member)
import Char exposing (toUpper)
import Random exposing (generate)
import Random.List exposing (shuffle)
import Maybe

main : AppWithTick () Model Msg
main =
    appWithTick Tick
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = MakeRequest
        , onUrlChange = UrlChange
        }

type Msg
 = Tick Float GetKeyState
 | MakeRequest Browser.UrlRequest
 | UrlChange Url.Url
 | Character Char
 | Control String
 | NewWord String
 | Animal
 | Random
 | Food
 | CompSci
 | ShuffledListAnimal (List String)
 | ShuffledListRandom (List String)
 | ShuffledListFood (List String)
 | ShuffledListCompSci (List String)



type alias Model = { size : Float, rads : Float, wordList : String, pressedKeys : Set Char, guesses : Int, randomWords : List String, animalList : List String, foodList : List String, compSciList : List String ,menuResponse : Bool, category : String}

init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key = ( { size = 10.0
                        , rads = 25 --Radius of the circle
                        , wordList = "SNAKE" --Initialize wordList with "SNAKE"
                        , pressedKeys = Set.empty
                        , guesses = 6 --The number of guesses/attempts the user gets
                        , animalList = ["SHARK","TURTLE","BAT","MONKEY","KANGAROO","AARDVARK","FALCON","PENGUIN","ZEBRA","TIGER","LION","RHINOCEROS","DOG","GOAT","ELEPHANT","SQUIRREL","WOLF","OPOSSUM","OCTOPUS","FROG","WHALE","EEL","ELK","RACCOON"]
                        , foodList = ["PIZZA","RICE","CHOCOLATE","BURGER","WATER","SALAD","STEAK","MUSHROOM","BREAD","EGG","CORN","ASPARAGUS","ALMOND","AVOCADO","CABBAGE","CHIMICHANGA","BABAGANOOSH","DUMPLING","SHAWARMA","FALAFEL","PANCAKE","GUACAMOLE","ZUCCHINI","QUESADILLA"]
                        , compSciList = ["BASH","PYTHON","SYNTAX","TYPE","ELM","DJANGO","MALWARE","ERROR","NETWORK","SOFTWARE","INHERITANCE","FUNCTION","ASCII","HEXADECIMAL","RGB","BOOLEAN","COMPILER","KERNEL","DAEMON","DATABASE","EDITOR","HASKELL","HTML","INTERNET"]
                        , randomWords = ["EGG","DIFFICULT","MIDTERM","EXAM","WATERMELON","SCRIPT","PROJECT","AUTOMATIC","FRICTION","TELEKINESIS","VENOMOUS","BUBBLE","DIVERGENT","UNKNOWN","MILITARY","LAUGH","DYSFUNCTIONAL","QUANTUM","WILDERNESS","ENGINEER","PARASITE","BASKETBALL","COCONUT","COMMUNICATE"]
                        , menuResponse = False --This will be used for the menu screen and will be set to true when the user picks a category
                        , category = "Random" --The category is initializred to "Random"
                        }
                        , Cmd.none )


view : Model -> { title : String, body : Collage Msg}
view model =
  let
    title = "Hangman"

    --The first if statement is the menu. It will only run if the user has not picked a category first
    --The second if statement is the game itself. It will run when the user picks a category
    body  = collage 500 500 [if not model.menuResponse then selectMenu else circle 0 |> filled blank
                            , if model.menuResponse then hangmanMain else circle 0 |> filled blank]

    --This is the menu screen where the user will be given a choice on what category they want to de
    selectMenu = group [ text "Hangman" |> size 20 |> filled black |> move (-40.0,220) --Title at the top of the page
                       , centered (text "Select a category") |> size 15 |> filled black |> move (0, 200) --Telling the user to select a category located below the title
                       , centered (text "Animals") |> size 15 |> filled black |> move (-80,95) --Animals
                       , notifyMouseUp Animal (roundedRect 100 40 2 |> filled blank |> addOutline (solid 2) black |> move (-80, 100)) -- Checks if the user clicks on Animal
                       , centered (text "Random") |> size 15 |> filled black |> move (-80,45) --Random
                       , notifyMouseUp Random (roundedRect 100 40 2 |> filled blank |> addOutline (solid 2) black |> move (-80, 50)) --Checks if the user clicks on Random
                       , centered (text "Food") |> size 15 |> filled black |> move (80,95) --Food
                       , notifyMouseUp Food (roundedRect 100 40 2 |> filled blank |> addOutline (solid 2) black |> move (80, 100)) --Checks if the user clicks on Food
                       , centered (text "CompSci") |> size 15 |> filled black |> move (80,45) --CompSci
                       , notifyMouseUp CompSci (roundedRect 100 40 2 |> filled blank |> addOutline (solid 2) black |> move (80, 50)) --Checks if the user clicks on CompSci
                       ]

    --This is the hangman game itself
    hangmanMain = group [ text "Hangman" |> size 20 |> filled black |> move (-40.0,220) --Titale at the top of the page
                            , text "Category: " |> size 15 |> filled black |> move (-250, 190) --Text that tells the user the category they picked (incase they forgot)
                            , text model.category |> size 15 |> filled black |> move (-250, 170) --Displays the category picked
                            , centered (text (wordBoxes (model.pressedKeys) (model.wordList))) |> size 20 |> filled black |> move (0, -75) --Prints out the empty boxes which will be filled with letters on the screen using the wordBoxes function
                            , if model.guesses <= 5 then circle model.rads |> outlined (solid 1) black |> move (0,150) else circle 0 |> filled blank --This is the head of the stickman. It will displat if the user guesses wrong
                            , line (0.0,200.0) (100.0,200.0) |> outlined (solid 2) black --Hanging thingy
                            , line (100.0,200.0) (100.0,-10.0) |> outlined (solid 2) black --Hanging thingy
                            , line (0.0,200.0) (0.0,175.0) |> outlined (solid 2) black --Hanging thingy
                            , if model.guesses <= 4 then line (0.0,125.0) (0.0,50.0) |> outlined (solid 2) black else circle 0 |> filled blank -- Body which will be displayed if the user guesses wrong
                            , if model.guesses <= 3 then line (0.0,50.0) (25.0,0.0) |> outlined (solid 2) black else circle 0 |> filled blank--Right leg which will be displayed if the user guesses wrong
                            , if model.guesses <= 2 then line (0.0,50.0) (-25.0,0.0) |> outlined (solid 2) black else circle 0 |> filled blank--Left leg which will be displayed if the user guesses wrong
                            , if model.guesses <= 1 then line (0.0,115.0) (25.0,65.0) |> outlined (solid 2) black  else circle 0 |> filled blank --Right arm which will be displayed if the user guesses wrong
                            , if model.guesses <= 0 then line (0.0,115.0) (-25.0,65.0) |> outlined (solid 2) black else circle 0 |> filled blank --Left arm which will be displayed if the user guesses wrong
                            , if model.guesses <= 0 then text ("The word was: " ++ model.wordList) |> filled black |> move (-60,-50) else circle 0 |> filled blank --If the user exhasts all their guesses it will print the answer
                            , if lose (model.pressedKeys) (model.wordList) && model.guesses <= 0 then text "GAME OVER!" |> size 20 |> filled red |> move (-60, -200) else circle 0 |> filled blank --Tells the user when they are out of guesses. Calls the lose function to check if they lost
                            , if win (model.pressedKeys) (model.wordList) then text "🔥 Winner! 🔥" |> size 20|> filled black |> move (-60,-200) else circle 0 |> filled blank --Tells the user they guessed the word correctly. Calls the win function to check if they got the word correctly
                            , centered (text ("Attempts: " ++ (String.fromInt (model.guesses)))) |> size 15 |> filled black |> move (0,-100) --Displays the number of attempts the user has left
                            , text "Guessed Letters: " |> size 15 |> filled black |> move (-250,-140) --Text that says "Guessed letter"
                            , text (Debug.toString(model.pressedKeys)) |> size 15 |> filled black |> move (-330,-155) --Displays the list of characters the user has entered
                            , centered (text "New Word") |>size 15 |> filled black |> move (0,-225) -- Text that goes voer button that says "New Word"
                            , notifyMouseUp (NewWord model.category) (roundedRect 80 20 2 |> filled blank |> addOutline (solid 2) black |> move (0, -220)) --The button the user clicks on if they want a new word
                            ]

  in { title = title, body = body }

-- The win function checks if the user has entered the correct letters to match the word. Uses the filter function to filter only letters in the word
win : Set Char -> String -> Bool
win set word =
  if (filter (\x -> member x set) (word)) == word then
    True
  else
    False

-- The lose function checks if the user has entered the incorrect letter and will run when their guesses are exhasted. Uses filter to filter any letter not in the word and
lose : Set Char -> String -> Bool
lose set word =
  if (filter (\x -> member x set) (word)) == word then
    False
  else
    True


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
       Tick _ (keys , _ , _) ->
           (model, Cmd.none)

       MakeRequest req ->
           ( model, Cmd.none ) -- do nothing

       UrlChange url ->
           ( model, Cmd.none ) -- do nothing

       Character char ->
         if model.guesses > 0 && not (win (model.pressedKeys) (model.wordList)) && not (member (toUpper char) model.pressedKeys) then --will only run if the user still has guesses and the letter is not in the set yet
           if (contains (String.toUpper (String.fromChar char)) (model.wordList)) && not (member char model.pressedKeys)then -- Checks if the letter is in the word then it will not decrement the guesses
              ({model | pressedKeys = insert (toUpper char) model.pressedKeys},Cmd.none)
           else
              ({model | pressedKeys = insert (toUpper char) model.pressedKeys, guesses = model.guesses - 1},Cmd.none) -- If the letter is not in the word then it will decrement guesses
         else
           (model, Cmd.none)

       Control string ->
           (model, Cmd.none)

       Animal ->
         ({model | menuResponse = True, category = "Animals", wordList = "SNAKE"},generate ShuffledListAnimal (shuffle model.animalList)) -- Runs if the user clicks on the Animal category

       Random ->
         ({model | menuResponse = True, category = "Random", wordList = "PAPER"}, generate ShuffledListRandom (shuffle model.randomWords)) -- Runs if the user clicks on the Random category

       Food ->
         ({model | menuResponse = True, category = "Food", wordList = "CAKE"}, generate ShuffledListFood (shuffle model.foodList)) -- Runs if the user clicks on the Food category

       CompSci ->
         ({model | menuResponse = True, category = "CompSci", wordList = "BINARY"}, generate ShuffledListCompSci (shuffle model.compSciList)) -- Runs if the user clicks on the CompSci category

       ShuffledListAnimal shuffledList ->
         ({model | animalList = shuffledList}, Cmd.none) -- Assigns animalList to the shuffledList

       ShuffledListRandom shuffledList ->
         ({model | randomWords = shuffledList}, Cmd.none) -- Assigns randomWords to the shuffledList

       ShuffledListFood shuffledList ->
         ({model | foodList = shuffledList}, Cmd.none) -- Assigns foodList to the shuffledList

       ShuffledListCompSci shuffledList ->
         ({model | compSciList = shuffledList}, Cmd.none) -- Assigns compSciList to the shuffledList

       -- If the user requests a new word, based on the category, it will restart the game by picking a new word, making guesses = 6 and empty the Set
       NewWord category ->
         if category == "Animals" then
           ({model | guesses = 6, pressedKeys = Set.empty
           , wordList = getHead model.animalList
           , animalList = getTail model.animalList},Cmd.none)

         else if category == "Food" then
           ({model | guesses = 6, pressedKeys = Set.empty
           , wordList = getHead model.foodList
           , foodList = getTail model.foodList},Cmd.none)

         else if category == "CompSci" then
           ({model | guesses = 6, pressedKeys = Set.empty
           , wordList = getHead model.compSciList
           , compSciList = getTail model.compSciList},Cmd.none)

        else
           ({model | guesses = 6, pressedKeys = Set.empty
           , wordList = getHead model.randomWords
           , randomWords = getTail model.randomWords},Cmd.none)

-- Gets the head of the list of words
getHead : List String -> String
getHead xs =
  case head xs of
    Just x -> x
    Nothing -> ""

-- Gets the tail of the list of words
getTail : List String -> List String
getTail list =
  case tail list of
    Just xs -> xs
    Nothing -> [""]

-- Prints the boxes for the the letters. Uses map to see if the letter is in the word and it i it print the letter and if not, print an empty box
wordBoxes : Set Char -> String -> String
wordBoxes set word =
  String.map (\x -> if member x set then
       x
    else
      '☐') (word)

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

-- Checks for when the keyboard is pressed
subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onKeyDown keyDecoder
