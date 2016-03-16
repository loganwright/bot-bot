//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Vapor

// For a better description of the values here, look at: https://api.slack.com/docs/attachments

public struct SlackResponse: ResponseConvertible{
    public enum ResponseType: String {
        case InChannel = "in_channel"
        case Ephemeral = "ephemeral"
    }
    
    let text: String?
    let responseType: ResponseType
    let attachments: [Attachment]?
    
    
    public func response() -> Response {
        var json: Json = [:]
        
        json["response_type"] = Json(responseType.rawValue)
        
        if let text = text {
            json["text"] = Json(text)
        }
        
        if let attachments = attachments?.map({ $0.json() }) {
            json["attachments"] = Json(attachments)
        }
        
        do {
            return Response(status: .OK,
                            data: try json.serialize(),
                            contentType: .Json)
        } catch {
            return Failure.UnableToSerializeJson.response()
        }
    }
}
