//
//  LoginModel.swift
//  LookMyPets
//
//  Created by 문정호 on 12/5/23.
//

import Foundation

struct LoginResult: Decodable{
    let token: String
    let refreshToken: String
}

struct LoginBodyModel: Encodable{
    let email: String
    let password: String
}
