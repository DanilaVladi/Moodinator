//
//  ViewController.swift
//  Mood Music Thing
//
//  Created by Alexsander Akers on 10/15/16.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

import AVFoundation
import Cocoa

class ViewController: NSViewController {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)

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

        captureSession.startRunning()
    }

    func recognizeImage(with data: Data) {
        let url = URL(string: "https://api.projectoxford.ai/emotion/v1.0/recognize")!
        var request = URLRequest(url: url)
        request.httpBody = data
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("9cef9b071e4749b7baae22649c0f33d1", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) else {
                return
            }

            if let faces = json as? [Any] {
                let totalSum = faces.lazy
                    .flatMap { json in Face(json: json) }
                    .map { face in face.scores }
                    .reduce(EmotionScores(), +)

                let scores = totalSum.scores
                let maxIndex = scores.indices.max(by: { i, j in scores[i].value < scores[j].value })
                if let maxIndex = maxIndex {
                    let (emotion, score) = scores[maxIndex]
                    print(emotion, score)
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

        timer.scheduleRepeating(deadline: .now(), interval: .seconds(5))
        timer.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCaptureSession()
        configureTimer()
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        let enabled = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        previewLayer.frame = view.bounds
        CATransaction.setDisableActions(enabled)
    }
}
