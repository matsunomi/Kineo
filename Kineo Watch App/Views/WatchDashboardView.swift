//
//  WatchDashboardView.swift
//  watch Watch App
//
//  Created by 唐惠 on 2025/06/14.
//

import SwiftUI

struct WatchDashboardView: View {
    // MARK: - Properties
    @StateObject private var viewModel = WatchMotionViewModel()
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                Text("Kineo")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Status or Data Display
                if let error = viewModel.error {
                    WatchErrorView(error: error)
                } else if viewModel.isUpdating {
                    if let motionData = viewModel.motionData {
                        WatchMotionDataView(motionData: motionData)
                    } else {
                        WatchLoadingView()
                    }
                } else {
                    WatchReadyView()
                }
                
                Spacer(minLength: 8)
                
                // Control Button
                WatchControlButton(isUpdating: viewModel.isUpdating) {
                    if viewModel.isUpdating {
                        viewModel.stopUpdates()
                    } else {
                        viewModel.startUpdates()
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Supporting Views
struct WatchErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(.title2))
            Text(error.localizedDescription)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }
}

struct WatchLoadingView: View {
    var body: some View {
        VStack(spacing: 4) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Collecting...")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct WatchReadyView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "play.circle.fill")
                .foregroundColor(.green)
                .font(.system(.title2))
            Text("Ready to start")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct WatchMotionDataView: View {
    let motionData: MotionData
    
    var body: some View {
        VStack(spacing: 6) {
            // Acceleration Section
            VStack(spacing: 2) {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.blue)
                        .font(.system(.caption))
                    Text("ACCEL")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 8) {
                    WatchDataPoint(label: "X", value: motionData.acceleration.x)
                    WatchDataPoint(label: "Y", value: motionData.acceleration.y)
                    WatchDataPoint(label: "Z", value: motionData.acceleration.z)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(6)
            
            // Gyroscope Section
            VStack(spacing: 2) {
                HStack {
                    Image(systemName: "rotate.3d")
                        .foregroundColor(.green)
                        .font(.system(.caption))
                    Text("GYRO")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 8) {
                    WatchDataPoint(label: "X", value: motionData.rotation.x)
                    WatchDataPoint(label: "Y", value: motionData.rotation.y)
                    WatchDataPoint(label: "Z", value: motionData.rotation.z)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.1))
            .cornerRadius(6)
            
            // Magnitude Display
            HStack(spacing: 12) {
                WatchMagnitudeView(
                    label: "ACC",
                    value: motionData.accelerationMagnitude,
                    color: .blue
                )
                WatchMagnitudeView(
                    label: "ROT",
                    value: motionData.rotationMagnitude,
                    color: .green
                )
            }
        }
    }
}

struct WatchDataPoint: View {
    let label: String
    let value: Double
    
    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f", value))
                .font(.system(.caption2, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WatchMagnitudeView: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(color)
            Text(String(format: "%.2f", value))
                .font(.system(.caption2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(4)
    }
}

struct WatchControlButton: View {
    let isUpdating: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isUpdating ? "stop.fill" : "play.fill")
                    .font(.system(.caption))
                Text(isUpdating ? "Stop" : "Start")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isUpdating ? Color.red : Color.green)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    WatchDashboardView()
        .previewDevice("Apple Watch Series 9 - 45mm")
} 