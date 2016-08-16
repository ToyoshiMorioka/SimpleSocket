//
//  SimpleTCP.swift
//  SimpleSocket
//
//  Created by MORIOKAToyoshi on 2016/08/05.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//

import Foundation

public struct SimpleTCP{
    var addressInfo:addrinfo?
    private var socketArray:[Int32]
    var isReady:Bool
    
    public init (){
        socketArray = []
        isReady = false
    }
    
    public mutating func openSocket(ipAddress:String, portNumber:String) -> Bool {
        
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_STREAM,
            ai_protocol: IPPROTO_TCP,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil)
        
        var result = UnsafeMutablePointer<addrinfo>.init(nilLiteral: ())
        let error = getaddrinfo(UnsafePointer<Int8>(ipAddress.cStringUsingEncoding(NSUTF8StringEncoding)!), UnsafePointer<Int8>(portNumber.cStringUsingEncoding(NSUTF8StringEncoding)!), &hints, &result)
        
        if error != 0 {
            return false
        }
        
        addressInfo = result.memory
        
        if addressInfo?.ai_family == AF_INET {
            print("IPv4.")
        }else if addressInfo?.ai_family == AF_INET6 {
            print("IPv6.")
        }
        
        if addressInfo?.ai_socktype == SOCK_DGRAM {
            print("udp.")
        }else if addressInfo?.ai_socktype == SOCK_STREAM {
            print("tcp.")
        }
        
        // make sockets
        var adrinf = addressInfo
        var available = true
        var hasConnection = false;
        while(available != false){
            
            let sock = socket((adrinf?.ai_family)!, (adrinf?.ai_socktype)!, (adrinf?.ai_protocol)!)
            socketArray.append(sock)
            
            if sock < 0 {
                print("making socket error.")
            }
            
            // udp = sock_dgramの時は不必要
            let connectResult = connect(sock, UnsafePointer<sockaddr>((adrinf?.ai_addr)!), (adrinf?.ai_addrlen)!)
            
            if connectResult < 0 {
                print("connect error.")
            }else{
                hasConnection = true
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                adrinf = adrinf?.ai_next.memory
            }
        }
        
        if hasConnection {
            isReady = true
            return true
        }else{
            isReady = false
            closeSocket()
            return false
        }
    }
    
    public mutating func sendData(data:NSData) -> Bool {
        
        if !isReady {
            return false
        }
        
        var adrinf = addressInfo
        var available = true
        var i = 0
        
        while(available != false){
            
            let sock = socketArray[i]
            
            if sock >= 0 {
                // send data
                sendto(sock, UnsafePointer<UInt8>(data.bytes), Int(data.length), 0, (adrinf?.ai_addr)!, (adrinf?.ai_addrlen)!)
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                i  = i+1
                adrinf = adrinf?.ai_next.memory
            }
        }
        
        return true
    }
    
    public mutating func closeSocket(){
        
        var adrinf = addressInfo
        var available = true
        var i = 0
        
        while(available != false){
            
            let sock = socketArray[i]
            
            if sock >= 0 {
                // socketのクローズ
                close(sock)
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                i  = i+1
                adrinf = adrinf?.ai_next.memory
            }
        }
    }
}