// Copyright 2019 miruka
// This file is part of harmonyqml, licensed under LGPLv3.

import QtQuick 2.7
import "../../Base"

HNoticePage {
    text: model.date.toLocaleDateString()
    color: theme.chat.daybreak.foreground
    backgroundColor: theme.chat.daybreak.background
    radius: theme.chat.daybreak.radius
}
