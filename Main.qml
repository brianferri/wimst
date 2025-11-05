pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.0
import SddmComponents 2.0

import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: 640
    height: 480

    readonly property color textColor: config.stringValue("basicTextColor")
    property int currentUsersIndex: userModel.lastIndex
    property int currentSessionsIndex: sessionModel.lastIndex
    property int usernameRole: Qt.UserRole + 1
    property int realNameRole: Qt.UserRole + 2
    property int sessionNameRole: Qt.UserRole + 4
    property string currentUsername: config.boolValue("showUserRealNameByDefault")
        ? userModel.data(userModel.index(currentUsersIndex, 0), realNameRole)
        : userModel.data(userModel.index(currentUsersIndex, 0), usernameRole)
    property string currentSession: sessionModel.data(sessionModel.index(currentSessionsIndex, 0), sessionNameRole)
    property string passwordFontSize: config.intValue("passwordFontSize") || 96
    property string usersFontSize: config.intValue("usersFontSize") || 48
    property string sessionsFontSize: config.intValue("sessionsFontSize") || 24
    property string helpFontSize: config.intValue("helpFontSize") || 18
    property string defaultFont: config.stringValue("font") || "monospace"
    property string helpFont: config.stringValue("helpFont") || defaultFont


    function usersCycleSelectPrev() {
        if (currentUsersIndex - 1 < 0) {
            currentUsersIndex = userModel.count - 1;
        } else {
            currentUsersIndex--;
        }
    }

    function usersCycleSelectNext() {
        if (currentUsersIndex >= userModel.count - 1) {
            currentUsersIndex = 0;
        } else {
            currentUsersIndex++;
        }
    }

    function sessionsCycleSelectPrev() {
        if (currentSessionsIndex - 1 < 0) {
            currentSessionsIndex = sessionModel.rowCount() - 1;
        } else {
            currentSessionsIndex--;
        }
    }

    function sessionsCycleSelectNext() {
        if (currentSessionsIndex >= sessionModel.rowCount() - 1) {
            currentSessionsIndex = 0;
        } else {
            currentSessionsIndex++;
        }
    }


    Connections {
        target: sddm
        function onLoginFailed() {
            wrongPasswordAnim.restart()
            // passwordInput.clear();
            passwordInput.readOnly = false
            passwordInput.cursorVisible = true
        }
        function onLoginSucceeded() {
            errorMessage.visible = false
        }

        function onInformationMessage(message) {
            errorMessage.text = message
            errorMessage.visible = true
        }
    }

    Rectangle {
        id: background
        visible: true
        anchors.fill: parent
        color: config.stringValue("backgroundFill") || "transparent"
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        Shortcut {
            sequences: ["Alt+U", "F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+S", "Ctrl+F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectPrev();
            }
        }

        Shortcut {
            sequences: ["Alt+S", "F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+U", "Ctrl+F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectPrev();
            }
        }

        Shortcut {
            sequence: "F10"
            onActivated: {
                if (sddm.canSuspend) {
                    sddm.suspend();
                }
            }
        }
        Shortcut {
            sequence: "F11"
            onActivated: {
                if (sddm.canPowerOff) {
                    sddm.powerOff();
                }
            }
        }
        Shortcut {
            sequence: "F12"
            onActivated: {
                if (sddm.canReboot) {
                    sddm.reboot();
                }
            }
        }

        Shortcut {
            sequence: "F1"
            onActivated: {
                helpMessage.visible = !helpMessage.visible
            }
        }

        TextInput {
            id: passwordInput
            width: parent.width*(config.realValue("passwordInputWidth") || 0.5)
            height: 200/96*root.passwordFontSize
            font.pointSize: root.passwordFontSize
            font.bold: true
            font.letterSpacing: 20/96*root.passwordFontSize
            font.family: root.defaultFont
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            echoMode: config.boolValue("passwordMask") ? TextInput.Password : null
            selectionColor: root.textColor
            selectedTextColor: "#000000"
            clip: true
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            passwordCharacter: config.stringValue("passwordCharacter") || "*"
            cursorVisible: config.boolValue("passwordInputCursorVisible")
            color: passwordInput.readOnly ? "#888888" : (config.stringValue("passwordTextColor") || root.textColor)
            onAccepted: {
                if (text !== "" || config.boolValue("passwordAllowEmpty")) {
                    passwordInput.readOnly = true
                    passwordInput.cursorVisible = false
                    sddm.login(
                        userModel.data(userModel.index(root.currentUsersIndex, 0), root.usernameRole) || "unkown",
                        text,
                        root.currentSessionsIndex
                    );
                }
            }

            Rectangle {
                z: -1
                anchors.fill: parent
                color: config.stringValue("passwordInputBackground") || "transparent"
                radius: config.intValue("passwordInputRadius") || 10
                border.width: config.intValue("passwordInputBorderWidth") || 0
                border.color: config.stringValue("passwordInputBorderColor") || "#ffffff"
            }

            SequentialAnimation {
                id: wrongPasswordAnim
                running: false

                ParallelAnimation {
                    ColorAnimation { target: passwordInput; property: "color"; to: "red"; duration: 100 }
                    SequentialAnimation {
                        NumberAnimation { target: mainFrame; property: "x"; to: mainFrame.x - 10; duration: 50; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: mainFrame; property: "x"; to: mainFrame.x + 10; duration: 100; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: mainFrame; property: "x"; to: mainFrame.x - 8; duration: 80; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: mainFrame; property: "x"; to: mainFrame.x + 8; duration: 80; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: mainFrame; property: "x"; to: mainFrame.x; duration: 50; easing.type: Easing.InOutQuad }
                    }
                }

                ColorAnimation { target: passwordInput; property: "color"; to: passwordInput.color; duration: 200 }
            }

            cursorDelegate: Rectangle {
                function getCursorColor() {
                    if (config.stringValue("passwordCursorColor").length === 7 && config.stringValue("passwordCursorColor")[0] === "#") {
                        return config.stringValue("passwordCursorColor");
                    } else {
                        return root.textColor
                    }
                }
                id: passwordInputCursor
                width: 18/96*root.passwordFontSize
                visible: config.boolValue("passwordInputCursorVisible")
                onHeightChanged: height = passwordInput.height/2
                anchors.verticalCenter: parent.verticalCenter
                color: getCursorColor()
                property color currentColor: color

                SequentialAnimation on color {
                    loops: Animation.Infinite
                    PauseAnimation { duration: 100 }
                    ColorAnimation { from: passwordInputCursor.currentColor; to: "transparent"; duration: 0 }
                    PauseAnimation { duration: 500 }
                    ColorAnimation { from: "transparent"; to: passwordInputCursor.currentColor; duration: 0 }
                    PauseAnimation { duration: 400 }
                    running: config.boolValue("cursorBlinkAnimation")
                }
            }
        }

        Text {
            id: errorMessage
            visible: false
            text: ""
            color: "red"
            font.pointSize: root.passwordFontSize * 0.5
            font.bold: true
            anchors {
                horizontalCenter: passwordInput.horizontalCenter
                top: passwordInput.bottom
                topMargin: 10
            }
        }

        UsersChoose {
            id: username
            text: root.currentUsername
            visible: config.boolValue("showUsersByDefault")
            width: mainFrame.width/2.5/48*root.usersFontSize
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: passwordInput.top
                bottomMargin: 40
            }
            onPrevClicked: {
                usersCycleSelectPrev();
            }
            onNextClicked: {
                usersCycleSelectNext();
            }
        }

        SessionsChoose {
            id: sessionName
            text: root.currentSession
            visible: config.boolValue("showSessionsByDefault")
            width: mainFrame.width/2.5/24*root.sessionsFontSize
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 30
            }
            onPrevClicked: {
                sessionsCycleSelectPrev();
            }
            onNextClicked: {
                sessionsCycleSelectNext();
            }
        }

        Text {
            id: helpMessage
            visible: false
            text: "Show help - F1\n" +
            "Cycle select next user - F2 or Alt+u\n" +
            "Cycle select previous user - Ctrl+F2 or Alt+Ctrl+u\n" +
            "Cycle select next session - F3 or Alt+s\n" +
            "Cycle select previous session - Ctrl+F3 or Alt+Ctrl+s\n" +
            "Suspend - F10\n" +
            "Poweroff - F11\n" +
            "Reboot - F12"
            color: root.textColor
            font.pointSize: root.helpFontSize
            font.family: root.helpFont
            anchors {
                top: parent.top
                topMargin: 30
                left: parent.left
                leftMargin: 30
            }
        }

        Component.onCompleted: {
            passwordInput.forceActiveFocus();
        }

    }

    Loader {
        active: config.boolValue("hideCursor") || false
        anchors.fill: parent
        sourceComponent: MouseArea {
            enabled: false
            cursorShape: Qt.BlankCursor
        }
    }
}
