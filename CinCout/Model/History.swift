//
//  History.swift
//  CinCout
//
//  Created by Harshil Modi on 24/06/23.
//

import Foundation

    
//let History: [returnData] = []


struct History: Codable {
    
    let date_in: String?
    let date_out: String?
    let destination: String?
    let in_out_id: Int?
    let mis: String?
    let reason: String?
    let time_in: String?
    let time_out: String?
}
