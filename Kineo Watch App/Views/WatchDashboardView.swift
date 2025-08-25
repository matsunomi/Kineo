//
//  WatchDashboardView.swift
//  watch Watch App
//
//  Created by 唐惠 on 2025/06/14.
//

import SwiftUI

// MARK: - 极简 Watch Dashboard View
struct WatchDashboardView: View {
    
    // MARK: - 状态对象
    @StateObject private var viewModel = WatchMotionViewModel()
    
    // MARK: - 视图
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("Kineo Watch")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 发送按钮
            Button("发送数字 1") {
                Task {
                    do {
                        try await viewModel.sendNumberToiPhone("1")
                    } catch {
                        print("⌚️ Watch: 发送失败: \(error)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            // 点击次数
            VStack(spacing: 5) {
                Text("点击次数")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.clickCount)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("⌚️ Watch: WatchDashboardView 出现")
        }
    }
}

// MARK: - 预览
#Preview {
    WatchDashboardView()
} 
