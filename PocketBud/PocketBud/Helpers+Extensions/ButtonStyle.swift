//
//  ButtonStyle.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/17/22.
//

import UIKit

class ButtonStyle: UIButton {

    override init(frame: CGRect) {
            super.init(frame: frame)
            setupButton()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupButton()
        }

        private func setupButton() {
            setTitleColor(.black, for: .normal)
            layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            layer.shadowOpacity = 1.0
            layer.shadowRadius = 8.0
            layer.masksToBounds = false
//            backgroundColor = ColorController.richGold.value
            layer.cornerRadius = 24
        }

}
