//
//  ContentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData
import CloudKit
import os.log

struct IcloudStatusMessageView: View {
    @Environment(\.openURL) var openURL
    let status: String = iCloudService.shared.statusMessage()
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("iCloud Is Not Available")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.top, 2)
            Text("Status: \(status)")
                .font(.callout)
                .padding(.vertical)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("A valid and working iCloud account is required to play this game.")
                .font(.callout)
                .padding(.vertical)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: openSettings) {
                Label("Open settings", systemImage: "gear")
                    .tint(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.bar)
            )
        }
        .padding().padding()
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.bar)
        )
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
    
    
    private func openSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
}

struct NoInternetConnectionView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Internet Connection")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.top, 2)
  
            Text("Your device is not connectred to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi networ.")
                .font(.callout)
                .padding(.vertical)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: openSettings) {
                Label("Open settings", systemImage: "gear")
                    .tint(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.bar)
            )
        }
        .padding().padding()
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.bar)
        )
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
    
    private func openSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
}

struct InternetStatusMessageView: View {
    @Environment(\.openURL) var openURL
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Internet Connection")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.top, 2)
  
            Text("Your device is not connectred to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi networ.")
                .font(.callout)
                .padding(.vertical)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
             
            Text(message)
                .font(.callout)
                .padding(.vertical)
                .foregroundColor(.primary.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: openSettings) {
                Label("Open settings", systemImage: "gear")
                    .tint(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.bar)
            )
        }
        .padding().padding()
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.bar)
        )
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
    
    private func openSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
}

#Preview {
    InternetStatusMessageView(message: "This is required to create your profile or fetch it on this device")
}
