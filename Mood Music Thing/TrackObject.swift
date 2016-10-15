//
//  TrackObject.swift
//  Mood Music Thing
//
//  Created by Vladimir Danila on 15/10/2016.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

import Cocoa

class TrackObject {
    var name: String?
    var artistName: String?
    var uri: String?

    var albumName: String?
    var albumCoverURL: String?

    var popularity: Int?

    var mood: String!

    convenience init(json track: [String : Any], mood: String){
        self.init()

        self.name = track["name"] as? String

        var names = ""
        for artistElement in track["artists"] as! [[String : Any]] {
            if names != "" {
                names += ", "
            }

            names += (artistElement["name"] as? String)!
        }


        self.artistName = names
        self.uri = track["uri"] as? String

        if let albumElement = track["album"] as? [String : Any] {
            self.albumName = albumElement["name"] as? String

            if let images = albumElement["images"] as? [[String : Any]] {
                let image = images.first
                self.albumCoverURL = image?["url"] as? String
            }
        }

        self.popularity = track["popularity"] as? Int

        self.mood = mood
    }
}
