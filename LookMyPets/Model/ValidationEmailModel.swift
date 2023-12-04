//
//  ValidationEmailModel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation

struct ValidationEmailResult: Decodable{
    let message: String
}

struct ValidationEmail: Encodable{
    let email: String
}
