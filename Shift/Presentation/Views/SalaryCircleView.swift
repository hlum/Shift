//
//  SalaryCircleView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/15.
//

import SwiftUI

struct SalaryCircleView: View {
    let desiredSalary: Int
    let salary: Int
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                Circle()
                    .trim(from: 0, to: CGFloat(Double(salary) / Double(desiredSalary)))
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(radius: 1)
                
                VStack {
                    Text("Expected Salary")
                    
                    Text("\(salary) $")
                        .font(.system(size: 30, weight: .bold, design: .default))
                    
                }
            }
        }
        .padding(.horizontal, 60)
    }
}

#Preview {
    SalaryCircleView(desiredSalary: 10000, salary: 9000)
}
