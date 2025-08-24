//
//  WatchDashboardView.swift
//  watch Watch App
//
//  Created by 唐惠 on 2025/06/14.
//

import SwiftUI

struct WatchDashboardView: View {
    @StateObject private var viewModel = WatchMotionViewModel()
    @State private var inputNumber: String = ""
    @State private var lastSentNumber: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            // 状态指示器
            HStack {
                Circle()
                    .fill(viewModel.isUpdating ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isUpdating ? "追踪中" : "等待命令")
                    .font(.caption2)
                    .foregroundColor(viewModel.isUpdating ? .green : .red)
            }
            
            // 连接状态
            HStack {
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isConnected ? "已连接" : "未连接")
                    .font(.caption2)
                    .foregroundColor(viewModel.isConnected ? .green : .red)
            }
            
            // 数字输入
            HStack {
                TextField("输入数字", text: $inputNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                
                Button("发送") {
                    sendNumber()
                }
                .disabled(inputNumber.isEmpty)
            }
            
            // 最后发送的数字
            if !lastSentNumber.isEmpty {
                Text("已发送: \(lastSentNumber)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            // 运动数据显示（保留原有功能）
            if let motionData = viewModel.currentMotionData {
                MotionDataDisplay(motionData: motionData)
            } else {
                NoDataDisplay()
            }
            
            // 提示信息
            Text("由 iPhone 远程控制")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 错误信息
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(8)
    }
    
    private func sendNumber() {
        guard !inputNumber.isEmpty else { return }
        
        Task {
            do {
                try await viewModel.sendNumberToiPhone(inputNumber)
                lastSentNumber = inputNumber
                inputNumber = ""
            } catch {
                print("Watch: 发送数字失败: \(error)")
            }
        }
    }
}

// MARK: - Motion Data Display
struct MotionDataDisplay: View {
    let motionData: MotionData
    
    var body: some View {
        VStack(spacing: 4) {
            Text("加速度: \(motionData.accelerationMagnitude, specifier: "%.2f")")
                .font(.caption2)
                .foregroundColor(.blue)
            
            Text("旋转: \(motionData.rotationMagnitudeDegreesPerSecond, specifier: "%.1f")°/s")
                .font(.caption2)
                .foregroundColor(.green)
        }
    }
}

// MARK: - No Data Display
struct NoDataDisplay: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "sensor.tag.radiowaves.forward")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("等待 iPhone 命令")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WatchDashboardView()
} 