//
//  SalaryCircleView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/15.
//

import SwiftUI

struct SalaryCircleView: View {
    @Binding var desiredSalary: Int
    @Binding var salary: Double
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
                    
                    Text("\(Int(salary)) $")
                        .font(.system(size: 30, weight: .bold, design: .default))
                    
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    SalaryCircleView(desiredSalary: .constant(10000), salary: .constant(9000))
}
