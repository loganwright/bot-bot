//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Foundation
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
    init(request: Request) {
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
            token,
            teamId,
            teamDomain,
            channelId,
            channelName,
            userId,
            userName,
            command,
            text,
            responseUrl
            ]
            .joinWithSeparator(",\n")
    }
}


// For a better description of the values here, look at: https://api.slack.com/docs/attachments

public struct SlackResponse: ResponseConvertible{
    public enum ResponseType: String {
        case InChannel = "in_channel"
        case Ephemeral = "ephemeral"
    }
    
    public struct Attachment {
        public enum Content {
            
            public struct Field {
                /// Shown as a bold heading above the value text. It cannot contain markup and will be escaped for you.
                let title: String
                /// The text value of the field. It may contain standard message markup (see details below) and must be escaped as normal. May be multi-line.
                let value: String
                /// An optional flag indicating whether the value is short enough to be displayed side-by-side with other values.
                let short: Bool?
                
                public func json() -> Json {
                    var js: Json = [:]
                    js["title"] = Json(title)
                    js["value"] = Json(value)
                    if let short = short {
                        js["short"] = Json(short)
                    }
                    return js
                }
            }
            
            case Fallback(String) // Required Plain-text Summary of the attachment
            
            case Color(String) // #36a64f
            
            case Pretext(String) // Optional text that appears above the attachment block
            
            case AuthorName(String) // Bobby Tables
            case AuthorLink(String) // http://flickr.com/bobby/
            case AuthorIcon(String) // http://flickr.com/icons/bobby.jpg
            
            case Title(String) // Slack API Documentation
            case TitleLink(String) // https://api.slack.com
            
            case Text(String) // Optional text that appears within the attachment
            
            case Fields([Field])
            
            case ImageUrl(String) // http://example.com/path/to/thumb.png
            case ThumbUrl(String) // http://example.com/path/to/thumb.png
            
            func keyValPair() -> (key: String, value: Json) {
                switch self {
                case let Fallback(fallback):
                    return ("fallback", Json(fallback))
                case let Color(color):
                    return ("color", Json(color))
                case let Pretext(pretext):
                    return ("pretext", Json(pretext))
                case let AuthorName(name):
                    return ("author_name", Json(name))
                case let AuthorLink(link):
                    return ("author_link", Json(link))
                case let AuthorIcon(icon):
                    return ("author_icon", Json(icon))
                case let Title(title):
                    return ("title", Json(title))
                case let TitleLink(link):
                    return ("title_link", Json(link))
                case let Text(text):
                    return ("text", Json(text))
                case let Fields(rawFields):
                    let fields = rawFields.map { $0.json() }
                    return ("fields", Json(fields))
                case let ImageUrl(url):
                    return ("image_url", Json(url))
                case let ThumbUrl(url):
                    return ("thumb_url", Json(url))
                }
            }
            
            func json() -> Json {
                let (key, val) = keyValPair()
                return Json([key : val])
            }
        }
        
        let content: [Content]
        
        public func json() -> Json {
            return Json(
                content.map { $0.json() }
            )
        }
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

// MARK: Failures

public enum Failure {
    case Unsupported
    case UnknownCommand(String)
    case UnsupportedPrime(String)
    case NoMessage
    case UnableToSerializeJson
}

//Response

extension Failure: ResponseConvertible {
    public func response() -> Response {
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
        
        do {
            let js = try Json(
                [
                    "response_type": "in_channel",
                    "text" : msg
                ]
            )
            return Response(status: .OK,
                            data: try js.serialize(),
                            contentType: .Json)
        } catch {
            return Response(error: "Unknown Error: \(error) Message: \(msg)")
        }
    }
}

// MARK: Handlers

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

// MARK: Say Hello

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

// MARK: Make A Meme

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

// MARK: Add new actions here to extend support

let actions: [Action] = [
    helloAction,
    MemeAction()
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

/**
 *  Debug Requests in Slack
 */
app.get("slack-debug") { req in
    let slack = SlackRequest(request: req)
    
    var msg = "Hi, I'm randy-bot!\n"
    msg += "\(slack)"
    
    let js: Json = [
        "response_type": "in_channel",
        "text" : Json(msg)
    ]
    return js
}

app.start(port: 9090)
