//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

let helloAction = BasicAction(
    supportsSlack: { slack in
        guard let prime = slack.arguments.first else { return false }
        switch prime {
        case "hi", "hey", "hello", "howdy", "hiya":
            return true
        default:
            return false
        }
    },
    handler: { slack in
        let salutation = slack.arguments.first ?? "Hi"
        return SlackResponse(
            text: "\(salutation), \(slack.userName)!",
            responseType: .InChannel,
            attachments: nil
        )
    }
)
