//
//  ScanButtonTableViewCell.swift
//  ScanButtonTableViewCell
//
//  Created by Ráchel Polachová on 07/09/2021.
//

import UIKit

class ScanButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var scannedSerialNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.deviceTypeLabel.text = "unknown"
        self.scannedSerialNo.text = "unknown"
    }
    
    func configure(for device: Device) {
        self.deviceTypeLabel.text = device.type.rawValue
        self.scannedSerialNo.text = device.serialNo
    }
}
