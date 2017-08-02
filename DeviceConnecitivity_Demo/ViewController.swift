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
    
}



protocol ServiceManagerDelegate: class {
    func foundPeer(manager: ServiceManager, peerId: MCPeerID)
}

class ServiceManager : NSObject {
    
    private let serviceType = "My-service"
    private let devicePeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    private let serviceBrower: MCNearbyServiceBrowser
    
    weak var delegate: ServiceManagerDelegate?
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: devicePeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrower = MCNearbyServiceBrowser(peer: devicePeerID, serviceType: serviceType)
        super.init()
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrower.delegate = self
        serviceBrower.startBrowsingForPeers()
    }

}

extension ServiceManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}

extension ServiceManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("find peer \(peerID)")
        delegate?.foundPeer(manager: self, peerId: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}


