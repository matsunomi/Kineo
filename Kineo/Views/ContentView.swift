//
//  ContentView.swift
//  Kineo
//
//  Created by 唐惠 on 2025/03/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            DashboardView()
                .navigationTitle("Kineo")
        }
    }
}

#Preview {
    ContentView()
        .previewDevice("iPhone 15")
}
