//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

public final class MemeAction: Action {
    public func supports(slack: SlackRequest) -> Bool {
        let prime = slack.arguments.first?.lowercaseString
        print("Got prime: \(prime)")
        return prime == "meme"
    }
    
    public func handle(slack: SlackRequest) -> SlackResponse {
        guard
            let suffix = slack
                .text
                .componentsSeparatedByString(" ")
                .dropFirst() // Drop 'meme'
                .joinWithSeparator(" ")
                .stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
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
