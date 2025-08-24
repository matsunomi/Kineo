//
//  WatchDashboardView.swift
//  watch Watch App
//
//  Created by 唐惠 on 2025/06/14.
//

import SwiftUI

struct WatchDashboardView: View {
    @StateObject private var viewModel = WatchMotionViewModel()
    
    var body: some View {
        VStack(spacing: 8) {
            // 状态指示器
            HStack {
                Circle()
                    .fill(viewModel.isUpdating ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isUpdating ? "追踪中" : "已停止")
                    .font(.caption2)
                    .foregroundColor(viewModel.isUpdating ? .green : .red)
            }
            
            // 运动数据显示
            if let motionData = viewModel.currentMotionData {
                MotionDataDisplay(motionData: motionData)
            } else {
                NoDataDisplay()
            }
            
            // 控制按钮
            HStack(spacing: 8) {
                Button(action: viewModel.startUpdates) {
                    Image(systemName: "play.fill")
                        .font(.caption)
                }
                .disabled(viewModel.isUpdating)
                
                Button(action: viewModel.stopUpdates) {
                    Image(systemName: "stop.fill")
                        .font(.caption)
                }
                .disabled(!viewModel.isUpdating)
            }
            
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
            
            Text("等待数据...")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WatchDashboardView()
} 