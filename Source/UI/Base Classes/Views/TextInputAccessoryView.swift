//
//  TextInputAccessoryView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class TextInputAccessoryView: View {

    private let label = XXSmallSemiBoldLabel()
    private let cancelButton = CancelButton()
    private var blurView = UIVisualEffectView(effect: nil)
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)

    var text: Localized? {
        didSet {
            guard let text = self.text else { return }
            self.label.set(text: text, color: .white, alignment: .left, stringCasing: .unchanged)
            self.layoutNow()
        }
    }

    var keyboardAppearance: UIKeyboardAppearance? {
        didSet {
            if let appearance = self.keyboardAppearance, appearance == .light {
                self.blurView.effect = nil
            } else {
                self.blurView.effect = UIBlurEffect(style: .dark)
            }
            self.set(backgroundColor: .keyboardBackground)
        }
    }

    var didCancel: CompletionOptional = nil

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .keyboardBackground)

        self.addSubview(self.blurView)
        self.addSubview(self.label)
        self.addSubview(self.cancelButton)
        self.cancelButton.onTap { [unowned self] (tap) in
            self.selectionFeedback.impactOccurred()
            self.didCancel?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurView.expandToSuperviewSize()

        self.cancelButton.centerOnY()
        self.cancelButton.right = self.width - Theme.contentOffset

        let maxWidth = self.width - (Theme.contentOffset * 3) - 44
        self.label.setSize(withWidth: maxWidth)
        self.label.left = Theme.contentOffset
        self.label.top = 8
    }
}