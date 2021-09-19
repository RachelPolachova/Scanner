//
//  ItemTableViewCell.swift
//  ItemTableViewCell
//
//  Created by Ráchel Polachová on 07/09/2021.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subviews = self.iconsStackView.subviews
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(with item: Item) {
        self.nameLabel.text = item.name
        print("devics: \(item.devices.count)")
        item.devices.forEach { device in
            var image: UIImage?
            if let systemImage = UIImage(systemName: device.type.iconName) {
                image = systemImage
            } else {
                image = UIImage(named: device.type.iconName)
            }
            let imageView = UIImageView(image: image)
            imageView.tintColor = device.state == .valid ? .green : .red
            self.iconsStackView.addArrangedSubview(imageView)
        }
    }
}
