//
//  StatsView.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 9/3/23.
//

import SwiftUI

struct StatsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Namespace var animation
    @State private var showRange = false
    @State private var currentTab = "Summary"
    

    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack {
                    Text(!showRange ? "Choose date" : "Choose start date")
                    Spacer()
                    Text(formattingDate(date: dataController.startingDate))
                        .padding(5)
                        .padding(.horizontal, 15)
                        .foregroundColor(.blue)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                                .foregroundColor(.blue)
                        }
                        .overlay {
                            DatePicker("", selection: $dataController.startingDate, in: ...Date(), displayedComponents: [.date])
                                .labelsHidden()
                                .blendMode(.destinationOver)
                                .onChange(of: dataController.startingDate, perform: { newDate in
                                    if !showRange {
                                        dataController.finishDate = newDate
                                    }
                                })

                                
                            }
                }

                if showRange {
                    HStack {
                        Text("Choose end date")
                        Spacer()
                        Text(formattingDate(date: dataController.finishDate))
                            .padding(5)
                            .padding(.horizontal, 15)
                            .foregroundColor(.blue)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .foregroundColor(.blue)
                            }
                            .overlay {
                                DatePicker("", selection: $dataController.finishDate, in: ...Date(), displayedComponents: [.date])
                                    .labelsHidden()
                                    .blendMode(.destinationOver)
                                }
                    }
                }


                Toggle("Show range of dates?", isOn: $showRange)
                    .onChange(of: showRange) { _ in
                        if !showRange {
                            dataController.finishDate = dataController.startingDate
                        }
                    }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
                            Divider()
                                .frame(height: 2)
                                .overlay(.blue)
            
            CustomSegmentedBar()
                .padding(.horizontal)
                .padding(.top, 5)
            
            if currentTab == "Summary" {
                summary()
            } else {
                TransactionsListView()
            }
        }
    }
    
    func summary() -> some View {
        List(dataController.items.sorted { $0.quantity > $1.quantity }, id: \.self) { item in
            HStack {
                Image(systemName: "\(item.quantity).square")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Text(item.title)
                Spacer()
                Text("\(asNumber(value: item.value))")
                    .foregroundColor(item.value < 0 ? .red : Color.theme.universal)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func CustomSegmentedBar() -> some View {
        let tabs = ["Summary", "Transactions"]

        HStack {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.blue)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    
                    .background {
                        if currentTab == tab {
                            Capsule()
                                .fill(Color.theme.tabBackground)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        } else {
                            Capsule()
                                .stroke(Color.theme.tabBackground, lineWidth: 1)
                        }
                    }
                    .contentShape(Capsule())
                    
                    .onTapGesture {
                        withAnimation {
                            currentTab = tab
                        }
                    }
            }
        }
    }
}



