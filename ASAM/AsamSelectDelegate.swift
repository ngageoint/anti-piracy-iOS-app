//
//  AsamSelectDelegate.swift
//  anti-piracy-iOS-app
//


import Foundation

protocol AsamSelectDelegate {

    func asamSelected(_ asam: Asam)
    func clusterSelected(asams: [Asam])

}
