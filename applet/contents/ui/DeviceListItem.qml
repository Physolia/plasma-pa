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

import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon

ListItemBase {
    readonly property var currentPort: Ports[ActivePortIndex]
    readonly property var currentActivePortIndex: ActivePortIndex
    readonly property var currentMuted: Muted
    readonly property var activePortIndex: ActivePortIndex

    draggable: false
    label: {
        if (currentPort) {
            var model = type === "sink" ? paSinkModel : paSourceModel;
            var itemLength = currentPort.description.length;
            for (var i = 0; i < model.rowCount(); i++) {
                if (i !== index) {
                    var port  = model.data(model.index(i, 0), model.role("Ports"))
                                [model.data(model.index(i, 0), model.role("ActivePortIndex"))];
                    if (port && port.description) {
                        var length = Math.min(itemLength, port.description.length)
                        if (currentPort.description.substring(0, length) === port.description.substring(0, length)) {
                            return i18nc("label of device items", "%1 (%2)", currentPort.description, Description);
                        }
                    }
                }
            }
            return currentPort.description;
        } else {
            return Description;
        }
    }

    onCurrentActivePortIndexChanged: {
        if (type === "sink" && globalMute && !Muted) {
            Muted = true;
        }
    }

    onCurrentMutedChanged: {
        if (type === "sink" && globalMute && !Muted) {
            plasmoid.configuration.globalMuteDevices = [];
            plasmoid.configuration.globalMute = false;
            globalMute = false;
        }
    }

    // Prevent an unavailable port selection. UI allows selection of an unavailable port, until it gets refresh,
    // because there is no call from pulseaudio for availability change.
    onActivePortIndexChanged: {
        if (currentPort.availability === Port.Unavailable) {
            for (var i = 0; i < Ports.length; i++) {
                if (Ports[i].availability === Port.Available) {
                    ActivePortIndex = i;
                    return
                }
            }
        }
    }
}
