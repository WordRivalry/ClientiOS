//
//  RankedMatchmaking.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

// MARK: RankedMatchmakingView
struct RankedMatchmakingView: View {
    @Bindable private var viewModel = RankedMatchmakingModel()
//    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        Divider()
                        
                        ForEach(ModeType.allCases, id: \.self) { type in
                          
                                RankedModeView(
                                    modeName: type.rawValue,
                                    activePlayers: 0,
                                    inQueue: 0) {
                                        self.viewModel.searchMatch(modeType: type)
                                    }
                            
                        }
                        TournamentSection(nextTournament: viewModel.nextTournament)
                    }
                }
                .padding()
            }
            .navigationTitle("Ranked")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $viewModel.showingCover) {
                FullScreenCoverView(
                    gameMode: self.viewModel.activeGameMode,
                    modeType: self.viewModel.activeModeType
                )
            }
            
//            // Setup and teardown the timer for fetching stats
//            .onAppear {
//                // Setup the timer to fetch stats every 3 seconds
//                self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
//                    viewModel.fetchStats()
//                }
//            }
//            .onDisappear {
//                // Invalidate and clear the timer when the view disappears
//                self.timer?.invalidate()
//                self.timer = nil
//            }
        }
//        .onAppear {
//            viewModel.fetchStats()
//        }
    }
}

// MARK: RankedModeView
struct RankedModeView: View {
    var modeName: String
    var activePlayers: Int?
    var inQueue: Int?
    var action: () -> Void
    @State private var loadingText = ""
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(modeName)
                .font(.headline.weight(.semibold))
                .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Active Players: \(activePlayers != nil ? "\(activePlayers!)" : loadingText)")
                    Text("In Queue: \(inQueue != nil ? "\(inQueue!)" : loadingText)")
                }
                Spacer()
                ActionButton(
                    title: "FIND MATCH",
                    action: action
                )
            }
            .padding(.vertical)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onReceive(timer) { _ in
            updateLoadingText()
        }
        .onAppear {
            loadingText = "." // Initial loading text
        }
        .onDisappear {
            timer.upstream.connect().cancel() // Stop the timer when the view disappears
        }
    }
    
    func updateLoadingText() {
        // Update the loading text to cycle through ".", "..", "...", resetting back to "."
        if loadingText.count == 3 {
            loadingText = "."
        } else {
            loadingText += "."
        }
    }
}

// MARK: ActionButton
struct ActionButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

// MARK: TournamentSection
struct TournamentSection: View {
    let nextTournament: Date
    
    var body: some View {
        VStack {
            Text("Daily Arena")
                .font(.headline)
                .padding()
            
            Text("Next Tournament: \(nextTournament, style: .time)")
                .bold()
                .foregroundColor(.red) // Customize as needed
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    RankedMatchmakingView()
}
