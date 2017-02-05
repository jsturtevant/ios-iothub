//
//  ViewController.swift
//  ios-iot
//
//  Created by James Sturtevant on 2/4/17.
//  Copyright © 2017 James Sturtevant. All rights reserved.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    var mqtt: CocoaMQTT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        simpleSSLSetting()
    }

    func simpleSSLSetting() {
        let clientID = "workshopdevice"
        mqtt = CocoaMQTT(clientID: clientID, host: "<your-iothub-name>.azure-devices.net", port: 8883)
        mqtt!.username = "<your-iothub-name>>.azure-devices.net/<devicename>"
        mqtt!.password = "SharedAccessSignature yourshared-sas-key"
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
        mqtt!.enableSSL = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func connectbtn(_ sender: Any) {
        
        let button = (sender as AnyObject)
        
        switch mqtt!.connState {
        case CocoaMQTTConnState.connected:
                print("disconnect")
                mqtt!.disconnect()
                mqttSend.isEnabled = false
                button.setTitle("Connect", for: .normal)
        case CocoaMQTTConnState.initial,
             CocoaMQTTConnState.disconnected:
                print("connect")
                mqtt!.connect()
                mqttSend.isEnabled = true
                button.setTitle("Disconnect", for: .normal)
            
            
        default:
                print("in transition state")
        }
    }
    
    @IBOutlet weak var c2dMesssages: UITextView!
    @IBOutlet weak var mqttSend: UIButton!
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = "sample message"
        mqtt!.publish("devices/workshopdevice/messages/events/", withString: message, qos: .qos1)
    }
    
}

// from sample at https://github.com/emqtt/CocoaMQTT/tree/master/Example
extension ViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        /// Validate the server certificate
        ///
        /// Some custom validation...
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck: \(ack)，rawValue: \(ack.rawValue)")
        
        if ack == .accept {
             mqtt.subscribe("devices/workshopdevice/messages/devicebound/#", qos: CocoaMQTTQOS.qos1)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string) with id \(id)")
        
        print("message: \(message.string!) \n topic  \(message.topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        _console("mqttDidDisconnect")
    }
    
    func _console(_ info: String) {
        print("Delegate: \(info)")
    }
}
