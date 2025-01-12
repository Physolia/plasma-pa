/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

function name(volume, muted, prefix) {
    if (!prefix) {
        prefix = "audio-volume";
    }
    var icon = null;
    var percent = volume / maxVolumeValue;
    if (percent <= 0.0 || muted) {
        icon = prefix + "-muted";
    } else if (percent <= 0.25) {
        icon = prefix + "-low";
    } else if (percent <= 0.75) {
        icon = prefix + "-medium";
    } else if (percent <= 1) {
        icon = prefix + "-high";
    } else if (percent <= 1.25) {
        icon = `${prefix}-high-warning`;
    } else {
        icon = `${prefix}-high-danger`;
    }
    return icon;
}
