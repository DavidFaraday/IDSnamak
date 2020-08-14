//
//  AudioRecorder.swift
//  Chat
//
//  Created by David Kababyan on 22/06/2020.ganq?
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let shared = AudioRecorder()
    
    private override init() {
        super.init()
        
        checkForRecordPermission()
    }
    
    
    func checkForRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()

            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                
            } catch {
                print("error setting up recorder")
            }

        }
    }
    
    func startRecording(fileName: String) {
        print("Start .....")

        let audioFilename = getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            print(audioFilename, ".....")
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            print("Error recording......")
            finishRecording()
        }
    }
    
    func finishRecording() {
        print("stop recording.......")
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print("finished flag ......", flag)
    }
}
