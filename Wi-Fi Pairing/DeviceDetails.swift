//
//  DeviceDetails.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 24.02.22.
//

import Foundation
import SwiftUI

struct DeviceDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(device: Device) {
        self.device = device
        self.infos = [
            DeviceInformation(title: "Manufacturer", value: device.manufacturername),
            DeviceInformation(title: "Device added", value: device.addedat.timeAgoDisplay()),
            DeviceInformation(title: "Added By", value: device.commissionername),
            DeviceInformation(title: "Current Status", value: device.admissionstatus),
            DeviceInformation(title: "Last Status Change", value: device.admissionstatusupdate.timeAgoDisplay()),
            DeviceInformation(title: "Device Credentials", value: "", subItems: [
                DeviceInformation(title: "Username", value: device.loginid),
                DeviceInformation(title: "Password", value: device.loginpassword),
                DeviceInformation(title: "Broadcast ID", value: device.broadcastid)
            ]),
            DeviceInformation(title: "Photo", value: "https://c1.neweggimages.com/ProductImageCompressAll640/AU62S210510lDbcl.jpg"),
            DeviceInformation(title: "Delete", value: "\(device.deviceid)")
        ]
    }
    
    var device: Device
    
    var infos: [DeviceInformation]
    
    var body: some View {
        List(infos, children: \.subItems) { row in
            DeviceDetailCell(presentationMode: presentationMode, title: row.title, value: row.value)
        }
        .navigationTitle(device.devicetype)
    }
}

struct DeviceInformation: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    var subItems: [DeviceInformation]?
}

struct DeviceDetailCell: View {
    var presentationMode: Binding<PresentationMode>
    let title: String
    let value: String
    
    var body: some View {
        if title == "Delete" {
            HStack(alignment: .center) {
                Spacer()
                Button {
                    apicalls().deletedevice(deviceid: Int(value) ?? 0) { result in
                        print(result)
                        DispatchQueue.main.async {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Delete")
                        .frame(width: 250, height: 15)
                        .padding()
                        .background(.red)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .listRowBackground(Color(UIColor.systemGray6))
        }
        else if title == "Photo" {
            VStack {
                HStack {
                    Text("Photo")
                        .font(.headline)
                    Spacer()
                }
                
                AsyncImage(url: URL(string: value)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
            }
        }
        else {
            HStack(alignment: .center){
                Text(title)
                    .font(.headline)
                Spacer()
                if title == "Current Status" {
                    AdmissionView(status: value)
                }
                else {
                    Text(value)
                        .font(.subheadline)
                }
            }
        }
    }
}
