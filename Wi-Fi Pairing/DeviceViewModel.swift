//
//  DeviceViewModel.swift
//  Wi-Fi Pairing
//
//  Created by Jannik Wortmann on 23.02.22.
//

import Foundation
import SwiftUI

class apicalls: NSObject, URLSessionTaskDelegate {
    let host = "wide.janakj.net"
    let token = "abcdef"
    
    func getDevices(completion: @escaping ([Device]) -> ()) {
        guard let url = URL(string: "https://\(host)/devices") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: request) { data, _, _ in
            let devices = try? JSONDecoder().decode([Device].self, from: data!)
            
            print(devices)
            
            DispatchQueue.main.async {
                completion(devices ?? [])
            }
        }
        session.resume()
    }
    
    func postdevice(username:String, password: String, broadcastid: String, devicetype: String, description: String, manufacturer: String, completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: "https://\(host)/devices") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let dict = ["loginid": username,
         "loginpassword": password,
         "broadcastid": broadcastid,
         "devicetype": devicetype,
         "description": description,
         "manufacturername": manufacturer]
        
        guard let jsondata = try? JSONEncoder().encode(dict) else {
            completion(false)
            return }
        
        request.httpBody = jsondata
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: request) { data, _, _ in
            guard let data = data, let res = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "") else {completion(false); return}
            
            if res.contains("success") {
                completion(true)
                return
            }
            completion(false)
        }
        session.resume()
    }
    
    func deletedevice(deviceid: Int, completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: "https://\(host)/devices/\(deviceid)") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: request) { data, _, _ in
            guard let data = data, let res = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "") else {completion(false); return}
            
            print(data)
            guard let num = Int(res) else { completion(false); return}
            if num >= 1 {
                completion(true)
                return
            }
            completion(false)
        }
        session.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
