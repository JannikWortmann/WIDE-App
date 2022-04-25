//
//  ContentView.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 23.02.22.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @State var devices: [Device] = [] {
        didSet {
            self.showEmptyLabel = devices.isEmpty
        }
    }
    @State var showingAddDevice = false
    @State var showingQRScanner = false
    @State var showDocumentView = false
    @State var showEmptyLabel = true
    @State var pushQRView = false
    
    let qrcodestr = "loginid:e33ce6ac-65f8-4903-b849-78e9b4286e90,loginpw:f44f7396-48f3-4181-879c-512ef53d6e1b,broadcastid:5ee333c3-7093-4965-a424-9231f297e10c"
    
    var body: some View {
        NavigationView{
            List{
                ForEach(devices, id: \.self) { device in
                    NavigationLink(destination: DeviceDetails(device: device)) {
                        DeviceCell(device: device)
                    }
                }
                    
            }
            .onAppear {
                apicalls().getDevices { devices in
                    self.devices = devices
                }
            }
            .navigationTitle("Wi-Fi Pairing App")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showingAddDevice = true
                    } label: {
                        Image(systemName: "plus")
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showingQRScanner = true
                    } label: {
                        Image(systemName: "camera.viewfinder")
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showDocumentView.toggle()
                    } label: {
                        Image(systemName: "doc.viewfinder")
                        .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddDevice) {
                AddDeviceView()
            }
            .sheet(isPresented: $showingQRScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: qrcodestr, shouldVibrateOnSuccess: true, completion: handleScan)
            }
            .sheet(isPresented: $pushQRView) {
                AddNewQRDeviceView {
                    apicalls().getDevices { devices in
                        
                        UIView.animate(withDuration: 0.3) {
                            self.devices = devices
                        }
                    }
                }
            }
            .fileImporter(isPresented: $showDocumentView, allowedContentTypes: [.text], onCompletion: { result in
                do {
                    let url = try result.get()
                    print(url)
                    
                    guard url.startAccessingSecurityScopedResource() else { return }
                    if let info = try? String(contentsOf: url) {
                        
                        _ = CredentialsLoader.shared.loadCredentialsFromString(str: info)
                        
                        AddQRDeviceView.shared.pushAddDeviceQRView = true
                        
                    }
                    url.stopAccessingSecurityScopedResource()
                }
                catch {
                    
                }
                self.showDocumentView = false
            })
            .refreshable {
                apicalls().getDevices { devices in
                    self.devices = devices
                }
            }
        }
        .onReceive(AddQRDeviceView.shared.$pushAddDeviceQRView) { out in
            self.pushQRView = out
        }
        .onReceive(AddQRDeviceView.shared.$reloadDeviceList) { _ in
            apicalls().getDevices { devices in
                self.devices = devices
            }
        }
        
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
            case .success(let result):
            
            _ = CredentialsLoader.shared.loadCredentialsFromString(str: result.string)
            
            AddQRDeviceView.shared.pushAddDeviceQRView = true
            case .failure(let error):
                print(error)
        }
        showingQRScanner = false
        print(result)
        // more code to come
    }
}

struct DeviceCell: View {
    var device: Device {
        didSet {
            timeago = device.admissionstatusupdate.timeAgoDisplay()
        }
    }
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var timeago = "1 second ago"
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 0) {
                Text(device.devicetype)
                    .font(.headline)
                Text(device.description)
                    .font(.subheadline)
                
            }
            Spacer()
            VStack{
                AdmissionView(status: device.admissionstatus)
                Text(timeago)
                    .font(.subheadline)
            }
                
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .onReceive(timer) { _ in
            self.timeago = device.admissionstatusupdate.timeAgoDisplay()
        }
    }
}

struct AdmissionView: View {
    let status: String
    
    var body: some View {
        if status == "Access-Accept" {
            Text("Accepted")
                .padding(2)
                .background(.green)
                .font(.headline)
                .cornerRadius(4)
        }
        else if status == "Access-Reject" {
            Text("Rejected")
                .padding(2)
                .background(.red)
                .font(.headline)
                .cornerRadius(4)
        }
        else {
            Text("Broadcasting")
                .padding(2)
                .background(.orange)
                .font(.headline)
                .cornerRadius(4)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension String {
    func toDate() -> Date {
        //Wed, 23 Feb 2022 22:15:25 GMT
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.timeZone = TimeZone(identifier:"GMT")
        dateFormatterGet.dateFormat = "E, d MMM yyyy HH:mm:ss 'GMT'"
        let ne = self.replacingOccurrences(of: " GMT", with: "")
        let d =  dateFormatterGet.date(from: ne)
        return d ?? Date()
    }
    
    func timeAgoDisplay() -> String {
        return self.toDate().timeAgoDisplay()
    }
}
