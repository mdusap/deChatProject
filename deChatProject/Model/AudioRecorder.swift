//
//  AudioRecorder.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 9/6/22.
//

/// Clase modelo para el objeto audio

import Foundation
import AVFoundation


class AudioRecoder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var hasPermission: Bool!
    
    static let shared = AudioRecoder()
    
    private override init() {
        super.init()
        
        checkForPermission()
    }
    
    func checkForPermission(){
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasPermission = true
            break
        case .denied:
            hasPermission = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                
                self.hasPermission = isAllowed
            }
        default:
            break
        }
    }
    
    // Preparacion de la grabadora
    func setupRecorder() {
        
        if hasPermission {
            
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                try recordingSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
                
            } catch {
                print("Error en configurar la grabadora de audio", error.localizedDescription)
            }
        }
    }
    
    // Cuando empieza a grabar
    func startRecording(fileName: String) {
        
        let audioFileName = getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            print("Error en grabar el audio", error.localizedDescription)
            finishRecording()
        }
    }
    
    // Parar de grabar
    func finishRecording() {
        
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
