//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Foundation

public final class MemeAction: Action {
    public func supports(slack: SlackRequest) -> Bool {
        let prime = slack.arguments.first?.lowercased()
        return prime == "meme"
    }
    
    public func handle(slack: SlackRequest) -> SlackResponse {
        guard
            let suffix = slack
                .text
                .characters
                .split(separator: " ")
                .map(String.init)
                .dropFirst() // Drop 'meme'
                .joined(separator: " ")
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed())
            else {
                return SlackResponse(text: "Machine Broke",
                                     responseType: .InChannel,
                                     attachments: nil)
            }
        
        let url = "http://urlme.me/\(suffix)"
        let content = SlackResponse.Attachment.Content.ImageUrl(url)
        let attachment = SlackResponse.Attachment(content: [content])
        return SlackResponse(text: url, responseType: .InChannel, attachments: [attachment])
    }
}
