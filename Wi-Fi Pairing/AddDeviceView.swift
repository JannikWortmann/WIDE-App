//
//  AddDeviceView.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 24.02.22.
//

import Foundation
import SwiftUI

struct AddDeviceView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    @State var showingAlert = false
    @State var alertMessage = "New Device named 'Test' has been added"
    
    @State var username = ""
    @State var password = ""
    @State var broadcastid = ""
    @State var devicetype = ""
    @State var manufacturer = ""
    @State var description = ""
    
    
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Group{
                        Text("Username")
                            .font(.headline)
                        TextField(UUID().uuidString.prefix(10), text: $username)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                            .accessibility(hint: Text("test123"))
                    }
                    .listRowSeparator(.hidden)
                    
                    Group{
                        Text("Password")
                            .font(.headline)
                        TextField(UUID().uuidString.prefix(10), text: $password)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    .listRowSeparator(.hidden)
                    
                    Group{
                        Text("Broadcast ID")
                            .font(.headline)
                        TextField("BID-" + UUID().uuidString.prefix(10), text: $broadcastid)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    .listRowSeparator(.hidden)
                    
                    Group{
                        Text("Device Type")
                            .font(.headline)
                        TextField("Amazon Alexa", text: $devicetype)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    .listRowSeparator(.hidden)
                    
                    Group{
                        Text("Manufacturer")
                            .font(.headline)
                        TextField("Amazon LLC", text: $manufacturer)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    .listRowSeparator(.hidden)
                    
                    Group{
                        Text("Description")
                            .font(.headline)
                            .padding(.bottom, -4)
                        TextField("Alexa Livingroom", text: $description)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    .listRowSeparator(.hidden)
                }
                
                Section{
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Button(action: {
                            
                            apicalls().postdevice(username: username, password: password, broadcastid: broadcastid, devicetype: devicetype, description: description, manufacturer: manufacturer) { result in
                                if result {
                                    self.alertMessage = "New Device \(devicetype) has been added"
                                }
                                else {
                                    self.alertMessage = "An error occurred"
                                }
                                self.showingAlert = true
                            }
                            
                        }, label: {
                            Text("Add Device")
                                .foregroundColor(.white)
                        })
                            .disabled(!(!username.isEmpty && !password.isEmpty && !broadcastid.isEmpty && !devicetype.isEmpty && !description.isEmpty && !manufacturer.isEmpty))
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 250, height: 15)
                            .padding()
                            .background(.blue)
                            .cornerRadius(20)
                        
                        Spacer()
                    }
                    .listRowBackground(Color(uiColor: .systemGray6))
                }
                
            }
            .navigationTitle("Add new device")
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        
        
        
    }
}
