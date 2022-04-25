//
//  DeviceModel.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 23.02.22.
//

import Foundation
import SwiftUI

struct Device: Codable, Hashable {
    let deviceid: Int
    let loginid: String
    let loginpassword: String
    let broadcastid: String
    let admissionstatus: String
    let admissionstatusupdate: String
    let addedat: String
    let commissionername: String
    let description: String
    let devicetype: String
    let manufacturername: String
}

/*
 
 "addedat": "Mon, 21 Feb 2022 23:52:45 GMT",
         "admissionstatus": "Pending",
         "admissionstatusupdate": "Mon, 21 Feb 2022 23:52:45 GMT",
         "broadcastid": "e0056859-f092-4417-af85-18398afc89ca",
         "commissionername": "Jannik",
         "description": "My RPI",
         "deviceid": 15,
         "devicetype": null,
         "loginid": "steve",
         "loginpassword": "testing",
         "manufacturername": "Raspberry Manufacturering Inc."
 */
