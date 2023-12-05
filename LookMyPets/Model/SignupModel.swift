//
//  SignupModel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import Foundation

struct SignupResult: Decodable {
    let _id: String
    let email: String
    let nick: String
}

struct SignupBodyModel: Encodable{
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
}
