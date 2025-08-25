//
//  DashboardView.swift
//  Kineo
//
//  Created by 唐惠 on 2025/03/24.
//

import SwiftUI

// MARK: - 极简 Dashboard View
struct DashboardView: View {
    
    // MARK: - 状态对象
    @StateObject private var viewModel = MotionViewModel()
    
    // MARK: - 视图
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("Kineo Dashboard")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 接收到的数字显示
            VStack(spacing: 10) {
                Text("从 Watch 接收的数字")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.receivedNumber)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("📱 iPhone: DashboardView 出现")
        }
    }
}

// MARK: - 预览
#Preview {
    DashboardView()
} 
