module Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Events exposing (..)
import Uuid
import Random.Pcg exposing (Seed, initialSeed, step)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias User =
    { token : String
    , upVoteList : List String
    , downVoteList : List String
    }


initUser : User
initUser =
    User "" [] []


type alias Question =
    { id : String, question : String, rating : Int }


initQuestions : List Question
initQuestions =
    []


type alias Model =
    { user : User
    , questions : List Question
    , query : String
    , seed : Seed
    }


initModel : Model
initModel =
    Model initUser initQuestions "" (initialSeed 1234)


init : ( Model, Cmd Msg )
init =
    initModel ! [ Cmd.none ]



-- Update


type alias QuestionId =
    String


type Msg
    = Index
    | InputQuery String
    | SubmitQuestion
    | UpVote QuestionId
    | DownVote QuestionId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Index ->
            model ! [ Cmd.none ]

        InputQuery query ->
            { model | query = query } ! [ Cmd.none ]

        SubmitQuestion ->
            let
                ( newUuid, newSeed ) =
                    Random.Pcg.step Uuid.uuidGenerator model.seed

                newQuestion =
                    { id = Uuid.toString newUuid, question = model.query, rating = 0 }

                newQuestionList =
                    newQuestion :: model.questions
            in
                { model
                    | query = ""
                    , questions = newQuestionList
                    , seed = newSeed
                }
                    ! [ Cmd.none ]

        UpVote questionId ->
            case isAlreadyUpVoted model.user questionId of
                False ->
                    let
                        score =
                            case isAlreadyDownVoted model.user questionId of
                                True ->
                                    2

                                False ->
                                    1

                        newQuestionList =
                            changeQuestionRatingBy model.questions questionId score

                        newUpVoteList =
                            questionId :: model.user.upVoteList

                        newDownVoteList =
                            model.user.downVoteList
                                |> List.filter ((/=) questionId)

                        newUser =
                            { token = model.user.token
                            , upVoteList = newUpVoteList
                            , downVoteList = newDownVoteList
                            }
                    in
                        { model | questions = newQuestionList, user = newUser } ! [ Cmd.none ]

                True ->
                    let
                        newQuestionList =
                            changeQuestionRatingBy model.questions questionId (-1)

                        newUpVoteList =
                            model.user.upVoteList
                                |> List.filter ((/=) questionId)

                        tempUser =
                            model.user

                        newUser =
                            { tempUser | upVoteList = newUpVoteList }
                    in
                        { model | questions = newQuestionList, user = newUser } ! [ Cmd.none ]

        DownVote questionId ->
            case isAlreadyDownVoted model.user questionId of
                False ->
                    let
                        score =
                            case isAlreadyUpVoted model.user questionId of
                                True ->
                                    (-2)

                                False ->
                                    (-1)

                        newQuestionList =
                            changeQuestionRatingBy model.questions questionId score

                        newUpVoteList =
                            model.user.upVoteList
                                |> List.filter ((/=) questionId)

                        newDownVoteList =
                            questionId :: model.user.downVoteList

                        newUser =
                            { token = model.user.token
                            , upVoteList = newUpVoteList
                            , downVoteList = newDownVoteList
                            }
                    in
                        { model | questions = newQuestionList, user = newUser } ! [ Cmd.none ]

                True ->
                    let
                        newQuestionList =
                            changeQuestionRatingBy model.questions questionId 1

                        newDownVoteList =
                            model.user.downVoteList
                                |> List.filter ((/=) questionId)

                        tempUser =
                            model.user

                        newUser =
                            { tempUser | downVoteList = newDownVoteList }
                    in
                        { model | questions = newQuestionList, user = newUser } ! [ Cmd.none ]


isAlreadyUpVoted : User -> QuestionId -> Bool
isAlreadyUpVoted user questionId =
    List.member questionId user.upVoteList


isAlreadyDownVoted : User -> QuestionId -> Bool
isAlreadyDownVoted user questionId =
    List.member questionId user.downVoteList


changeQuestionRatingBy : List Question -> QuestionId -> Int -> List Question
changeQuestionRatingBy questions questionId score =
    let
        updateFn q =
            if q.id == questionId then
                { q | rating = q.rating + score }
            else
                q
    in
        questions
            |> List.map updateFn



-- View


view : Model -> Html.Html Msg
view model =
    div []
        [ viewMenu
        , div
            [ class "ui main text container"
            , style [ ( "margin-top", "5%" ) ]
            ]
            [ viewQuestionForm model
            , viewQuestions model
            ]
        ]


viewQuestions : Model -> Html.Html Msg
viewQuestions model =
    model.questions
        |> List.sortBy (\x -> -x.rating)
        |> List.map (viewQuestion model.user)
        |> div [ style [ ( "margin-top", "5%" ) ] ]


viewQuestion : User -> Question -> Html.Html Msg
viewQuestion user question =
    let
        arrowStyle =
            style
                [ ( "font-size", "3em" )
                , ( "color", "black" )
                ]

        questionStyle =
            style
                [ ( "font-size", "1.5em" )
                , ( "margin-left", "1.5em" )
                , ( "display", "flex" )
                , ( "flex-wrap", "wrap" )
                , ( "width", "100%" )
                ]

        infoStyle =
            style
                [ ( "float", "left" )
                , ( "clear", "left" )
                , ( "margin-top", "0%" )
                ]

        ratingStyle =
            style
                [ ( "text-align", "center" )
                , ( "font-weight", "bold" )
                , ( "font-size", "1.5em" )
                ]

        isUpVoted =
            List.member question.id user.upVoteList

        isDownVoted =
            List.member question.id user.downVoteList

        upVoteButton =
            let
                textMessage =
                    if isUpVoted then
                        "Cancel"
                    else
                        "Like"

                buttonClass =
                    if isUpVoted then
                        class "fluid ui primary button"
                    else
                        class "fluid ui button"
            in
                div []
                    [ button
                        [ buttonClass
                        , onClick (UpVote question.id)
                        ]
                        [ text textMessage ]
                    ]

        downVoteButton =
            let
                textMessage =
                    if isDownVoted then
                        "Cancel"
                    else
                        "Dislike"

                buttonClass =
                    if isDownVoted then
                        class "fluid ui primary button"
                    else
                        class "fluid ui button"
            in
                div []
                    [ button
                        [ buttonClass
                        , onClick (DownVote question.id)
                        ]
                        [ text textMessage ]
                    ]

        ratingShow =
            div [ ratingStyle ] [ text <| toString question.rating ]
    in
        div [ class "ui segment", style [ ( "display", "flex" ) ] ]
            [ div [ infoStyle ]
                [ upVoteButton
                , ratingShow
                , downVoteButton
                ]
            , div [ class "question wrapword", questionStyle ] [ text question.question ]
            ]


viewQuestionForm : Model -> Html.Html Msg
viewQuestionForm model =
    div [] [ formQuestion model ]


formQuestion : Model -> Html.Html Msg
formQuestion model =
    Html.form [ class "ui form", onSubmit SubmitQuestion ]
        [ div [ class "field" ]
            [ input [ type_ "text", placeholder "Ask a question", value model.query, onInput InputQuery ] []
            ]
        ]


viewMenu : Html.Html Msg
viewMenu =
    div [ class "ui fixed inverted menu" ]
        [ div [ class "ui container" ]
            [ a [ class "header item" ] [ text "Project Name" ]
            , a [ class "item", href "#" ] [ text "Home" ]
            ]
        ]



-- Sub


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
