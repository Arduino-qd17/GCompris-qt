/* GCompris - Oware.qml
 *
 * Copyright (C) 2017 Divyam Madaan <divyam3897@gmail.com>
 *
 * Authors:
 *   Frederic Mazzarol (GTK+ version)
 *   Divyam Madaan <divyam3897@gmail.com> (Qt Quick port)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.6
import GCompris 1.0

import "../../core"
import "oware.js" as Activity
import "."

ActivityBase {
    id: activity

    property bool twoPlayer: false
    property bool horizontalLayout: (background.width > background.height) ? true : false
    onStart: focus = true
    onStop: {}

    pageComponent: Image {
        id: background
        anchors.fill: parent
        source: "qrc:/gcompris/src/activities/guesscount/resource/backgroundW01.svg"
        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property alias bar: bar
            property alias bonus: bonus
            property alias cellGridRepeater: cellGridRepeater
            property bool playerOneTurn: true
            property int playerOneScore: 0
            property int playerTwoScore: 0
            property alias playerOneLevelScore: playerOneLevelScore
            property alias playerTwoLevelScore: playerTwoLevelScore
            property alias boardModel: boardModel
            property bool computerTurn: false
            property var currentMove
            property var player
            property int indexValue
        }

        onStart: { Activity.start(items,twoPlayer) }
        onStop: { Activity.stop() }

        // Timer to trigger computer move
        Timer {
            id: trigComputerMove
            repeat: false
            interval: 600
            onTriggered: Activity.computerMove()
        }

        Item {
            id: boardModel
            width: parent.width * 0.7
            height: width * 0.4
            z: 2
            anchors.centerIn: parent
            rotation: horizontalLayout ? 0 : 90

            Image {
                id: board
                source: Activity.url + "/owareBoard.png"
                anchors.fill: parent
            }

            Rectangle {
                id: playerOneBorder
                height: 5
                width: parent.width/4
                color: "orange"
                anchors.top: board.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 6
            }

            Rectangle {
                id: playerTwoBorder
                height: 5
                width: parent.width/4
                color: "blue"
                anchors.bottom: board.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 5
            }

            // Grid of houses with 6 houses for each player
            Grid {
                id: boardGrid
                columns: 6
                rows: 2
                anchors.horizontalCenter: board.horizontalCenter
                anchors.top: board.top

                Repeater {
                    id: cellGridRepeater
                    model: 12

                    Rectangle {
                        id: house
                        color: "transparent"
                        height: board.height/2
                        width: board.width * (1/6.25)
                        property real circleRadius: width
                        property int value
                        property var nextMove

                        GCText {
                            text: value
                            color: "white"
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            z: 2
                            rotation:  (background.width > background.height) ? 0 : 270
                            fontSize: smallSize
                        }

                        MouseArea {
                            id: buttonClick
                            anchors.fill: parent
                            onPressed: {
                                items.indexValue = index
                                items.currentMove = items.playerOneTurn ? (index - 6) : (11 - index)
                                items.player = items.playerOneTurn ? 0 : 1
                                if ((!items.computerTurn && items.playerOneTurn && (items.currentMove >= 0 && items.currentMove <= 5) && Activity.isValidMove(items.currentMove,1,Activity.house)) || (!items.playerOneTurn && (items.currentMove >= 6 && items.currentMove <= 11) && Activity.isValidMove(items.currentMove,0,Activity.house)) && Activity.house[items.currentMove] != 0) {
                                    firstMove()
                                    items.playerOneTurn = !items.playerOneTurn
                                    Activity.seedsExhausted(Activity.house,0,Activity.scoreHouse)
                                }
                            }
                        }

                        function firstMove() {
                            items.boardModel.enabled = false
                            /* If the indexValue on which player has clicked is between 6 and 11 then the first move will be towards right. */
                            if(items.indexValue >= 6 && items.indexValue < 11)
                                nextMove = "right"
                            /* Else if the indexValue on which player has clicked is 11 then first move will be up */
                            else if(items.indexValue == 11)
                                nextMove = "up"
                            /* Similarly if the indexValue on which player has clicked is between 0 and 5 then first move will be left and if equal to 0 then it will be down. */
                            else if(items.indexValue > 0 && items.indexValue <= 5)
                                nextMove = "left"
                            else if(items.indexValue == 0)
                                nextMove = "down"
                            for(var i = 0; i < grainRepeater.count; i++) {
                                grainRepeater.itemAt(i).startAnimation()
                            }
                        }

                        Repeater {
                            id: grainRepeater
                            model: value
                            z: 1

                            Image {
                                id: grain
                                source: Activity.url + "grain2.png"
                                height: circleRadius * 0.2
                                width: circleRadius * 0.2
                                x: circleRadius/2 + Activity.getX(circleRadius/6, index,value)
                                y: circleRadius/2 + Activity.getY(circleRadius/5, index,value)

                                property int currentIndex: index
                                property int currentSeeds: grainRepeater.count
                                // moveCount is the current index of the moving seed wrt board.
                                property int moveCount: items.indexValue
                                signal checkAnimation

                                Timer {
                                    id: moveSeedsTimer
                                    repeat: false
                                    interval: 500
                                    onTriggered: Activity.setValues(Activity.house)
                                }

                                onCheckAnimation: {
                                    if(!currentSeeds) {
                                        grainRepeater.itemAt(index).source = Activity.url + "grain2.png"
                                        Activity.sowSeeds(items.currentMove,Activity.house,Activity.scoreHouse,items.player)
                                        moveSeedsTimer.start()
                                        if(!twoPlayer && !items.playerOneTurn)  {
                                            items.computerTurn = true
                                            trigComputerMove.start()
                                            items.playerOneTurn = !items.playerOneTurn
                                        }
                                    }
                                }

                                function startAnimation() {
                                    grainRepeater.itemAt(index).source = Activity.url + "grain.png"
                                    for(var i = 0; i < grainRepeater.count; i++) {
                                        grainRepeater.itemAt(index).z = 2
                                    }

                                    if(currentIndex >= 0 && currentSeeds > 0) {
                                        if(nextMove == "right" && currentIndex >= 0)
                                            xRightAnimation.start()
                                        else if(nextMove == "up" && currentIndex >= 0)
                                            yUpAnimation.start()
                                        else if(nextMove == "left")
                                            xLeftAnimation.start()
                                        else if(nextMove == "down" && currentIndex >= 0)
                                            yDownAnimation.start()
                                    }
                                    checkAnimation()
                                }

                                property var xLeftAnimation: NumberAnimation {
                                    target: grain
                                    properties: "x"
                                    from: x ;to: x - (0.15 * board.width)
                                    duration: 450
                                    onStopped: {
                                        if(currentIndex >= 0 && currentSeeds > 0) {
                                            currentSeeds--
                                            currentIndex--;
                                            moveCount--
                                            if(moveCount > 0 && moveCount < 6)
                                                nextMove = "left"
                                            else if(moveCount == 0)
                                                nextMove = "down"
                                            startAnimation()
                                        }
                                    }
                                }

                                property var xRightAnimation: NumberAnimation {
                                    target: grain
                                    properties: "x"
                                    from: x ;to: x + (0.15 * board.width)
                                    duration: 450
                                    onStopped: {
                                        if(currentIndex >= 0 && currentSeeds > 0) {
                                            currentSeeds--
                                            currentIndex--
                                            moveCount++
                                            if(moveCount >= 6 && moveCount < 11)
                                                nextMove = "right"
                                            else if(moveCount == 11)
                                                nextMove = "up"
                                            startAnimation()
                                        }
                                    }
                                }

                                property var yUpAnimation: NumberAnimation {
                                    target: grain
                                    properties: "y"
                                    from: y; to: y - 0.5 * board.height
                                    duration: 350
                                    onStopped: {
                                        if(currentIndex >= 0 && currentSeeds > 0) {
                                            currentSeeds--
                                            currentIndex--
                                            moveCount = 5
                                            nextMove = "left"
                                            startAnimation()
                                        }
                                    }
                                }

                                property var yDownAnimation: NumberAnimation {
                                    target: grain
                                    properties: "y"
                                    loops: 1
                                    from: y; to: y + 0.5 * board.height
                                    duration: 350
                                    onStopped: {
                                        if(currentIndex >= 0 && currentSeeds > 0) {
                                            currentSeeds--
                                            currentIndex--
                                            moveCount = 6
                                            nextMove = "right"
                                            startAnimation()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Image {
                id: playerOneScoreBox
                height: board.height * 0.5
                width: height
                source:Activity.url+"/score.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: boardModel.left

                Flow {
                    width: board.width * (1/7.25)
                    height: parent.height
                    anchors.centerIn: parent

                    Repeater {
                        id: playerOneScoreRepeater
                        model: items.playerOneScore

                        Image {
                            id: playerOneSeedsImage
                            source: Activity.url + "grain2.png"
                            height: board.width * (1 / 7.25) * 0.2
                            width: board.width * (1 / 7.25) * 0.2
                            x: parent.width/2 + Activity.getX(parent.width/6, index,items.playerOneScore)
                            y: parent.width/2 + Activity.getY(parent.width/5, index,items.playerOneScore)
                        }
                    }
                }

                GCText {
                    id: playerOneScoreText
                    color: "white"
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: smallSize
                    text: items.playerOneScore
                    horizontalAlignment: Text.AlignHCenter
                    rotation:  (background.width > background.height) ? 0 : 270
                    wrapMode: TextEdit.WordWrap
                }
            }

            Image {
                id: playerTwoScore
                height: board.height * 0.5
                width: height
                source:Activity.url+"/score.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: boardModel.right

                Flow {
                    width: board.width * (1/7.25)
                    height: parent.height
                    anchors.centerIn: parent

                    Repeater {
                        id: playerTwoScoreRepeater
                        model: items.playerTwoScore
                        Image {
                            id: playerTwoSeedsImage
                            source: Activity.url + "grain2.png"
                            height: board.width * (1 / 7.25) * 0.2
                            width: board.width * (1 / 7.25) * 0.2
                            x: parent.width/2 + Activity.getX(parent.width/6, index,items.playerTwoScore)
                            y: parent.width/2 + Activity.getY(parent.width/5, index,items.playerTwoScore)
                        }
                    }
                }

                GCText {
                    id: playerTwoScoreText
                    color: "white"
                    fontSize: smallSize
                    text: items.playerTwoScore
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    rotation:  (background.width > background.height) ? 0 : 270
                    wrapMode: TextEdit.WordWrap
                }
            }
        }

        Image {
            id: tutorialImage
            source: "qrc:/gcompris/src/activities/guesscount/resource/backgroundW01.svg"
            anchors.fill: parent
            z: 5
            visible: twoPlayer ? false : true
            Tutorial {
                id:tutorialSection
                tutorialDetails: Activity.tutorialInstructions
                onSkipPressed: {
                    Activity.initLevel()
                    tutorialImage.z = 0
                    playerOneLevelScore.beginTurn()
                }
            }
        }

        ScoreItem {
            id: playerOneLevelScore
            player: 1
            height: Math.min(background.height/7, Math.min(background.width/7, bar.height * 1.05))
            width: height * 11/8
            playerScore: 0
            anchors {
                top: background.top
                topMargin: 5
                left: background.left
                leftMargin: 5
            }
            playerImageSource: "qrc:/gcompris/src/activities/align4-2players/resource/player_1.svg"
            backgroundImageSource: "qrc:/gcompris/src/activities/align4-2players/resource/score_1.svg"
        }

        ScoreItem {
            id: playerTwoLevelScore
            player: 2
            height: Math.min(background.height/7, Math.min(background.width/7, bar.height * 1.05))
            width: height * 11/8
            playerScore: 0
            anchors {
                top: background.top
                topMargin: 5
                right: background.right
                rightMargin: 5
            }
            playerImageSource: "qrc:/gcompris/src/activities/align4-2players/resource/player_2.svg"
            backgroundImageSource: "qrc:/gcompris/src/activities/align4-2players/resource/score_2.svg"
            playerScaleOriginX: playerTwoLevelScore.width
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: twoPlayer ? (help | home | reload) : (tutorialSection.visible ?
                                                                                       (help | home) : (help | home | level | reload)) }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
            onReloadClicked: Activity.reset()
        }

        Bonus {
            id: bonus
        }
    }
}