//
//  ContentView.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 12/2/23.
//

import SwiftUI
import CoreData
struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Namespace var animation
    
    @State private var showingAddView = false {
        didSet {
            dataController.editTransaction = nil
        }
    }
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {

                CustomSegmentedBar()
                    .padding(.horizontal, 5)
                resultBar
                    .padding(.horizontal, 5)
                Divider()
                    .frame(height: 1)
                    .overlay(.blue)
                
                if !dataController.savedTransactions.isEmpty {
                    TransactionsListView()
                } else {
                    noTransactions
                }
                    

                Spacer()
            }
            .navigationTitle("Your Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddView.toggle()
                    } label: {
                        Label("Add item", systemImage: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                dataController.editTransaction = nil
            } content: {
                
                AddTransactionView()
            }
            
        }
    }
    
    
    private var resultBar: some View {
        
        HStack {
            Text("\(asNumber(value: dataController.totalSellToday()))")
                .barValue()
                .foregroundColor(dataController.totalSellToday() < 0 ? .red : .green)
            
            Text("\(asNumber(value: dataController.totalSellYesterday()))")
                .barValue()
                .foregroundColor(dataController.totalSellYesterday() < 0 ? .red : .green)
            
            Text("\(asNumber(value: dataController.totalSellWeek()))")
                .barValue()
                .foregroundColor(dataController.totalSellWeek() < 0 ? .red : .green)
            
            Text("\(asNumber(value: dataController.totalSellMonth()))")
                .barValue()
                .foregroundColor(dataController.totalSellMonth() < 0 ? .red : .green)
        }
        
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    func CustomSegmentedBar() -> some View {
        let tabs = ["Today", "Yesterday", "Week", "Month"]
        
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? Date()

        let beginingOfWeek = Date().startOfWeek
        let beginingOfMonth = Date().startOfMonth
        
        let startingDatefunctions = [today, yesterday, beginingOfWeek, beginingOfMonth]
        let finishDateFunctions = [Date(), yesterday, Date(), Date()]
        
        HStack {
       
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(dataController.currentTab == tab ? Color.theme.tabFontLight : Color.theme.tabFontDark)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background {
                        if dataController.currentTab == tab {
                            Capsule()
                                .fill(Color.theme.tabBackground)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation {
                            dataController.currentTab = tab
                            dataController.startingDate = startingDatefunctions[index] ?? Date()
                            dataController.finishDate = finishDateFunctions[index]
                         
                        }
                    }
            }
        }
    }
    private var noTransactions: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("No transactions")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.accentColor)
                Text("Press the button to add a new transaction.")
                    .padding(.bottom, 20)
                    .foregroundColor(Color.accentColor)
                
                Button {
                    showingAddView.toggle()
                } label: {
                    Text("Add transaction")
                        .foregroundColor(Color.accentColor)
                        .font(.title2)
                        .bold()
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.red)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: 400)
            .multilineTextAlignment(.center)
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

