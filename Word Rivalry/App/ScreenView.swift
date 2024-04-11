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
    let status: String = iCloudService.shared.statusMessage()
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("iCloud Status")
                .font(.headline)
                .padding(.top, 2)
            Text(
                status
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
        }
        .padding()
        .background(.clear)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct InternetStatusMessageView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("Internet Connection Required")
                .font(.headline)
                .padding(.top, 2)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(.clear)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    IcloudStatusMessageView()
}
