//
//  ViewController.swift
//  SimpleSocketExample
//
//  Created by MORIOKAToyoshi on 2016/08/13.
//  Copyright © 2016年 ___MORIOKAToyoshi___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pushSendMessageButton(_ sender: AnyObject) {
        // ipv6
        //let udp = SimpleUDPv6(iPAddress: "2001:2:0:aab1::1", portNumber: 50000)
        var udp = SimpleUDP()
        
        if udp.openSocket("10.0.1.142", portNumber: "50000") {
            print("making connection success.")
        }else{
            print("making connection fail.")
            return
        }
        
        // let udp = SimpleUDPv6(iPAddress: "169.254.81.219", portNumber: 50000)
        let test = "test test test test\n"
        if udp.sendData(test.data(using: String.Encoding.utf8)!) {
            print("send data success.")
        }else{
            print("send data failt.")
        }
        
        udp.closeSocket()
    }
}

