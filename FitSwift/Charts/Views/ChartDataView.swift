//
//  ChartDataView.swift
//  FitSwift
//
//  Created by csuftitan on 4/27/25.
//

import SwiftUI

struct ChartDataView: View {
    @State var average: Int
    @State var total: Int
    
    var body: some View {
        HStack {
            Spacer()
            // Average
            VStack(spacing: 16) {
                Text("Average")
                    .font(.title2)
                
                Text(average.formatted())
                    .font(.title3)
            }
            .frame(width: 80)
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            // Total
            VStack(spacing: 16) {
                Text("Total")
                    .font(.title2)
                
                Text(total.formatted())
                    .font(.title3)
            }
            .frame(width: 80)
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
        }
    }
}

#Preview {
    ChartDataView(average: 123, total: 456)
}
