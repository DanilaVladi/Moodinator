//
//  Face.swift
//  Mood Music Thing
//
//  Created by Vladimir Danila & Alexsander Akers on 10/15/16.
//  Copyright © 2016 Vladimir Danila & Alexsander Akers. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init?(json: Any)
}

struct FaceRectangle: JSONDecodable {
    var left: Int
    var top: Int
    var width: Int
    var height: Int

    init(left: Int, top: Int, width: Int, height: Int) {
        self.left = left
        self.top = top
        self.width = width
        self.height = height
    }

    init?(json: Any) {
        if let object = json as? [String: Any],
            let left = object["left"] as? Int,
            let top = object["top"] as? Int,
            let width = object["width"] as? Int,
            let height = object["height"] as? Int {

            self.init(left: left, top: top, width: width, height: height)
        } else {
            return nil
        }
    }
}

struct Emotion: RawRepresentable, Equatable, Hashable, CustomStringConvertible, JSONDecodable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init?(json: Any) {
        if let string = json as? String {
            self.rawValue = string
        } else {
            return nil
        }
    }

    static var anger: Emotion     { return Emotion(rawValue: "anger") }
    static var contempt: Emotion  { return Emotion(rawValue: "contempt") }
    static var disgust: Emotion   { return Emotion(rawValue: "disgust") }
    static var fear: Emotion      { return Emotion(rawValue: "fear") }
    static var happiness: Emotion { return Emotion(rawValue: "happiness") }
    static var neutral: Emotion   { return Emotion(rawValue: "neutral") }
    static var sadness: Emotion   { return Emotion(rawValue: "sadness") }
    static var surprise: Emotion  { return Emotion(rawValue: "surprise") }

    static func ==(lhs: Emotion, rhs: Emotion) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    var hashValue: Int {
        return rawValue.hashValue
    }

    var description: String {
        return rawValue
    }
}

struct EmotionScores: JSONDecodable {
    var scores: [Emotion: Double]

    init(scores: [Emotion: Double] = [:]) {
        self.scores = scores
    }

    init?(json: Any) {
        if let object = json as? [String: Double] {
            self.scores = [Emotion: Double]()
            for (emotionString, score) in object {
                self.scores[Emotion(rawValue: emotionString)] = score
            }
        } else {
            return nil
        }
    }

    static func +(lhs: EmotionScores, rhs: EmotionScores) -> EmotionScores {
        var scores = lhs.scores
        for (emotion, score) in rhs.scores {
            var newScore = scores[emotion] ?? 0
            newScore += score
            scores[emotion] = newScore
        }

        return EmotionScores(scores: scores)
    }
}

struct Face: JSONDecodable {
    var faceRectangle: FaceRectangle
    var scores: EmotionScores

    init(faceRectangle: FaceRectangle, scores: EmotionScores) {
        self.faceRectangle = faceRectangle
        self.scores = scores
    }

    init?(json: Any) {
        if let object = json as? [String: Any],
            let faceRectangleJSON = object["faceRectangle"],
            let faceRectangle = FaceRectangle(json: faceRectangleJSON),
            let scoresJSON = object["scores"],
            let scores = EmotionScores(json: scoresJSON) {

            self.scores = scores
            self.faceRectangle = faceRectangle
        } else {
            return nil
        }
    }
}
