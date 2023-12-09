//
//  TokenAuthPlugin.swift
//  LookMyPets
//
//  Created by 문정호 on 12/7/23.
//

import Foundation
import Moya

final class TokenAuthPlugin: PluginType {
    typealias accessToken = () -> String?
    
    let tokenClosure: () -> String?
    
    init(tokenClosure: @escaping () -> String?) {
        self.tokenClosure = tokenClosure
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard
              let token = tokenClosure(),
              let target = target as? catchErrorTargetType,
              target.needsToken
            else {
              return request
            }

            var request = request
            request.addValue(token, forHTTPHeaderField: "Authorization")
            return request
    }
}
