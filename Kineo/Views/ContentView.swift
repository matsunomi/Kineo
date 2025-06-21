//
//  ContentView.swift
//  Kineo
//
//  Created by 唐惠 on 2025/03/24.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = MotionViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Motion Data")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Motion Data Display
            if let motionData = viewModel.motionData {
                VStack(alignment: .leading, spacing: 15) {
                    // Acceleration
                    Group {
                        Text("Acceleration")
                            .font(.headline)
                        HStack {
                            Text("X: \(motionData.acceleration.x, specifier: "%.2f")")
                            Text("Y: \(motionData.acceleration.y, specifier: "%.2f")")
                            Text("Z: \(motionData.acceleration.z, specifier: "%.2f")")
                        }
                    }
                    
                    // Rotation
                    Group {
                        Text("Rotation")
                            .font(.headline)
                        HStack {
                            Text("X: \(motionData.rotation.x, specifier: "%.2f")")
                            Text("Y: \(motionData.rotation.y, specifier: "%.2f")")
                            Text("Z: \(motionData.rotation.z, specifier: "%.2f")")
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
            } else {
                Text("Waiting for motion data...")
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
                Text(viewModel.isUpdating ? "Stop Updates" : "Start Updates")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isUpdating ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .previewDevice("iPhone 15")
}
