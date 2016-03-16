//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

public final class DebugAction: Action {
    public func supports(slack: SlackRequest) -> Bool {
        return slack.arguments.first == "debug"
    }
    
    public func handle(slack: SlackRequest) -> SlackResponse {
        var msg = "Hi, I'm bot-bot!\n"
        msg += "Version: \(VERSION)\n\n"
        msg += "\(slack)"
        return SlackResponse(text: msg,
                             responseType: .Ephemeral,
                             attachments: nil)
    }
}
