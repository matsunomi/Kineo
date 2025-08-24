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
            ScrollView {
                VStack(spacing: 20) {
                    // 连接状态视图
                    ConnectionStatusView(
                        connectionStatus: viewModel.connectionStatus,
                        isWatchPaired: viewModel.isWatchPaired,
                        isWatchAppInstalled: viewModel.isWatchAppInstalled
                    )
                    
                    // Watch 控制按钮
                    WatchControlButtonsView(
                        isWatchTracking: viewModel.isWatchTracking,
                        onStartTracking: viewModel.startWatchTracking,
                        onStopTracking: viewModel.stopWatchTracking
                    )
                    
                    // iPhone 控制按钮
                    iPhoneControlButtonsView(
                        isReceivingData: viewModel.isReceivingData,
                        onStartReceiving: viewModel.startReceiving,
                        onStopReceiving: viewModel.stopReceiving
                    )
                    
                    // 诊断按钮
                    DiagnosticButtonView(viewModel: viewModel)
                    
                    // 运动数据显示
                    if let motionData = viewModel.currentMotionData {
                        MotionDataView(motionData: motionData)
                    } else {
                        NoDataView()
                    }
                    
                    // 接收到的数字显示
                    if let number = viewModel.receivedNumber {
                        ReceivedNumberView(number: number)
                    }
                    
                    // 错误信息显示
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage)
                    }
                    
                    // Watch 应用状态
                    WatchAppStatusView(
                        isWatchPaired: viewModel.isWatchPaired,
                        isWatchAppInstalled: viewModel.isWatchAppInstalled
                    )
                }
                .padding()
            }
            .navigationTitle("Kineo Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Diagnostic Button View
struct DiagnosticButtonView: View {
    let viewModel: MotionViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("诊断工具")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("🔍 重新检查状态") {
                    // 手动触发状态检查
                    viewModel.startReceiving()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("🧪 测试消息接收") {
                    // 测试消息接收功能
                    viewModel.testMessageReception()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Text("左侧：重新检查状态 | 右侧：测试消息接收")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Received Number View
struct ReceivedNumberView: View {
    let number: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("从 Watch 接收的数字")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("最新数字: \(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
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
    let isWatchPaired: Bool
    let isWatchAppInstalled: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Apple Watch 应用状态")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                StatusIndicator(
                    title: "配对状态",
                    isActive: isWatchPaired,
                    activeColor: .green,
                    inactiveColor: .red
                )
                
                StatusIndicator(
                    title: "应用安装",
                    isActive: isWatchAppInstalled,
                    activeColor: .green,
                    inactiveColor: .orange
                )
            }
            
            if !isWatchAppInstalled {
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
    let connectionStatus: ConnectionStatus
    let isWatchPaired: Bool
    let isWatchAppInstalled: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(connectionStatus.color)
                    .frame(width: 12, height: 12)
                
                Text(connectionStatus.displayText)
                    .font(.headline)
                    .foregroundColor(connectionStatus.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(connectionStatus.color.opacity(0.1))
            )
            
            // 状态详情
            VStack(spacing: 4) {
                HStack {
                    Circle()
                        .fill(isWatchPaired ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text("Watch 配对: \(isWatchPaired ? "是" : "否")")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(isWatchAppInstalled ? .green : .orange)
                        .frame(width: 8, height: 8)
                    Text("Watch 应用: \(isWatchAppInstalled ? "已安装" : "未安装")")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Watch Control Buttons View
struct WatchControlButtonsView: View {
    let isWatchTracking: Bool
    let onStartTracking: () -> Void
    let onStopTracking: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Apple Watch 控制")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Button(action: onStartTracking) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("启动追踪")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isWatchTracking ? Color.gray : Color.green)
                    )
                }
                .disabled(isWatchTracking)
                
                Button(action: onStopTracking) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("停止追踪")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(!isWatchTracking ? Color.gray : Color.red)
                    )
                }
                .disabled(!isWatchTracking)
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
    let isReceivingData: Bool
    let onStartReceiving: () -> Void
    let onStopReceiving: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("iPhone 接收控制")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Button(action: onStartReceiving) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("开始接收")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isReceivingData ? Color.gray : Color.blue)
                    )
                }
                .disabled(isReceivingData)
                
                Button(action: onStopReceiving) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.slash")
                        Text("停止接收")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(!isReceivingData ? Color.gray : Color.orange)
                    )
                }
                .disabled(!isReceivingData)
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