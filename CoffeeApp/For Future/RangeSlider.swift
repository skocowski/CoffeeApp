//
//  RangeSlider.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 3/3/23.
//

import SwiftUI

struct RangeSlider: View {
    
    @EnvironmentObject var dataController: DataController
    
    @State var width: CGFloat = 0
    @State var width1: CGFloat = 95
    
    @State var product = ""
    
    
    var body: some View {
        VStack {
            
            Picker("Choose a product", selection: $product) {
                ForEach(dataController.usedWords.sorted(by: <), id: \.self) { product in
                    Text(product)
                }
            }
            
            GeometryReader { geo in
                VStack {
                    
                    Text("Value:")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(self.getValue(val: self.width)) - \(self.getValue(val: self.width1))")
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 6)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: self.width1 - self.width, height: 6)
                            .offset(x: self.width + 18)
                        
                        HStack(spacing: 0) {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 18, height: 18)
                                .offset(x: self.width)
                                .gesture(
                                    DragGesture()
                                        .onChanged() { value in
                                            if value.location.x >= 0 && value.location.x <= self.width1 {
                                                self.width = value.location.x
                                            }
                                        }
                                )
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: 18, height: 18)
                                .offset(x: self.width1)
                                .gesture(
                                    DragGesture()
                                        .onChanged() { value in
                                            if value.location.x <= (geo.size.width - 60) && value.location.x >= self.width {
                                                self.width1 = value.location.x
                                            }
                                        }
                                )
                        }
                    }
                    .padding(.top, 25)
                }
                .padding()
            }
        }
    }
    
    func getValue(val: CGFloat) -> String {
        
        return String(format: "%.2f", val)
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSlider()
            .environmentObject(DataController())
    }
}
