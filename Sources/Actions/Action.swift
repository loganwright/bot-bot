//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

public protocol Action {
    func supports(slack: SlackRequest) -> Bool
    func handle(slack: SlackRequest) -> SlackResponse
}

// MARK: Basic Action

public final class BasicAction: Action {
    let supportsSlack: SlackRequest -> Bool
    let handler: SlackRequest -> SlackResponse
    
    public init(supportsSlack: SlackRequest -> Bool, handler: SlackRequest -> SlackResponse) {
        self.supportsSlack = supportsSlack
        self.handler = handler
    }
    
    public func supports(slack: SlackRequest) -> Bool {
        return supportsSlack(slack)
    }
    
    public func handle(slack: SlackRequest) -> SlackResponse {
        return handler(slack)
    }
}
