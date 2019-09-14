import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../../Base"
import "../../utils.js" as Utils

Column {
    id: eventDelegate
    width: eventList.width
    topPadding:
        model.event_type == "RoomCreateEvent" ? 0 :
        dayBreak  ? theme.spacing * 4 :
        talkBreak ? theme.spacing * 6 :
        combine   ? theme.spacing / 2 :
        theme.spacing * 2


    enum Media { Page, File, Image, Video, Audio }

    property var hoveredMediaTypeUrl: []

    // Remember timeline goes from newest message at index 0 to oldest
    property var previousItem: eventList.model.get(model.index + 1)
    property var nextItem: eventList.model.get(model.index - 1)
    readonly property QtObject currentItem: model
    property int modelIndex: model.index
    onModelIndexChanged: {
        previousItem = eventList.model.get(model.index + 1)
        nextItem     = eventList.model.get(model.index - 1)
    }

    property bool isOwn: chatPage.userId === model.sender_id
    property bool onRight: eventList.ownEventsOnRight && isOwn
    property bool combine: eventList.canCombine(previousItem, model)
    property bool talkBreak: eventList.canTalkBreak(previousItem, model)
    property bool dayBreak: eventList.canDayBreak(previousItem, model)

    readonly property bool smallAvatar:
        eventList.canCombine(model, nextItem) &&
        (model.event_type == "RoomMessageEmote" ||
         ! model.event_type.startsWith("RoomMessage"))

    readonly property bool collapseAvatar: combine
    readonly property bool hideAvatar: onRight

    readonly property bool hideNameLine:
        model.event_type == "RoomMessageEmote" ||
        ! model.event_type.startsWith("RoomMessage") ||
        onRight ||
        combine

    readonly property bool unselectableNameLine:
        hideNameLine && ! (onRight && ! combine)

    readonly property int cursorShape:
        eventContent.hoveredLink || hoveredMediaTypeUrl.length > 0 ?
        Qt.PointingHandCursor :

        eventContent.hoveredSelectable ? Qt.IBeamCursor :

        Qt.ArrowCursor

    // Needed because of eventList's MouseArea which steals the
    // HSelectableLabel's MouseArea hover events
    onCursorShapeChanged: eventList.cursorShape = cursorShape


    function json() {
        return JSON.stringify(
            Utils.getItem(
                modelSources[[
                    "Event", chatPage.userId, chatPage.roomId
                ]],
                "client_id",
                model.client_id
            ),
        null, 4)
    }


    Daybreak {
        visible: dayBreak
        width: eventDelegate.width
    }

    Item {
        visible: dayBreak
        width: parent.width
        height: topPadding
    }

    EventContent {
        id: eventContent
        x: onRight ? parent.width - width : 0

        Behavior on x { HNumberAnimation {} }
    }


    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: {
            contextMenu.media = eventDelegate.hoveredMediaTypeUrl
            contextMenu.link  = eventContent.hoveredLink
            contextMenu.popup()
        }
    }

    HMenu {
        id: contextMenu

        property var media: []
        property string link: ""

        onClosed: { media = []; link = "" }

        HMenuItem {
            id: copyMedia
            icon.name: "copy-link"
            text:
                contextMenu.media.length < 1 ? "" :

                contextMenu.media[0] === EventDelegate.Media.Page ?
                qsTr("Copy page address") :

                contextMenu.media[0] === EventDelegate.Media.File ?
                qsTr("Copy file address") :

                contextMenu.media[0] === EventDelegate.Media.Image ?
                qsTr("Copy image address") :

                contextMenu.media[0] === EventDelegate.Media.Video ?
                qsTr("Copy video address") :

                contextMenu.media[0] === EventDelegate.Media.Audio ?
                qsTr("Copy audio address") :

                qsTr("Copy media address")

            visible: Boolean(text)
            onTriggered: Utils.copyToClipboard(contextMenu.media[1])
        }

        HMenuItem {
            id: copyLink
            icon.name: "copy-link"
            text: qsTr("Copy link address")
            visible: Boolean(contextMenu.link)
            onTriggered: Utils.copyToClipboard(contextMenu.link)
        }

        HMenuItem {
            icon.name: "copy-text"
            text: qsTr("Copy text")
            visible: enabled || (! copyLink.visible && ! copyMedia.visible)
            enabled: Boolean(selectableLabelContainer.joinedSelection)
            onTriggered:
                Utils.copyToClipboard(selectableLabelContainer.joinedSelection)
        }

        HMenuItem {
            icon.name: "clear-messages"
            text: qsTr("Clear messages")
            onTriggered: Utils.makePopup(
                "Popups/ClearMessagesPopup.qml",
                chatPage,
                {userId: chatPage.userId, roomId: chatPage.roomId},
            )
        }

        HMenuItem {
            icon.name: "settings"
            text: qsTr("Set as debug console target")
            visible: debugMode
            onTriggered: {
                mainUI.debugConsole.target = [eventDelegate, eventContent]
                mainUI.debugConsole.runJS("t[0].json()")
            }
        }
    }
}
