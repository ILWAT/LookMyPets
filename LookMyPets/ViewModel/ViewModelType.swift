//
//  ViewModelType.swift
//  LookMyPets
//
//  Created by 문정호 on 11/27/23.
//

import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
