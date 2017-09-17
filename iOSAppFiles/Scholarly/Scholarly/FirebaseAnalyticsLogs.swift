//
//  FirebaseAnalyticsLogs.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics

func lytTextMessageSent() {
    Analytics.logEvent("text_message_sent", parameters: nil)
}

func lytImageMessageSent() {
    Analytics.logEvent("image_message_sent", parameters: nil)
}

func lytAgendaItemAdded() {
    Analytics.logEvent("agenda_item_added", parameters: nil)
}

func lytAgendaItemDeleted() {
    Analytics.logEvent("agenda_item_removed", parameters: nil)
}

func lytLeaderBoardChecked() {
    Analytics.logEvent("leaderboard_checked", parameters: nil)
}

func lytMessageHearted() {
    Analytics.logEvent("message_hearted", parameters: nil)
}

func lytMessageUnHearted() {
    Analytics.logEvent("message_unhearted", parameters: nil)
}
