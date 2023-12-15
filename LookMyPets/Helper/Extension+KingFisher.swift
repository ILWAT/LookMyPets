//
//  Extension+KingFisher.swift
//  LookMyPets
//
//  Created by 문정호 on 12/15/23.
//

import UIKit
import Kingfisher

extension KingfisherWrapper where Base: UIImageView {
    
    func setImageWithAuthHeaders(
        with resource: Resource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        
        let modifier = AnyModifier { request in
            var r = request
            r.addValue(TokenManger.shared.readCurrentTokenInUserDefaults(tokenType: .accessToken) ?? "", forHTTPHeaderField: "Authorization")
            r.addValue(SecretKeys.SeSAC_ServerKey, forHTTPHeaderField: "SesacKey")
            print(r)
            return r
        }
        
        let newOptions: KingfisherOptionsInfo = options ?? [.requestModifier(modifier)]
        
        self.setImage(
            with: resource,
            placeholder: placeholder,
            options: newOptions,
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }
}
