/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.4
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.private.volume 0.1

RowLayout {
    id: sliderRow

    signal moved()

    property alias value: slider.value

    property int channel: -1

    QQC2.Slider {
        id: slider

        Layout.fillWidth: true

        value: Volume
        from: PulseAudio.MinimalVolume
        to: config.raiseMaximumVolume ? PulseAudio.MaximalVolume /* 150 */ : PulseAudio.NormalVolume /* 100 */
        // TODO: implement a way to hide tickmarks (stepSize is also required to scroll)
        // stepSize: to / (PulseAudio.MaximalVolume / PulseAudio.NormalVolume * 100.0)
        visible: HasVolume
        enabled: VolumeWritable
        opacity: Muted ? 0.5 : 1
        onMoved: {
            // Since it is not possible to use stepSize without tickmarks being displayed, force 1% steps
            // Unfortunately without stepSize, it cannot snap visually whilst scrolling by changing value instead of Volume as it breaks the binding
            let volume = Math.round(value * 100 / PulseAudio.NormalVolume) * PulseAudio.NormalVolume / 100
            if (channel == -1) {
                Volume = volume
                Muted = volume === 0;
            } else {
                delegate.pulseObject.setChannelVolume(channel, volume);

                // volumes are updated async, so we'll just assume it worked here
                let newChannelVolumes = ChannelVolumes;
                newChannelVolumes[index] = value;
                Muted = newChannelVolumes.every(volume => volume === 0);
            }

            sliderRow.moved()
        }

    }

    QQC2.Label {
        id: percentText
        readonly property real value: PulseObject.volume > slider.maximumValue ? PulseObject.volume : slider.value
        readonly property real displayValue: Math.round(value / PulseAudio.NormalVolume * 100.0)
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumWidth: percentMetrics.advanceWidth
        horizontalAlignment: Qt.AlignRight
        text: i18ndc("kcm_pulseaudio", "volume percentage", "%1%", displayValue)
        // Display a subtle visual indication that the volume might be
        // dangerously high
        // ------------------------------------------------
        // Keep this in sync with the copies in ListItemBase.qml
        // and plasma-workspace:OSDItem.qml
        color: {
            if (displayValue <= 100) {
                return Kirigami.Theme.textColor
            } else if (displayValue > 100 && displayValue <= 125) {
                return Kirigami.Theme.neutralTextColor
            } else {
                return Kirigami.Theme.negativeTextColor
            }
        }
    }

    TextMetrics {
        id: percentMetrics
        font: percentText.font
        text: i18ndc("kcm_pulseaudio", "only used for sizing, should be widest possible string", "100%")
    }
}
