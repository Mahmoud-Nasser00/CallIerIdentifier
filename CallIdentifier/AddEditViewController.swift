//
//  AddEditViewController.swift
//  CallIdentifier
//
//  Created by Mahmoud Nasser on 10/03/2021.
//

import UIKit
import CallerData

class AddEditViewController: UIViewController {

    @IBOutlet weak var callerName: UITextField!
    @IBOutlet weak var callerNumber: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var caller:Caller? {
        didSet{
            updateUI()
        }
    }
    
    var callerData:CallerData!
    var isBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callerNumber.delegate = self
        callerNumber.delegate = self
        title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    private func updateUI(){
        guard let caller = caller , let callerName = callerName , let callerNumber = callerNumber
        else {return}
        
        callerName.text = caller.name
        callerNumber.text = caller.number != 0 ? String(caller.number) : ""
        navigationItem.title = caller.name
        
        updateSaveButton()
    }

    private func updateSaveButton(){
        self.saveButton.isEnabled = false
        guard let name = self.callerName.text,
              let number = self.callerNumber.text else {
            return
        }
        self.saveButton.isEnabled = !(name.isEmpty || number.isEmpty)
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        self.updateSaveButton()
    }
    
    @IBAction func saveBtnTapped(_ sender:UIBarButtonItem){
        if let numberText = callerNumber.text ,
           let number = Int64(numberText) {
            let caller = self.caller ?? Caller(context: self.callerData.context)
            caller.name = callerName.text
            caller.number = number
            caller.isBlocked = isBlocked
            caller.isRemoved = false
            caller.updateDate = Date()
            self.callerData.saveContext()
        }
        
        performSegue(withIdentifier: "unwindFromSave", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddEditViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text ,
              let textRange = Range(range, in: text)
        else {
            return false
        }
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        if textField == callerName {
            if updatedText.isEmpty {
                return true
            }
            if Int64(updatedText) == nil {
                return false
            }
        }
        
        if textField == callerNumber {
            if updatedText.isEmpty {
                navigationItem.title = updatedText
            }
        }
        return true
    }
    
}
