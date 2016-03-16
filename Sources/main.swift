//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Foundation
import Vapor

public let VERSION = "1.0.1"

// MARK: Add new actions here to extend support

let actions: [Action] = [
    helloAction,
    MemeAction(),
    DebugAction()
]

// MARK: Application

let app = Application()

app.get("status") { _ in
    return "It's alive"
}

app.get("slack") { req in
    let slack = SlackRequest(request: req)
    
    // Only handling first right now, in future,
    // possibly figure out a priority scheme 
    // for which action should respond
    return actions
        .lazy
        .filter {
            $0.supports(slack)
        }
        .first?
        .handle(slack) ?? Failure.Unsupported
}

app.start(port: 9090)
