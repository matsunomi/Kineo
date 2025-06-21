//
//  ContentView.swift
//  watch Watch App
//
//  Created by 唐惠 on 2025/06/14.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = WatchMotionViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            // Status
            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if viewModel.isUpdating {
                if let motionData = viewModel.motionData {
                    // Motion Data Display
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Acceleration")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("X: \(motionData.acceleration.x, specifier: "%.2f")")
                        Text("Y: \(motionData.acceleration.y, specifier: "%.2f")")
                        Text("Z: \(motionData.acceleration.z, specifier: "%.2f")")
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Rotation")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("X: \(motionData.rotation.x, specifier: "%.2f")")
                        Text("Y: \(motionData.rotation.y, specifier: "%.2f")")
                        Text("Z: \(motionData.rotation.z, specifier: "%.2f")")
                    }
                } else {
                    Text("Collecting...")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Ready to start")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Control Button
            Button(action: {
                if viewModel.isUpdating {
                    viewModel.stopUpdates()
                } else {
                    viewModel.startUpdates()
                }
            }) {
                Text(viewModel.isUpdating ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(viewModel.isUpdating ? Color.red : Color.green)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .previewDevice("Apple Watch Series 9 - 45mm")
}
