import Foundation
import Speech

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    override init() {
        super.init()
        recognizer?.delegate = self
        requestSpeechAuth()
    }

    private func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }

        if #available(iOS 17.0, *) {
            // No alternative yet on iOS; AVAudioApplication is not available
            print("Using deprecated mic permission — no replacement yet on iOS 17")
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                if !allowed {
                    print("Microphone access denied (fallback for iOS 17+)")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                if !allowed {
                    print("Microphone access denied (< iOS 17)")
                }
            }
        }
    }



    func startRecognition(completion: @escaping (String) -> Void) {
        stopRecognition()

        // Setup audio session first
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
            return
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                completion(result.bestTranscription.formattedString)
            } else if let error = error {
                print("Error recognizing speech: \(error.localizedDescription)")
            }
        }
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
            stopRecognition()
        }
    }

    func stopRecognition() {
        // Always check if the engine is running first
        if audioEngine.isRunning {
            audioEngine.stop()
            
            // Remove the tap if it exists
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End the request and cancel the task
        request?.endAudio()
        task?.cancel()
        
        // Reset the audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // Reset all state
        task = nil
        request = nil
    }

}
