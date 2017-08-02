//
//  ViewController.swift
//  DeviceConnecitivity_Demo
//
//  Created by Vikash Kumar on 01/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, ServiceManagerDelegate {
    
    @IBOutlet var lblIDs : UILabel!
    
    let serviceManager = ServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceManager.delegate = self
    }
    
    func foundPeer(manager: ServiceManager, peerId: MCPeerID) {
        let ids = lblIDs.text! + "\n" + peerId.displayName
        lblIDs.text = ids
    }
    
    func didReceive(data: Data) {
        var colorValue: Int = 0
        (data as NSData).getBytes(&colorValue, length: MemoryLayout<Int>.size)
        if let color = Color(rawValue: colorValue) {
            DispatchQueue.main.async {
                self.view.backgroundColor = color.uiColor
            }
        }
    }
    
    @IBAction func colorButtonClicked(_ sender : UIButton) {
        var colorValue = sender.tag
        if let color = Color(rawValue: colorValue) {
            self.view.backgroundColor = color.uiColor
            let data = NSData(bytes: &colorValue, length: MemoryLayout<Int>.size)
           serviceManager.sendData(data: data as Data )
        }
    }
    
    enum Color: Int {
        case Red = 1, Blue, Green, Black
        
        var uiColor: UIColor {
            switch self {
            case .Red:
                return .red
            case .Blue:
                return .blue
            case .Green:
                return .green
            case .Black:
                return .black
        
            }
        }
    }
    
    
}



protocol ServiceManagerDelegate: class {
    func foundPeer(manager: ServiceManager, peerId: MCPeerID)
    func didReceive(data: Data)
}

class ServiceManager : NSObject {
    
    private let serviceType = "My-service"
    private let devicePeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    private let serviceBrower: MCNearbyServiceBrowser
    
    weak var delegate: ServiceManagerDelegate?
    
    lazy var session: MCSession = {
        let ssn = MCSession(peer: self.devicePeerID, securityIdentity: nil, encryptionPreference: .required)
        ssn.delegate = self
        return ssn
    }()
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: devicePeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrower = MCNearbyServiceBrowser(peer: devicePeerID, serviceType: serviceType)
        super.init()
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrower.delegate = self
        serviceBrower.startBrowsingForPeers()
    }

    func sendData(data: Data) {
        do {
            if session.connectedPeers.count > 0 {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch let e {
            print(e.localizedDescription)
        }
    }
}

extension ServiceManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}

extension ServiceManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("find peer \(peerID)")
        delegate?.foundPeer(manager: self, peerId: peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}

extension ServiceManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("State Change for PeerID: \(peerID),  new state: \(state)")
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
     self.delegate?.didReceive(data: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
}
