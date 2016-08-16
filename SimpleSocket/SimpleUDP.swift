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
    private var addressInfo:addrinfo?
    private var socketArray:[Int32]
    private var isReady:Bool
    
    public init (){
        socketArray = []
        isReady = false
    }
    
    public mutating func openSocket(ipAddress:String, portNumber:String) -> Bool {
        
        // get addressInfo
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_DGRAM,
            ai_protocol: IPPROTO_UDP,
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
        var hasSocket = false;
        while(available != false){
            
            let sock = socket((adrinf?.ai_family)!, (adrinf?.ai_socktype)!, (adrinf?.ai_protocol)!)
            socketArray.append(sock)
            
            if sock < 0 {
                print("making socket error.")
            }else{
                hasSocket = true
            }
            
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                adrinf = adrinf?.ai_next.memory
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