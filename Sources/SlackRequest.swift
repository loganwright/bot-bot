//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Vapor

/*
 token=GLtqZxRlry3UpVW1chQeTPEk
 team_id=T0001
 team_domain=example
 channel_id=C2147483705
 channel_name=test
 user_id=U2147483697
 user_name=Steve
 command=/weather
 text=94070
 response_url=https://hooks.slack.com/commands/1234/5678
 */

// MARK: Slack Models

public struct SlackRequest {
    let token: String
    let teamId: String
    let teamDomain: String
    let channelId: String
    let channelName: String
    let userId: String
    let userName: String
    let command: String
    let text: String
    let responseUrl: String
    
    let arguments: [String]
    
    init(request: Vapor.Request) {
        token = request.data["token"]?.string ?? "*"
        teamId = request.data["team_id"]?.string ?? "*"
        teamDomain = request.data["team_domain"]?.string ?? "*"
        channelId = request.data["channel_id"]?.string ?? "*"
        channelName = request.data["channel_name"]?.string ?? "*"
        userId = request.data["user_id"]?.string ?? "*"
        userName = request.data["user_name"]?.string ?? "*"
        command = request.data["command"]?.string ?? "*"
        responseUrl = request.data["response_url"]?.string ?? "*"
        
        // Spaces ' ' come as '+' in message
        let raw = request.data["text"]?.string ?? "*"
        arguments = raw.componentsSeparatedByString("+")
        text = arguments.joinWithSeparator(" ")
    }
}

extension SlackRequest: CustomStringConvertible {
    public var description: String {
        return [
                "token" : "****", // token
                "team id" : teamId,
                "team domain" : teamDomain,
                "channel id" : channelId,
                "channel name" : channelName,
                "user id" : userId,
                "user name" : userName,
                "command" : command,
                "text" : text
                "response url" : responseUrl
            ]
            .map { key, val in "\(key) = \(val)" }
            .joinWithSeparator(",\n")
    }
}
