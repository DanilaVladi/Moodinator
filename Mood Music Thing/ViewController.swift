//
//  ViewController.swift
//  Mood Music Thing
//
//  Created by Alexsander Akers on 10/15/16.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

import AVFoundation
import Cocoa

let SpotifyAccessTokenKey = "SpotifyAccessToken"
var SpotifyAccessTokenKVOContext: UInt8 = 0

class ViewController: NSViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)

    var currentlyPlaying: TrackObject?

    var spotifyAccessToken: String? {
        didSet {
            if spotifyAccessToken != nil {
                captureSession.startRunning()
            } else {
                captureSession.stopRunning()
            }
        }
    }

    func process(emotion: Emotion, strength: Double) {
        print(emotion.rawValue)

        guard let accessToken = spotifyAccessToken else {
            return
        }

        let url: URL
        switch emotion {
        case Emotion.anger:
            url = URL(string: "https://api.spotify.com/v1/users/227fivmyok6a6kb7h7esxtjdy/playlists/2Dm3bj8NslDH8lXRQbSa38/tracks")!
        case Emotion.contempt:
            url = URL(string: "https://api.spotify.com/v1/users/spotify/playlists/2dzLgP7igXftq2lw8gTB9M/tracks")! // Copping with loss Playlist Spotify
        case Emotion.disgust:
            url = URL(string: "https://api.spotify.com/v1/users/1299389445/playlists/1299389445/tracks")! // My Disgusting Music Playlist Mathew Tran
        case Emotion.happiness:
            url = URL(string: "https://api.spotify.com/v1/users/spotify/playlists/65V6djkcVRyOStLd8nza8E/tracks")! // Happy Hits! Playlist Spotify
        case Emotion.neutral:
            url = URL(string: "https://api.spotify.com/v1/users/spotify/playlists/3xgbBiNc7mh3erYsCl8Fwg/tracks")! // Goos Vibes Sporitfy
        case Emotion.sadness:
            url = URL(string: "https://api.spotify.com/v1/users/spotify_germany/playlists/6LRZtDfgbldIvyagGfWKRU/tracks")! // Melancholie Playlist Spotify Germany
        case Emotion.surprise:
            url = URL(string: "https://api.spotify.com/v1/users/1113800793/playlists/5NWoCkC6PkSwoHIfmECZAH/tracks")!
        default:
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { data, response, error in
            if let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? [String : Any], let errorMessage = json["error"] as? [String : Any] {
                if errorMessage["message"] as! String == "The access token expired" {
                    self.spotifyAccessToken = nil
                    let clientID = "2fd1f7deca6140188f8e19289ce934c1"
                    let redirectURI = "moodmusicthing://spotify/auth/"
                    let url = URL(string: "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=token&redirect_uri=\(redirectURI)")!
                    NSWorkspace.shared().open(url)
                }
            }

            if let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any], let tracks = json["items"] as? [[String: Any]], !tracks.isEmpty {
                let playlistTrack = tracks[Int(arc4random_uniform(UInt32(tracks.count)))]
                if let track = playlistTrack["track"] as? [String : Any]{

                    if self.currentlyPlaying?.mood! != emotion.rawValue {
                        self.currentlyPlaying = TrackObject(json: track, mood: emotion.rawValue)
                        SpotifyHelper.playTrack(self.currentlyPlaying!.uri!, inContext: nil)
                    }
                    else {
                        self.currentlyPlaying = TrackObject(json: track, mood: emotion.rawValue)
                    }
                }
            }
        }
        task.resume()
    }

    func configureCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        for device in AVCaptureDevice.devices() as! [AVCaptureDevice] {
            if device.hasMediaType(AVMediaTypeVideo) || device.hasMediaType(AVMediaTypeMuxed) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                    }
                } catch {
                    print("Failed to create device input", error)
                }
            }
        }

        stillImageOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.connection.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection.isVideoMirrored = true

        let rootLayer = view.layer!
        rootLayer.backgroundColor = NSColor.black.cgColor
        rootLayer.addSublayer(previewLayer)
    }

    func recognizeImage(with data: Data) {
        let url = URL(string: "https://api.projectoxford.ai/emotion/v1.0/recognize")!
        var request = URLRequest(url: url)
        request.httpBody = data
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("9cef9b071e4749b7baae22649c0f33d1", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let strongSelf = self,
                let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data))
            else {
                return
            }

            if let faces = json as? [Any] {
                let faceScores = faces.lazy
                    .flatMap { json in Face(json: json) }
                    .map { face in face.scores }
                let totalSum = faceScores.reduce(EmotionScores(), +)

                let scores = totalSum.scores
                let maxIndex = scores.indices.max(by: { i, j in scores[i].value < scores[j].value })
                if let maxIndex = maxIndex {
                    let (emotion, score) = scores[maxIndex]
                    strongSelf.process(emotion: emotion, strength: score / Double(faceScores.count))
                }
            }
        }
        task.resume()
    }

    func takePicture() {
        let connection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
        stillImageOutput.captureStillImageAsynchronously(from: connection) { [weak self] sampleBuffer, error in
            guard let strongSelf = self else {
                return
            }

            if let sampleBuffer = sampleBuffer, let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                strongSelf.recognizeImage(with: data)
            } else {

            }
        }
    }

    func configureTimer() {
        let timer = DispatchSource.makeTimerSource()
        timer.setEventHandler { [weak self] in
            guard let strongSelf = self else {
                timer.cancel()
                return
            }

            strongSelf.takePicture()
        }

        timer.scheduleRepeating(deadline: .now(), interval: .seconds(2))
        timer.resume()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &SpotifyAccessTokenKVOContext {
            spotifyAccessToken = change?[.newKey] as? String
            if spotifyAccessToken == nil {
                let clientID = "2fd1f7deca6140188f8e19289ce934c1"
                let redirectURI = "moodmusicthing://spotify/auth/"
                let url = URL(string: "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=token&redirect_uri=\(redirectURI)")!
                NSWorkspace.shared().open(url)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCaptureSession()
        configureTimer()

        UserDefaults.standard.addObserver(self, forKeyPath: SpotifyAccessTokenKey, options: [.new, .initial], context: &SpotifyAccessTokenKVOContext)
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        let enabled = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        previewLayer.frame = view.bounds
        CATransaction.setDisableActions(enabled)
    }
}
