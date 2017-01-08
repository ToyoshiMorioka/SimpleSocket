//
//  SimpleUDP.swift
//  SimpleSocket
//
//  Created by MORIOKAToyoshi on 2016/08/03.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//
// http://www.russbishop.net/swift-let-s-query-dns

import Foundation

public struct SimpleUDP{
    fileprivate var addressInfo:addrinfo?
    fileprivate var socketArray:[Int32]
    fileprivate var isReady:Bool
    
    public init (){
        socketArray = []
        isReady = false
    }
    
    public mutating func openSocket(_ ipAddress:String, portNumber:String) -> Bool {
        
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: AF_INET,
            ai_socktype: SOCK_DGRAM,
            ai_protocol: IPPROTO_UDP,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil)
        
        let ipAddressData = ipAddress.cString(using: String.Encoding.utf8)
        let portNumberData = portNumber.cString(using: String.Encoding.utf8)
        
        var result: UnsafeMutablePointer<addrinfo>? = nil
        let error = getaddrinfo(UnsafePointer<Int8>(ipAddressData!), UnsafePointer<Int8>(portNumberData!), &hints, &result)
        
        if error != 0 {
            return false
        }
        
        addressInfo = result?.pointee
        
        // make sockets
        var adrinf = addressInfo
        var available = true
        var hasSocket = false;
        while(available != false){
            // addressInfo?.ai_family = AF_INET
            if adrinf?.ai_family == AF_INET {
                print("IPv4.")
                
            }else if adrinf?.ai_family == AF_INET6 {
                print("IPv6.")
            }
            if adrinf?.ai_socktype == SOCK_DGRAM {
                print("udp.")
            }else if adrinf?.ai_socktype == SOCK_STREAM {
                print("tcp.")
            }
            print("ipddress:\(adrinf?.ai_addr)")
            // adrinf?.ai_addr = UnsafeMutablePointer<sockaddr>(0x0000000170002bf0)
            
            
            var sock:Int32 = -1
            sock = socket((adrinf?.ai_family)!, (adrinf?.ai_socktype)!, (adrinf?.ai_protocol)!)
            socketArray.append(sock)
            
            if sock < 0 {
                print("making socket failed...")
            }else{
                print("making socket success.")
                hasSocket = true
            }
            //            if adrinf?.ai_family == AF_INET {
            //
            //            }
            //            let sock = socket((adrinf?.ai_family)!, (adrinf?.ai_socktype)!, (adrinf?.ai_protocol)!)
            //            socketArray.append(sock)
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                adrinf = adrinf?.ai_next.pointee
            }
        }
        
        if hasSocket {
            isReady = true
            return true
        }else{
            isReady = false
            closeSocket()
            return false
        }
    }
    
    public mutating func sendData(_ data:Data) -> Bool {
        
        if !isReady {
            return false
        }
        
        var adrinf = addressInfo
        var available = true
        var i = 0
        var result = false
        
        
        while(available != false){
            
            let sock = socketArray[i]
            
            if sock >= 0 {
                // send data
                //let pointer:UnsafePointer<UInt8> = data.
                //let pointer:UnsafeRawPointer = data.bytes
//                let sendCount = sendto(sock, databytes, Int(data.count), 0, adrinf?.ai_addr!, (adrinf?.ai_addrlen)!)
                var sendCount = 0;
                data.withUnsafeBytes{(bytes: UnsafePointer<Int8>)->Void in
                    //Use `bytes` inside this closure
                    sendCount = sendto(sock, bytes, Int(data.count), 0, adrinf?.ai_addr!, (adrinf?.ai_addrlen)!)
                }
//                let sendCount = sendto(sock, data.withUnsafeBytes { (ptr: UnsafePointer<Int8>) -> Double in
//                    return ptr.pointee
//                }, Int(data.count), 0, adrinf?.ai_addr!, (adrinf?.ai_addrlen)!)
                if sendCount == Int(data.count) {
                    print("send data success.")
                    result = true
                }else {
                    print("send data error.")
                }
                // print("send result:\(result)")
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                i  = i+1
                adrinf = adrinf?.ai_next.pointee
            }
        }
        
        return result
    }
    
    public mutating func closeSocket(){
        
        var adrinf = addressInfo
        var available = true
        var i = 0
        
        while(available != false){
            
            let sock = socketArray[i]
            
            if sock >= 0 {
                // socketのクローズ
                print("socket close.")
                close(sock)
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                i  = i+1
                adrinf = adrinf?.ai_next.pointee
            }
        }
    }
}
