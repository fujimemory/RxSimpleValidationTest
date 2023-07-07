//
//  ViewController.swift
//  RxValidationExample
//
//  Created by 藤森太暉 on 2023/07/07.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    
    @IBOutlet weak var firstValidLabel: UILabel!
    @IBOutlet weak var secondValidLabel: UILabel!
    
    
    @IBOutlet weak var confilmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstValidLabel.text = "NG"
        secondValidLabel.text = "NG"
        
        let emailValid = firstTextField.rx.text.orEmpty
            .map({$0.count >= 8})
            .share(replay: 1)
        
        let passwordValid = secondTextField.rx.text.orEmpty
            .map({$0.count >= 8})
            .share(replay: 1)
        
        let validAll = Observable.combineLatest(emailValid,passwordValid) {$0 && $1}
            .share(replay: 1)
        
        emailValid
            .subscribe(onNext: {event in
                self.branchMessage(event, targetLabel: self.firstValidLabel)
            })
            .disposed(by: disposeBag)
        
        emailValid
            .bind(to: secondTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        passwordValid
            .subscribe(onNext: {event in
                self.branchMessage(event, targetLabel: self.secondValidLabel)
            })
            .disposed(by: disposeBag)
        
        validAll
            .bind(to: confilmButton.rx.isEnabled)
            .disposed(by:disposeBag)
        
        confilmButton.rx.tap
            .subscribe { [weak self] _  in
                self?.showAlert()
            }
            .disposed(by: disposeBag)
    }

    func branchMessage(_ valid :Bool,targetLabel: UILabel){
        targetLabel.text = valid ? "OK" : "NG"
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "確認",
                                      message: "1: \(firstTextField.text!)\n2: \(secondTextField.text!)",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "完了", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
        
    }
}

