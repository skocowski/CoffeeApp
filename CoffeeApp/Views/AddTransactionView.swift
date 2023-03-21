//
//  AddItemView.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 19/2/23.
//

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var savingUsedWords = SavingUsedWords()
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var transactionTitle: String = ""
    @State var transactionValue: Double?
    @State var transactionDate: Date = Date()
    @State var isExpense: Bool = false
    @State var showCalendar = false
    
    @State var usedWords = Set<String>()
    
    @FocusState private var isTitleFocused: Bool
    var body: some View {
        VStack {
            Text("Add new transaction")
            VStack(alignment: .leading, spacing: 12) {
                Text("Transaction title")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("", text: $transactionTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
                    .focused($isTitleFocused)
                
                if (transactionTitle != "") && isTitleFocused &&  !(savingUsedWords.usedWords.filter { self.searchFor($0) }.isEmpty) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(savingUsedWords.usedWords.filter { self.searchFor($0) }.sorted(by: {$0 < $1 }), id: \.self) { title in
                                HStack {
                                    Text(title)
                                        .onTapGesture { transactionTitle = title }
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.theme.suggestionsBackground.opacity(0.9))
                    .cornerRadius(10)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
            
            Divider()
                .frame(height: 1)
                .background(.blue)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Transaction value")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("", value: $transactionValue, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
            }
            .padding(.top, 10)
            
            Divider()
                .frame(height: 1)
                .background(.blue)
            
     
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Transaction date")
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack {
                    
                    Text(transactionDate.formatted(date: .abbreviated, time: .shortened))
                    Spacer()
                    Button {
                        showCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            
            Divider()
                .frame(height: 1)
                .background(.blue)
            
            Toggle(isOn: $isExpense) {
                Text("Is it an expense?")
            }
            .padding(.vertical, 10)

            Spacer()
            
            Button {
                dataController.addEditTransaction(
                    title: transactionTitle,
                    value: transactionValue ?? 0,
                    isExpense: isExpense,
                    date: transactionDate,
                    context: moc)
                
                dataController.editTransaction = nil
                savingUsedWords.add(transactionTitle)
                dismiss()
            } label: {
                Text("Submit")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background {
                        Capsule()
                            .fill(.black)
                    }
            }
            .padding(.bottom, 10)
            .disabled(transactionTitle == "" && transactionValue == nil)
            .opacity(transactionTitle == "" ? 0.6 : 1)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear {
            if let transaction = dataController.editTransaction {
                transactionTitle = transaction.wrappedTitle
                transactionValue = transaction.value
                isExpense = transaction.isExpense
                transactionDate = transaction.wrappedDate
            }
        }
        .overlay {
            ZStack {
                if showCalendar {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showCalendar = false
                        }
                    
                    DatePicker("", selection: $transactionDate, in: ...Date())
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
             //           .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding()
                }
            }
            .animation(.easeOut, value: showCalendar)
        }
             
    }
    private func searchFor(_ txt: String) -> Bool {
        return (txt.lowercased().contains(transactionTitle.lowercased()) || transactionTitle.isEmpty)
    }
}
