//
//  AddPersonViewController.swift
//  AddPersonViewController
//
//  Created by Ráchel Polachová on 07/09/2021.
//

import UIKit

protocol AddPersonDelegate: AnyObject {
    func added(_ item: Item)
    func edited(_ item: Item, at index: Int)
}

class AddPersonViewController: UIViewController {
    
    @IBOutlet weak var personNameTextfield: UITextField! {
        didSet {
            self.personNameTextfield.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
        }
    }
    
    weak var delegate: AddPersonDelegate?
    
    private var devices: [Device] = [
        Device(type: .watch, serialNo: nil),
        Device(type: .iPhone, serialNo: nil),
        Device(type: .iPad, serialNo: nil),
        Device(type: .keyboard, serialNo: nil),
        Device(type: .mouse, serialNo: nil),
        Device(type: .trackpad, serialNo: nil)
    ]
    
    private var scanningAtIndex: Int?
    
    private var editModeAtIndex: Int?
    private var editingItem: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = self.editingItem {
            self.personNameTextfield.text = item.name
            self.devices = item.devices
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let index = self.editModeAtIndex {
            self.delegate?.edited(Item(name: self.personNameTextfield.text ?? "no name", devices: self.devices), at: index)
        } else {
            self.delegate?.added(Item(name: self.personNameTextfield.text ?? "no name", devices: self.devices))
        }
        
        self.editModeAtIndex = nil
        self.editingItem = nil
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateView(with item: Item, index: Int) {
        self.editModeAtIndex = index
        self.editingItem = item
    }
}

extension AddPersonViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ScanButtonTableViewCell else { fatalError("no cell") }
        cell.configure(for: self.devices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scanner") as? ScannerViewController {
            self.scanningAtIndex = indexPath.row
            vc.delegate = self
            DispatchQueue.main.async {
                self.present(vc, animated: true)
            }
        } else {
            print("yo, no vc.")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.devices[indexPath.row].serialNo = nil
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
}

extension AddPersonViewController: ScannerDelegate, UITextFieldDelegate {
    
    func scanned(_ code: String) {
        if let index = self.scanningAtIndex {
            self.devices[index].serialNo = code
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.resignFirstResponder()
        }
        return true
    }
}
