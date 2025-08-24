//
//  DashboardView.swift
//  Kineo
//
//  Created by 唐惠 on 2025/03/24.
//

import SwiftUI

struct DashboardView: View {
    // MARK: - Properties
    @StateObject private var viewModel = MotionViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Motion Data Display
            if let motionData = viewModel.motionData {
                MotionDataCard(motionData: motionData)
            } else {
                WaitingForDataView()
            }
            
            Spacer()
            
            // Control Button
            MotionControlButton(isUpdating: viewModel.isUpdating) {
                if viewModel.isUpdating {
                    viewModel.stopUpdates()
                } else {
                    viewModel.startUpdates()
                }
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct MotionDataCard: View {
    let motionData: MotionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Acceleration (Linear)
            Group {
                Text("Linear Acceleration")
                    .font(.headline)
                    .foregroundColor(.blue)
                HStack {
                    Text("X: \(motionData.acceleration.x, specifier: "%.3f")")
                    Text("Y: \(motionData.acceleration.y, specifier: "%.3f")")
                    Text("Z: \(motionData.acceleration.z, specifier: "%.3f")")
                }
                .font(.system(.body, design: .monospaced))
            }
            
            Divider()
            
            // Gyroscope (Rotation Rate)
            Group {
                Text("Gyroscope (Rotation Rate)")
                    .font(.headline)
                    .foregroundColor(.green)
                HStack {
                    Text("X: \(motionData.rotation.x, specifier: "%.3f")")
                    Text("Y: \(motionData.rotation.y, specifier: "%.3f")")
                    Text("Z: \(motionData.rotation.z, specifier: "%.3f")")
                }
                .font(.system(.body, design: .monospaced))
                
                // Rotation magnitude
                Text("Magnitude: \(motionData.rotationMagnitude, specifier: "%.3f") rad/s")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Rotation in degrees/s
                let rotationDegrees = motionData.rotationDegreesPerSecond
                Text("Degrees/s - X: \(rotationDegrees.x, specifier: "%.1f")° Y: \(rotationDegrees.y, specifier: "%.1f")° Z: \(rotationDegrees.z, specifier: "%.1f")°")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct WaitingForDataView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sensor.tag.radiowaves.forward")
                .font(.system(.largeTitle))
                .foregroundColor(.secondary)
            Text("Waiting for motion data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct MotionControlButton: View {
    let isUpdating: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isUpdating ? "stop.fill" : "play.fill")
                    .font(.headline)
                Text(isUpdating ? "Stop Updates" : "Start Updates")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isUpdating ? Color.red : Color.green)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .previewDevice("iPhone 15")
} 