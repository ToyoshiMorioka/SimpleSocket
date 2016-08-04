//
//  SimpleUDP.swift
//  SimpleSocket
//
//  Created by MORIOKAToyoshi on 2016/08/03.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//
// http://www.russbishop.net/swift-let-s-query-dns

import Foundation


struct SimpleUDP{
    var addressInfo:addrinfo?
    
    mutating func getAddressInfo() -> Bool {
        // int getaddrinfo(const char *nodename, const char *servname, const struct addrinfo *hints, struct addrinfo **res);
        // <IN> nodename: ノード名を渡します。例えば、"192.168.1.155" や "super-www-sv" などを渡せます。 ←
        // <IN> servname: サービス名を渡します。例えば、"21" や "ftp" などを渡せます。 ← port番号
        // <IN> hints: 取得するアドレス情報の種類などを指定します。
        // <OUT> res: 取得されたアドレス情報へのポインタが返されます。ポインタが不要になったら、freeaddrinfo(3) で解放しなければなりません。
        // <RETURN> 成功時は 0 です。失敗時は gai_strerror(3) に返り値を渡してエラー文字列を取得できます。
        
        let ipAddress:String = "10.0.1.84"
        let portNumber:String = "12345"
        
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
        
        return true
    }
    
    mutating func setSocketInfo() -> Bool {
        
        let result = getAddressInfo()
        
        if !result {
            return false
        }
        
        var adrinf = addressInfo
        var available = true
        while(available != false){
          
            let sock = socket((adrinf?.ai_family)!, (adrinf?.ai_socktype)!, (adrinf?.ai_protocol)!)
            
            if sock < 0 {
                print("making socket error.")
            }

            // udp = sock_dgramの時は不必要
//            let connectResult = connect(sock, UnsafePointer<sockaddr>((adrinf?.ai_addr)!), (adrinf?.ai_addrlen)!)
//            if connectResult < 0 {
//                print("connect error.")
//            }
            
            let test = "test!test!test!"
            let data = test.dataUsingEncoding(NSUTF8StringEncoding)!
            
            // 通信
            sendto(sock, UnsafePointer<UInt8>(data.bytes), Int(data.length), 0, (adrinf?.ai_addr)!, (adrinf?.ai_addrlen)!)
            
            // socketのクローズ
            close(sock)
            print("next:\(adrinf!.ai_next)")
            if adrinf!.ai_next  == nil{
                available = false
            }else{
                adrinf = adrinf?.ai_next.memory
            }
        }
        

        
        
        // int getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, size_t hostlen, char *serv, size_t servlen, int flags);
        // <IN> sa: アドレス情報へのポインタを渡します。
        // <IN> salen: アドレス情報の長さを渡します。
        // <OUT> host: 取得されたノード名を格納するバッファを渡します。
        // <IN> hostlen: host のバッファ長を渡します。
        // <OUT> serv: 取得されたサービス名を格納するバッファを渡します。
        // <IN> servlen: serv のバッファ長を渡します。
        // <IN> flags: ノード名、サービス名の取得方法などを指定します。
        // <RETURN> 成功時は 0 です。失敗時は gai_strerror(3) に返り値を渡してエラー文字列を取得できます。
        
        return true
    }
}