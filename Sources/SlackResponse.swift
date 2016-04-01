//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Vapor

// For a better description of the values here, look at: https://api.slack.com/docs/attachments

extension Json: JsonRepresentable {
    public func makeJson() -> Json {
        return self
    }
}

public struct SlackResponse: ResponseRepresentable {
    public enum ResponseType: String {
        case InChannel = "in_channel"
        case Ephemeral = "ephemeral"
    }
    
    let text: String?
    let responseType: ResponseType
    let attachments: [Attachment]?
    
    
    public func makeResponse() -> Response {
        var json: [String : JsonRepresentable] = [:]
        
        json["response_type"] = responseType.rawValue
        
        if let text = text {
            json["text"] = text
        }
        
        if let attachments = attachments?.map({ $0.json() }) {
            json["attachments"] = Json.array(attachments)
        }
        
        return Json(json).makeResponse()
    }
}
