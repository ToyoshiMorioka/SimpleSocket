//
//  ViewController.swift
//  SimpleSocket
//
//  Created by MORIOKAToyoshi on 2016/06/29.
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
    @IBAction func pushSendMessageButton(sender: AnyObject) {
        // ipv6
        //let udp = SimpleUDPv6(iPAddress: "2001:2:0:aab1::1", portNumber: 50000)
        var udp = SimpleTCP()
        
        if udp.openSocket("10.0.1.84", portNumber: "12345") {
            print("making connection success.")
        }else{
            print("making connection fail.")
            return
        }
        
        // let udp = SimpleUDPv6(iPAddress: "169.254.81.219", portNumber: 50000)
        let test = "test test test test\n"
        udp.sendData(test.dataUsingEncoding(NSUTF8StringEncoding)!)

        udp.closeSocket()
    }


}

