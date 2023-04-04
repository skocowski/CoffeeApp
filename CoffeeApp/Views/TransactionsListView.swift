//
//  TransactionsListView.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 9/3/23.
//

import SwiftUI
import CoreData

struct TransactionsListView: View {
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        
        List {
            ForEach(dataController.savedTransactions) { transaction in
                HStack {
                    Button {
                        withAnimation {
                            dataController.addEditTransaction(
                                title: transaction.wrappedTitle,
                                value: transaction.value,
                                isExpense: transaction.isExpense,
                                date: Date(),
                                context: moc)
                        }
                    } label: {
                        Image(systemName: "plus.app")
                            .font(.system(size: 35))
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        dataController.editTransaction = transaction
                        dataController.showingEditView = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(transaction.title ?? "")
                                    .bold()
                                Text(calcTimeSince(date: transaction.date!))
                                    .foregroundColor(.gray)
                                    .italic()
                                    .font(.caption)
                                
                            }
                            Spacer()
                            HStack {
                                if transaction.isExpense {
                                    Text("-")
                                        .foregroundColor(.red)
                                        .font(.headline)
                                }
                                Text("\(asNumber(value: transaction.value))")
                                    .foregroundColor(transaction.isExpense ? .red : Color.theme.universal)
                                    .font(.headline)
                            }
                            
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .sheet(isPresented: $dataController.showingEditView) {
                    AddTransactionView(
                        transactionTitle: transaction.wrappedTitle,
                        transactionValue: transaction.value,
                        transactionDate: transaction.wrappedDate,
                        isExpense: transaction.isExpense)
                }
            }
            
            .onDelete(perform: dataController.deleteItem)
            .listRowSeparatorTint(.blue)
        }
        .listStyle(.plain)
        
        
    }
    
    
}
