//
//  ViewController.swift
//  websockettest
//
//  Created by 정보인 on 2023/02/12.
//

import UIKit
import CoreLocation

struct testJSON : Encodable {
    var name:String
    var stamp : Int32
}

class ViewController: UIViewController, URLSessionDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var counter = 0
    @IBOutlet weak var logBox: UITextField!
    @IBOutlet weak var messageBox: UITextField!
    
    @IBAction func disconnectWebSocket(_ sender: UIButton) {
        
        close()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        send()
    }
    
    private var webSocket:URLSessionWebSocketTask?
    private let jsonEncoder : JSONEncoder = JSONEncoder()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        guard let url = URL(string:"ws://10.101.6.38:9090")
        else{
            print("#############URL Session Error!!!!!!!!!x !!")
            return
            
        }
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
    }
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        
        print("0 - Did connect to socket")
        logBox.insertText("Did connect to socket")
        ping()
        receive()
        close()
    }
    
    func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            
            print("Did close connection with reason")
            
        }

    
    func ping() {
            print("ping!!!!!!!!!!!!!!!!!!")
            webSocket?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    print("Ping error: \(error)")
                    self.logBox.insertText("Ping error")
                }
            })
            
        }
    
    
    func receive() {
        
        webSocket?.receive(completionHandler: { [weak self] result in
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
                    print("Got string: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            
            self?.receive()
        })
        
    }
    
    func send(){
            
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.send()
                do{
                    guard let currentLocation = self.locationManager.location else{
                          //let currentHeading = self.locationManager.heading else{
                        print("Data Error%%%%%%%%%%%%%%%%%%%%%%%%")
                        return
                    }
                    
                    let locations = [currentLocation.coordinate.latitude, currentLocation.coordinate.longitude] //currentHeading.trueHeading]
                    let timestamp = Date().timeIntervalSince1970
                    let msg = MessageUtils.locationToNavsatFix(time: timestamp, location: locations)
                    let d = RosbridgeMsg(seq: self.counter, topic: "/ipad/location", type:nil, msg:msg)
                    let json = try self.jsonEncoder.encode(d)
                    let data = URLSessionWebSocketTask.Message.data(json)
                    self.webSocket?.send((data), completionHandler: { error in
                        if let error = error {
                            print("Send error: \(error)")
                        }
                    })
                    self.counter = self.counter + 1
                    
                } catch (let error){
                    print("json error!")
                }
            }
            
        }

    
    
    @objc func close() {
        
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
        
    }
    


}

