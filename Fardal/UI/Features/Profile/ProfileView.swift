//
//  ProfileView.swift
//  Fardal
//
//  Created by Tobias Scholze on 29.12.23.
//

import SwiftUI

/// Represents a [View] that shows the detail and
///  other self-service information for the signed-in user
struct ProfileView: View {
    // MARK: - System properties -
    
    @Environment(\.openURL) private var openURL

    // MARK: - UI -
    
    var body: some View {
        Form {
            makeAvatarSection()
            makeIapSection()
            makeSupportSection()
        }
    }
}

// MARK: - View builders -

extension ProfileView {
    @ViewBuilder
    private func makeAvatarSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            VStack {
                ProfileAvatar(style: .header)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Profile.Section.Avatar.MockGreeting")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
            }
        }
    }

    @ViewBuilder
    private func makeIapSection() -> some View {
        Section("ProfileView.Section.IAP") {
            LabeledContent("ProfileView.Section.IAP.Tier", value: "Premium")
            LabeledContent("ProfileView.Section.IAP.Costs", value: "2.99 €")
            LabeledContent("ProfileView.Section.IAP.RenewDate", value: "24.12.2023")
        }
    }

    private func makeSupportSection() -> some View {
        Section("ProfileView.Section.Help") {
            List {
                Button("ProfileView.Section.Help.Support") {
                    onSupportTapped()
                }

                Button("ProfileView.Section.Help.About") {
                    onAboutTapped()
                }

                Button("ProfileView.Section.Help.Contact") {
                    onContactapped()
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

// MARK: - Actions -

extension ProfileView {
    private func onSupportTapped() {
        openURL(FardalConstants.Links.githubUrl)
    }

    private func onAboutTapped() {
        openURL(FardalConstants.Links.githubUrl)
    }

    private func onContactapped() {
        openURL(FardalConstants.Links.contactUrl)
    }
}

// MARK: - UI -

#Preview {
    ProfileView()
}
