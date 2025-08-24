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
                
                Text(viewModel.isUpdating ? "追踪中" : "等待命令")
                    .font(.caption2)
                    .foregroundColor(viewModel.isUpdating ? .green : .red)
            }
            
            // 运动数据显示
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