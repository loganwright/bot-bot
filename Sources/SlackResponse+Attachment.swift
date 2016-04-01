//
//  main.swift
//  slack-bot
//
//  Created by Logan Wright on 2/22/16.
//  Copyright © 2016 loganwright. All rights reserved.
//

import Foundation
import Vapor

// For a better description of the values here, look at: https://api.slack.com/docs/attachments

extension SlackResponse {
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
                    var js: [String : JsonRepresentable] = [:]
                    js["title"] = Json(title)
                    js["value"] = Json(value)
                    if let short = short {
                        js["short"] = Json(short)
                    }
                    return Json(js)
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
                    return ("fields", Json.array(fields))
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
}