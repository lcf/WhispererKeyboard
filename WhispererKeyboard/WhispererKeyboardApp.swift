//
//  WhispererKeyboardApp.swift
//  WhispererKeyboard
//
//  Created by Alexander Steshenko on 9/11/23.
//

import SwiftUI
import Foundation

/// This is a full screen view that opens up when "Record audio" button is clicked in the keyboard extension
/// When open, the app automatically begins recording. Once finished, the application requests transcriptiong using OpenAI Whisperer API
/// The app then suggests the user to return to the app that had the keyboard open. Unfortunately found no way to return user automatically.
@main
struct WhispererKeyboardApp: App {
    
    // contains logic for capturing audio from the microphone and saving into a temporary file
    private var audio = Audio()
    
    // contains logic for sending data for transcription to OpenAI and storing results into shared app storage
    @StateObject private var transcription = Transcription()
    
    // Necessary to detect when application becomes active. Begin recording immediately
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        // Will show one clickable text at at the bottom of the screen to control recording
        // Positioned at the bottom so it's convenient to swipe back to the previous app
        WindowGroup {
            VStack {
                Spacer()
                Text(getTranscriptionStatusMessage())
                    .onTapGesture(count: 1, perform: {
                        if self.transcription.status != .finished {
                            // Request to transcribe is what stops the audio recording
                            self.audio.stop()
                            self.transcription.transcribe(audio.getFilename())
                        }
                    })
            }
            .padding()
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // When app loads, start recording immediately.
                    // This auxiliary appliation is to workaround iOS restrictions to record audio from within keyboard extension
                    transcription.status = .recording
                    self.audio.start()
                }
            }
        }
    }
    
    func getTranscriptionStatusMessage() -> String {
        switch transcription.status {
        case .recording:
            return "Press to stop recording"
        case .transcribing:
            return "Transcribing ..."
        case .finished:
            return "Finished. Return to the application"
        case .error:
            return "Error. Try again later"
        }
    }
}
