//
//  TrackObject.swift
//  Mood Music Thing
//
//  Created by Vladimir Danila on 15/10/2016.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

import Cocoa

protocol TrackObjectDelegate: class {
    func imageLoaded(image: NSImage)
    func songIsOver()
}

class TrackObject {
    var name: String?
    var artistName: String?
    var uri: String?

    var albumName: String?
    var albumCoverURL: String?

    var popularity: Int?

    var mood: String!

    var cover: NSImage?

    private var timer: Timer?

    func duration() -> TimeInterval {
        print(TimeInterval(SpotifyHelper.duration()))
        return TimeInterval(SpotifyHelper.duration())
    }

    weak var delegate: TrackObjectDelegate?

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

                if let url = URL(string: self.albumCoverURL!) {
                    downloadImage(url: url)
                }
            }
        }

        self.popularity = track["popularity"] as? Int

        self.mood = mood

    }

    func startDownload() {
        if let url = URL(string: self.albumCoverURL!) {
            downloadImage(url: url)
        }
    }

    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            DispatchQueue.main.sync() { () -> Void in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")

                self.cover = NSImage(data: data)
                self.delegate?.imageLoaded(image: self.cover!)
            }
        }
    }

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

}
