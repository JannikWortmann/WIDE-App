//
//  Wi_Fi_PairingApp.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 23.02.22.
//

import SwiftUI
import Foundation

@main
struct Wi_Fi_PairingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { (url) in
                    let showDialog = CredentialsLoader.shared.loadCredentialsFrom(URL: url)
                    
                    if !showDialog {
                        //add new device
                        //reload list
                        apicalls().postdevice(username: CredentialsLoader.shared.loginid, password: CredentialsLoader.shared.loginpw, broadcastid: CredentialsLoader.shared.broadcastid, devicetype: CredentialsLoader.shared.devicetype, description: CredentialsLoader.shared.description, manufacturer: CredentialsLoader.shared.manufacturername) { result in
                            print(result)
                            DispatchQueue.main.async {
                                AddQRDeviceView.shared.reloadDeviceList.toggle()
                            }
                        }
                    }
                    else {
                        AddQRDeviceView.shared.pushAddDeviceQRView = true
                    }
                }
                .environmentObject(AddQRDeviceView.shared)
        }
    }
}

class AddQRDeviceView: ObservableObject {
    @Published var pushAddDeviceQRView: Bool = false
    @Published var reloadDeviceList: Bool = false
    
    static var shared = AddQRDeviceView()
}

//class FSAppDelegate: NSObject, UIApplicationDelegate {
//    func applicationDidFinishLaunching(_ application: UIApplication) {
//    }
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        print(url)
//        CredentialsLoader.shared.loadCredentialsFrom(URL: url)
//        return true
//    }
//}
