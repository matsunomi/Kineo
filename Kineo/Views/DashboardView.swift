//
//  DashboardView.swift
//  Kineo
//
//  Created by 唐惠 on 2025/03/24.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 连接状态指示器
                ConnectionStatusView(status: viewModel.connectionStatus)
                
                // Watch 应用状态检查
                WatchAppStatusView(viewModel: viewModel)
                
                // 接收到的数字显示
                ReceivedNumberView(viewModel: viewModel)
                
                // Watch 控制按钮
                WatchControlButtonsView(
                    isTracking: viewModel.isWatchTracking,
                    onStart: viewModel.startWatchTracking,
                    onStop: viewModel.stopWatchTracking
                )
                
                // iPhone 接收控制按钮
                iPhoneControlButtonsView(
                    isReceiving: viewModel.isReceivingData,
                    onStart: viewModel.startReceiving,
                    onStop: viewModel.stopReceiving
                )
                
                // 运动数据显示
                if let motionData = viewModel.currentMotionData {
                    MotionDataView(motionData: motionData)
                } else {
                    NoDataView()
                }
                
                // 错误信息显示
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Kineo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Received Number View
struct ReceivedNumberView: View {
    @ObservedObject var viewModel: MotionViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("从 Watch 接收的数字")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let receivedNumber = viewModel.receivedNumber {
                Text("最新数字: \(receivedNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            } else {
                Text("等待数字...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Watch App Status View
struct WatchAppStatusView: View {
    @ObservedObject var viewModel: MotionViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Apple Watch 应用状态")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                StatusIndicator(
                    title: "配对状态",
                    isActive: viewModel.isWatchPaired,
                    activeColor: .green,
                    inactiveColor: .red
                )
                
                StatusIndicator(
                    title: "应用安装",
                    isActive: viewModel.isWatchAppInstalled,
                    activeColor: .green,
                    inactiveColor: .orange
                )
                
                StatusIndicator(
                    title: "连接状态",
                    isActive: viewModel.connectionStatus == .connected,
                    activeColor: .green,
                    inactiveColor: .red
                )
            }
            
            if !viewModel.isWatchAppInstalled {
                Text("⚠️ Watch 应用未安装，请检查部署配置")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let title: String
    let isActive: Bool
    let activeColor: Color
    let inactiveColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? activeColor : inactiveColor)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Connection Status View
struct ConnectionStatusView: View {
    let status: ConnectionStatus
    
    var body: some View {
        HStack {
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
            
            Text(status.displayText)
                .font(.headline)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(status.color.opacity(0.1))
        )
    }
}

// MARK: - Watch Control Buttons View
struct WatchControlButtonsView: View {
    let isTracking: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Apple Watch 控制")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("启动追踪")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isTracking ? Color.gray : Color.green)
                    )
                }
                .disabled(isTracking)
                
                Button(action: onStop) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("停止追踪")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(!isTracking ? Color.gray : Color.red)
                    )
                }
                .disabled(!isTracking)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - iPhone Control Buttons View
struct iPhoneControlButtonsView: View {
    let isReceiving: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("iPhone 接收控制")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("开始接收")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isReceiving ? Color.gray : Color.blue)
                    )
                }
                .disabled(isReceiving)
                
                Button(action: onStop) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.slash")
                        Text("停止接收")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(!isReceiving ? Color.gray : Color.orange)
                    )
                }
                .disabled(!isReceiving)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Motion Data View
struct MotionDataView: View {
    let motionData: MotionData
    
    var body: some View {
        VStack(spacing: 16) {
            Text("实时运动数据")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DataRow(
                    title: "加速度",
                    value: String(format: "%.2f m/s²", motionData.accelerationMagnitude),
                    icon: "speedometer"
                )
                
                DataRow(
                    title: "旋转率",
                    value: String(format: "%.2f °/s", motionData.rotationMagnitudeDegreesPerSecond),
                    icon: "rotate.3d"
                )
                
                DataRow(
                    title: "X轴加速度",
                    value: String(format: "%.2f m/s²", motionData.acceleration.x),
                    icon: "arrow.left.and.right"
                )
                
                DataRow(
                    title: "Y轴加速度",
                    value: String(format: "%.2f m/s²", motionData.acceleration.y),
                    icon: "arrow.up.and.down"
                )
                
                DataRow(
                    title: "Z轴加速度",
                    value: String(format: "%.2f m/s²", motionData.acceleration.z),
                    icon: "arrow.up.and.down.forward"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Data Row
struct DataRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - No Data View
struct NoDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "watch")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("等待 Apple Watch 数据")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("请先启动 Apple Watch 追踪，然后开始接收数据")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
    }
}

#Preview {
    DashboardView()
} 