port module Docs exposing (..)

import Html exposing (Html, div, text, h1, img, a, br, span, code, pre, p)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style, src, href, class, classList, id, name)
import Msg exposing (..)
import Common exposing (..)
import Svg.Plot exposing (Point)
import PlotSine
import PlotRangeFrame
import PlotAxis
import PlotBars


-- MODEL


type alias Model =
    { focused : Maybe String
    , hovering : Maybe Point
    }


initialModel : Model
initialModel =
    { focused = Nothing
    , hovering = Nothing
    }


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ focused } as model) =
    case msg of
        FocusExample id ->
            ( { model | focused = updateFocused id focused }, Cmd.none )

        Hover point ->
          { model | hovering = point } ! []


updateFocused : String -> Maybe String -> Maybe String
updateFocused newId model =
    case model of
        Nothing ->
            Just newId

        Just oldId ->
            if oldId == newId then
                Nothing
            else
                Just newId



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "view" ]
        [ div [ class "view--left" ]
            [ h1 [ class "view__title" ] [ text "elm-plot" ]
            , div [ class "view__github-link" ]
                [ a [ href "https://github.com/terezka/elm-plot" ] [ text "github" ]
                , text " / "
                , a [ href "https://twitter.com/terezk_a" ] [ text "twitter" ]
                ]
            ]
        , div [ class "view--right" ] (List.map (viewExample model) (examples model))
        ]


viewExample : Model -> PlotExample Msg -> Html.Html Msg
viewExample model ({ title, id, view, code } as example) =
    div [ class "view-plot" ]
        [ div [ class "view-plot--left" ] [ view ]
        , div [ class "view-plot--right" ] [ viewCode model example ]
        ]


viewHeading : Model -> PlotExample msg -> Html Msg
viewHeading model { title, id } =
    div [ class "view-heading" ]
        [ viewToggler id
        ]


viewToggler : String -> Html.Html Msg
viewToggler id =
    p
        [ class "view-heading__code-open"
        , onClick (FocusExample id)
        ]
        [ text "View source snippet" ]


viewCode : Model -> PlotExample msg -> Html Msg
viewCode model { id, code } =
    div [ class "view-code" ]
        [ Html.code
            [ class "elm view-code__inner" ]
            [ pre [] [ text code ]
            ]
        , viewLink id
        ]


viewLink : String -> Html.Html Msg
viewLink id =
    a
        [ class "view-code__link"
        , href (toUrl id)
        ]
        [ text "See full source" ]




-- View helpers


toUrl : String -> String
toUrl end =
    "https://github.com/terezka/elm-plot/blob/master/docs/" ++ end ++ ".elm"


getVisibility : Model -> String -> List ( String, String )
getVisibility { focused } id =
    if focused == Just id then
        [ ( "display", "block" ) ]
    else
        [ ( "display", "none" ) ]



-- Ports


port highlight : () -> Cmd msg



-- Main


examples : Model -> List (PlotExample Msg)
examples model =
    [ PlotRangeFrame.plotExample
    , PlotSine.plotExample
    , PlotAxis.plotExample
    , PlotBars.plotExample model.hovering
    ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, highlight () )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }
