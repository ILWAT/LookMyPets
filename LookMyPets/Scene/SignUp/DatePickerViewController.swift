//
//  DatePickerViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 12/1/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class DatePickerViewController: BaseViewController {
    //MARK: - View Properties
    private let picker = {
        let view = UIDatePicker()
        view.preferredDatePickerStyle = .wheels
        view.datePickerMode = .date
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    let date = BehaviorRelay(value: Date())
    
    //MARK: - Configure
    override func configure() {
        configureViewHierarchy()
        configureConstraints()
    }
    
    override func bind() {
        picker.rx.date
            .asDriver(onErrorJustReturn: date.value)
            .drive(with: self) { owner, date in
                owner.date.accept(date)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - configureView
    private func configureViewHierarchy() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(picker)
    }
    
    private func configureConstraints() {
        picker.snp.makeConstraints { make in
//            make.horizontalEdges.top.equalTo(self.view.safeAreaLayoutGuide)
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}
