//
//  MessageInputView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/29/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageInputView: View, UITextViewDelegate {

    let textField = MessageInputTextField()
    let darkEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let lightEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override func initializeViews() {
        super.initializeViews()

        self.addSubview(self.darkEffectView)
        self.darkEffectView.autoPinEdgesToSuperviewEdges()

        self.addSubview(self.lightEffectView)
        self.addSubview(self.textField)

        self.textField.messagePlaceholder = "Message @Natalie"
        self.textField.delegate = self
        self.textField.height = 50
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.addShadow(withOffset: -10)

        self.lightEffectView.height = 34
        self.lightEffectView.width = self.width * 0.9
        self.lightEffectView.top = 10
        self.lightEffectView.centerOnX()
        self.lightEffectView.roundCorners()

        self.textField.frame = self.lightEffectView.frame
        self.darkEffectView.round(corners: [.topLeft, .topRight], size: CGSize(width: 10, height: 10))
    }
}

extension MessageInputView: UITextFieldDelegate {

}

class MessageInputTextField: TextField {

    var messagePlaceholder: String? {
        get {
            return super.placeholder
        }
        set {
            guard let text = newValue else { return }

            let attributed = AttributedString(text,
                                              font: .ultraLight,
                                              size: 18,
                                              color: .darkGray)

            self.setPlaceholder(attributed: attributed)
        }
    }

    override func initialize() {
        self.set(backgroundColor: .clear)

        let paddingView = View()
        paddingView.frame = CGRect(x: 0, y: 0, width: 15, height: self.height)
        paddingView.set(backgroundColor: .clear)

        self.leftView = paddingView
        self.leftViewMode = .always

        self.keyboardAppearance = .dark
        self.keyboardType = .twitter

        self.tintColor = Color.blue.color

        let style = StringStyle(font: .regular, size: 18, color: .lightGray)
        self.setDefaultAttributes(style: style)
    }
}
