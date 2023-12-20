//
//  GetPostModel.swift
//  LookMyPets
//
//  Created by 문정호 on 12/11/23.
//

import Foundation

//MARK: - BodyModel
struct GetPostBodyModel: Encodable {
    let next: String?
    let limit: String?
    let product_id: String?
}

//MARK: - ResultModel
struct GetPostResultModel: Decodable{
    let data:[GetPostData]
    let next_cursor: String
}

struct GetPostData: Decodable {
    let likes: [String]
    let image: [String]
    let hashTags: [String]
    let comments: [CommentData]
    let time: String
    let _id: String
    let creator: CreatorInfo
    let content: String?
    let content1: String?
    let product_id: String
}

struct CommentData: Decodable {
    let _id: String
    let content: String
    let time: String
    let creator: CreatorInfo
}

struct CreatorInfo: Decodable {
    let _id: String
    let nick: String
    let profile: String?
}


struct contentResultModel: Decodable {
    let message: String
}
