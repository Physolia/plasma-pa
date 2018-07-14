/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3

import org.kde.plasma.private.volume 0.1
import org.kde.kcoreaddons 1.0 as KCoreAddons


ScrollView {
    id: scrollView

    ColumnLayout {
        Component.onCompleted: {
            // Normal binding causes binding loops
            width = Qt.binding(function() {
                return scrollView.viewport.width;
            });
        }

        Header {
            Layout.fillWidth: true
            enabled: view.count > 0
            text: i18n("Device Profiles")
            disabledText: i18nc("@label", "No Device Profiles Available")
        }

        ListView {
            id: view
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.margins: units.gridUnit / 2
            interactive: false
            spacing: units.smallSpacing * 2
            model: CardModel {}
            delegate: CardListItem {}
        }

        Header {
            Layout.fillWidth: true
            text: i18n("Advanced Output Configuration")
            visible: moduleManager.settingsSupported
        }

        ModuleManager {
            id: moduleManager
        }

        CheckBox {
            Layout.fillWidth: true
            Layout.topMargin: units.smallSpacing
            Layout.leftMargin: units.gridUnit / 2
            Layout.rightMargin: units.gridUnit / 2
            text: i18n("Add virtual output device for simultaneous output on all local sound cards")
            checked: moduleManager.combineSinks
            onCheckedChanged: moduleManager.combineSinks = checked;
            enabled: moduleManager.loadedModules.indexOf("module-gconf") != -1
            visible: moduleManager.settingsSupported
        }

        CheckBox {
            Layout.fillWidth: true
            Layout.leftMargin: units.gridUnit / 2
            Layout.rightMargin: units.gridUnit / 2
            text: i18n("Automatically switch all running streams when a new output becomes available")
            checked: moduleManager.switchOnConnect
            onCheckedChanged: moduleManager.switchOnConnect = checked;
            enabled: moduleManager.loadedModules.indexOf("module-gconf") != -1
            visible: moduleManager.settingsSupported
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            enabled: false
            font.italic: true
            text: i18n("Requires 'module-gconf' PulseAudio module")
            visible: moduleManager.settingsSupported && moduleManager.loadedModules.indexOf("module-gconf") == -1
        }

        Header {
            Layout.fillWidth: true
            text: i18n("Speaker Placement and Testing")
        }

        RowLayout {
            Layout.margins: units.gridUnit / 2
            visible: sinks.count > 1

            Label {
                text: i18nc("@label", "Output:")
                font.bold: true
            }

            ComboBox {
                id: sinks

                property var pulseObject: null

                Layout.fillWidth: true
                textRole: "Description"
                model: SinkModel {
                    onRowsInserted: sinks.updatePulseObject()
                    onRowsRemoved: sinks.updatePulseObject()
                    onDataChanged: sinks.updatePulseObject()
                }
                onCurrentIndexChanged: updatePulseObject()
                onCurrentTextChanged: updatePulseObject()
                Component.onCompleted: updatePulseObject()

                function updatePulseObject() {
                    Qt.callLater(function() {
                        pulseObject = model.data(model.index(sinks.currentIndex, 0), model.role("PulseObject"));
                    });
                }
            }
        }

        Grid {
            id: grid
            columns: 3
            spacing: 5
            Layout.fillWidth: true

            Item {
                width: grid.width/3
                height: 50

                Button{
                    text: i18n("Front Left")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Front Left") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Front Left")
                }
            }
            Item {
                width: grid.width/3
                height: 50

                Button{
                    text: i18n("Front Center")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Front Center") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Front Center")
                }
            }
            Item {
                width: grid.width/3
                height: 50

                Button{
                    text: i18n("Front Right")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Front Right") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Front Right")
                }
            }
            Item {
                width: grid.width/3
                height: 50

                Button{
                    text: i18n("Side Left")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Side Left") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Side Left")

                }
            }
            Item {
                width: grid.width/3
                height: 50

                KCoreAddons.KUser {
                    id: kuser
                }

                Image {
                    source: kuser.faceIconUrl
                    anchors.centerIn: parent
                    width: 50
                    height: 50
                }
            }
            Item {
                width: grid.width/3
                height: 50
                Button{
                    text: i18n("Side Right")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Side Right") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Side Right")
                }
            }
            Item {
                width: grid.width/3
                height: 50
                Button{
                    text: i18n("Rear Left")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Rear Left") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Rear Left")
                }
            }
            Item {
                width: grid.width/3
                height: 50
                Button{
                    text: i18n("Subwoofer")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Subwoofer") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Subwoofer")
                }
            }
            Item {
                width: grid.width/3
                height: 50
                Button{
                    text: i18n("Rear Right")
                    anchors.centerIn: parent
                    visible: sinks.pulseObject ? sinks.pulseObject.channels.indexOf("Rear Right") > -1 : false
                    onClicked: sinks.pulseObject.testChannel("Rear Right")
                }
            }
        }
    }
}
