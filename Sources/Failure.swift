//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Vapor

public enum Failure {
    case Unsupported
    case UnknownCommand(String)
    case UnsupportedPrime(String)
    case NoMessage
    case UnableToSerializeJson
}

//Response

extension Failure: ResponseRepresentable {
    public func makeResponse() -> Response {
        let msg: String
        switch self {
        case .Unsupported:
            msg = "I'm not sure I understand, try something different"
        case let .UnknownCommand(command):
            msg = "Unknown command: \(command)"
        case let .UnsupportedPrime(prime):
            msg = "Unable to parse prime: \(prime)"
        case .NoMessage:
            msg = "No message passed"
        case .UnableToSerializeJson:
            msg = "Unable to serialize Json"
        }
        
        let js = Json(
            [
                "response_type": "in_channel",
                "text" : msg
            ]
        )
        return js.makeResponse()
    }
}
