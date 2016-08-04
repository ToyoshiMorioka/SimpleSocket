//
//  SimpleUDP.swift
//  SoSA
//
//  Created by MORIOKAToyoshi on 2016/04/05.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//

import Foundation

class SimpleUDPv4{
    internal var iPAddress:String = ""
    internal var portNumber:Int = 0
    var _fd:Int32 = 0
    var _addr:sockaddr_in = sockaddr_in()
    
    init(){
        
    }
    
    init(iPAddress:String, portNumber:Int) {
        func htons(value: CUnsignedShort) -> CUnsignedShort {
            return (value << 8) + (value >> 8);
        }
        
        var address: in_addr = in_addr()
        _fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
        address.s_addr = inet_addr(iPAddress)
        
        _addr = sockaddr_in(
            sin_len:    __uint8_t(sizeof(sockaddr_in)),
            sin_family: sa_family_t(AF_INET),
            sin_port:   htons(CUnsignedShort(portNumber)),
            sin_addr:   address,
            sin_zero:   ( 0, 0, 0, 0, 0, 0, 0, 0 )
        )
    }
    
    func sendData(data:NSData)  {
        var newAddr = _addr
        withUnsafePointer(&newAddr) { (ptr) -> Void in
            let addrptr = UnsafePointer<sockaddr>(ptr)
            sendto(_fd, UnsafePointer<UInt8>(data.bytes), Int(data.length), 0, addrptr, socklen_t(_addr.sin_len))
            //print("send result:\(result).")
        }
    }
}
