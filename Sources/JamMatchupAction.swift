//
//  JamMatchupAction.swift
//  BotBot
//
//  Created by Logan Wright on 4/1/16.
//
//

import Foundation

extension Sequence {
    var array: [Iterator.Element] {
        return Array(self)
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

public final class JamMatchupAction: Action {
    public func supports(slack: SlackRequest) -> Bool {
        return slack.arguments.first == "matchup"
    }
    
    public func handle(slack: SlackRequest) -> SlackResponse {
        let allArgs = slack.arguments.dropFirst().array
        guard allArgs.count == 4 else {
            return SlackResponse(text: "I don't know what to do with this",
                                 responseType: .InChannel,
                                 attachments: nil)
        }
        
        let teams = allArgs.shuffle()
        let first = teams[0...1].joined(separator: ", ")
        let second = teams[2...3].joined(separator: ", ")
        let text = first + " VS " + second
        return SlackResponse(text: text, responseType: .InChannel, attachments: [])
    }
}
