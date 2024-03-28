//
//  ProfileView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import SwiftData

// Placeholder enum for ProfileImage
enum ProfileImage: Int, CaseIterable {
    case defaultImage = 0
    // Add more cases as needed
    
    var imageName: String {
        switch self {
        case .defaultImage: return "default-profile-image" // Placeholder image name
            // Handle other cases
        }
    }
}

// Placeholder enum for BannerImage
enum BannerImage: Int, CaseIterable {
    case defaultBanner = 0
    // Add more cases as needed
    
    var imageName: String {
        switch self {
        case .defaultBanner: return "default-profile-banner" // Placeholder banner name
            // Handle other cases
        }
    }
}

struct ProfileBannerView: View {
    var profileImageName: ProfileImage // Assuming this is the name of the profile image in your assets
    var bannerImageName: BannerImage // Assuming this is the name of the banner image in your assets
    
    var body: some View {
        ZStack {
            Image(profileImageName.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            Image(bannerImageName.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
        }
    }
}

// Example Enum for Title (implement similar enums for Banner and ProfileImage)
enum ProfileTitle: Int, CaseIterable {
    case none = 0
    // Add more cases as needed
    var description: String {
        switch self {
        case .none: return "No Title"
            // Handle other cases
        }
    }
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(Profile.local) var SD_profiles: [Profile]
    @State var field: String = ""
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            if isEditing {
                // Edit View - simplified for demonstration
                TextField("Player Name", text: $field)
                // Add selectors for title, banner, and profileImage based on enums
                Button("Save") {
                    Task {
                        self.SD_profiles[0].playerName = field
                        try? self.modelContext.save()
                        self.isEditing = false
                    }
                    
                }
            } else {
                VStack(alignment: .center, spacing: 10) {
                    
                    ProfileBannerView(
                        profileImageName: ProfileImage(
                            rawValue: self.SD_profiles[0].profileImage)!,
                        bannerImageName: BannerImage(rawValue: self.SD_profiles[0].banner)!
                    )
//                    // Display banner
//                    Image(BannerImage(rawValue: self.SD_profiles[0].banner)?.imageName ?? "default-banner")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 300, height: 100)
//                    
//                    // Profile image with circular framing
//                    Image(ProfileImage(rawValue: self.SD_profiles[0].profileImage)?.imageName ?? "default-profile-image")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
//                        .shadow(radius: 10)
//                        .padding(.bottom, -50) // Adjust as necessary based on banner design
                    
                    VStack {
                        Text(self.SD_profiles[0].playerName)
                        Text("Rating: \(self.SD_profiles[0].eloRating)")
                        Text("Title: \(ProfileTitle(rawValue: self.SD_profiles[0].title)?.description ?? "Unknown")")
                    }
                    .padding(.top, 50) // Adjust to ensure text doesn't overlap with the image
                }
                
                
                // Display View
                Button("Edit") {
                    self.isEditing = true
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
        .shadow(radius: 5)
        .frame(width: 300, height: 400) // Adjust size as needed
    }
}

#Preview {
    ProfileView()
        .modelContainer(previewContainer)
}
