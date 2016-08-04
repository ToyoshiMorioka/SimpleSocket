//
//  SimpleUDPv4.swift
//  SimpleSocket
//
//  Created by MORIOKAToyoshi on 2016/06/29.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//

import Foundation

class SimpleUDPv6{
    internal var iPAddress:String = ""
    internal var portNumber:Int = 0
    var _fd:Int32 = 0
    var _addr:sockaddr_in6 = sockaddr_in6()
    
    init(){
        
    }
    
    init(iPAddress:String, portNumber:Int) {
//        func htons(value: CUnsignedShort) -> CUnsignedShort {
//            return (value << 8) + (value >> 8);
//        }
        
        func htons(value: CUnsignedShort) -> CUnsignedShort {
            return value.bigEndian
        }
        
        //var address: in6_addr = in6_addr()
        _fd = socket(AF_INET6, SOCK_DGRAM, 0) // DGRAM makes it UDP
        //address = inet6_addr(iPAddress)
        
        _addr = sockaddr_in6(
            sin6_len:    __uint8_t(sizeof(sockaddr_in)),
            sin6_family: sa_family_t(AF_INET),
//            sin6_port: htons(CUnsignedShort(portNumber)),
            sin6_port: htons(CUnsignedShort(portNumber)),
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        
        inet_pton(AF_INET6, iPAddress, &(_addr.sin6_addr));
    }
    
    func sendData(data:NSData)  {
        var newAddr = _addr
        withUnsafePointer(&newAddr) { (ptr) -> Void in
            let addrptr = UnsafePointer<sockaddr>(ptr)
            sendto(_fd, UnsafePointer<UInt8>(data.bytes), Int(data.length), 0, addrptr, socklen_t(_addr.sin6_len))
            //print("send result:\(result).")
        }
    }
}