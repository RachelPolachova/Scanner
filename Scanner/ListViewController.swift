//
//  ListViewController.swift
//  Scanner
//
//  Created by Ráchel Polachová on 19/09/2021.
//

import UIKit
import MessageUI

class ListViewController: UIViewController {
    
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var tablieView: UITableView! {
        didSet {
            self.tablieView.delegate = self
            self.tablieView.dataSource = self
        }
    }
    
    private var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPerson") as? AddPersonViewController {
            vc.delegate = self
            vc.isModalInPresentation = true
            self.present(vc, animated: true)
        } else {
            print("yo, no vc.")
        }
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        self.createCSV()
    }
    
    private func createCSV() {
        var csvString = "\("Name"),\("Watch serial no."),\("iPhone serial no."),\("iPad serial no."),\("Keyboard serial no."),\("Mouse serial no."),\("Trackpad serial no."), \("Hub")\n\n"
        for item in self.items {
            csvString = csvString.appending("\(item.name)")
            item.devices.forEach{ csvString.append(",\($0.serialNo ?? "-")") }
            csvString.append("\n")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            self.sendViaMail(fileUrl: fileURL)
            
        } catch {
            print("error creating file")
        }
    }
    
    func sendViaMail(fileUrl: URL) {
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self

        //Set to recipients
        mailComposer.setToRecipients(["your email address heres"])

        //Set the subject
        mailComposer.setSubject("Packages export")

        //set mail body
        mailComposer.setMessageBody("Tralalalala", isHTML: true)
        
        if let fileData = NSData(contentsOfFile: fileUrl.path)
        {
            print("File data loaded.")
            mailComposer.addAttachmentData(fileData as Data, mimeType: "application/csv", fileName: "export.csv")

        }

        //this will compose and present mail to user
        self.present(mailComposer, animated: true, completion: nil)

    }
}

extension ListViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("good.")
        
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            self.items = []
            DispatchQueue.main.async {
                self.checkMark.isHidden = false
                self.tablieView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.checkMark.isHidden = true
                }
            }
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemTableViewCell else { fatalError("no cell") }
        
        cell.configure(with: self.items[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPerson") as? AddPersonViewController {
            vc.delegate = self
            vc.updateView(with: self.items[indexPath.row], index: indexPath.row)
            vc.isModalInPresentation = true
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
            self.items.remove(at: indexPath.row)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
}

extension ListViewController: AddPersonDelegate {
    func added(_ item: Item) {
        self.items.append(item)
        DispatchQueue.main.async {
            self.tablieView.reloadData()
        }
    }
    
    func edited(_ item: Item, at index: Int) {
        self.items[index] = item
        DispatchQueue.main.async {
            self.tablieView.reloadData()
        }
    }
}
