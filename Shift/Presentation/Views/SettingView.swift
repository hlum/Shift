//
//  SettingView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    Text("Hello")
                } label: {
                    Text("Company")

                }
            } header: {
                Text("Company List")
            }

        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
