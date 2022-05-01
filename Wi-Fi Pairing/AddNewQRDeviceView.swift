//
//  AddNewQRDeviceView.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 24.02.22.
//

import Foundation
import SwiftUI

struct AddNewQRDeviceView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let completion: (() -> Void)
    
    @State var description = ""
    @State var devicetype = ""
    @State var manufacturer = ""
    
    var body: some View {
        NavigationView{
            List {
                Section {
                    VStack(alignment: .leading){
                        Text("Description")
                            .font(.headline)
                        TextField("Lamp over Dinner Table", text: $description)
                            .font(.subheadline)
                    }
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("Device Type")
                            .font(.headline)
                        TextField("Apple TV", text: $devicetype)
                            .font(.subheadline)
                    }
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("Manufacturer")
                            .font(.headline)
                        TextField("Raspberry Pi Foundation", text: $manufacturer)
                            .font(.subheadline)
                    }
                }
                
                Section {
                    HStack(alignment: .center) {
                        Button {
                            apicalls().postdevice(username: CredentialsLoader.shared.loginid, password: CredentialsLoader.shared.loginpw, broadcastid: CredentialsLoader.shared.broadcastid, devicetype: devicetype, description: description, manufacturer: manufacturer) { result in
                                if result {
                                    DispatchQueue.main.async {
                                        self.presentationMode.wrappedValue.dismiss()
                                        completion()
                                    }
                                }
                                else {
                                    
                                }
                            }
                        } label: {
                            Text("Add Device")
                                .foregroundColor(.white)
                                .frame(width: 250, height: 15)
                                .padding()
                                .background(.blue)
                                .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listRowBackground(Color(uiColor: .systemGray6))
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle("Add New Device")
        }
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}


class CredentialsLoader {
    static var shared: CredentialsLoader = CredentialsLoader()
    
    var deviceCredentials: [Credentials] = []
    
    
    
    
    var credentials: [String: String] = [String:String]()
    
    var loginid: String {
        get {
            return credentials["loginid"] ?? ""
        }
    }
    
    var loginpw: String {
        get {
            return credentials["loginpw"] ?? ""
        }
    }
    
    var broadcastid: String {
        get {
            return credentials["broadcastid"] ?? ""
        }
    }
    
    var devicetype: String {
        get {
            return credentials["devicetype"] ?? ""
        }
    }
    
    var description: String {
        get {
            return credentials["description"] ?? ""
        }
    }
    
    var manufacturername: String {
        get {
            return credentials["manufacturer"] ?? ""
        }
    }
    
    func loadJSONFromString(str: String) -> [Credentials] {
        guard let data = str.data(using: .utf8) else { return [] }
        
        guard let arr = try? JSONDecoder().decode([Credentials].self, from: data) else { return [] }
        
        return arr
    }
    
    func loadJSONFromURL(url: URL) -> [Credentials] {
        guard let str = try? String(contentsOf: url) else { return [] }
        
        return loadJSONFromString(str: str)
    }
    
    
    
    
    
    
    func loadCredentialsFromString(str: String) -> Bool {
        let res = str.components(separatedBy: ",").reduce(into: [String: String]()) {
                let comps = $1.components(separatedBy: ":")
                guard comps.count == 2 else {return}
                $0[comps[0]] = comps[1]
            }
        self.credentials = res
        
        return devicetype.isEmpty || description.isEmpty || manufacturername.isEmpty
        //Returns true if a dialog is needed
    }
    
    func loadCredentialsFrom(URL url: URL) -> Bool {
        guard let str = try? String(contentsOf: url) else { return false }
        
        return loadCredentialsFromString(str: str)
    }
}


class Credentials: Codable {
    let loginid: String
    let loginpw: String
    let broadcastid: String
    let devicetype: String
    let description: String
    let manufacturer: String
}
