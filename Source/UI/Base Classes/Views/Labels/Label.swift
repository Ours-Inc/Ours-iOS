//
//  Label.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class Label: UILabel {

    func set(attributed: AttributedString,
             alignment: NSTextAlignment = .left,
             lineCount: Int = 0,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             stringCasing: StringCasing = .unchanged) {

        let string = stringCasing.format(string: attributed.string.string)
        let newString = NSMutableAttributedString(string: string)
        newString.addAttributes(attributed.attributes, range: NSRange(location: 0,
                                                                      length: newString.length))
        // NOTE: Some emojis don't display properly with certain attributes applied to them
        for emojiRange in string.getEmojiRanges() {
            newString.removeAttributes(atRange: emojiRange)
        }

        self.attributedText = newString
        self.numberOfLines = lineCount
        self.lineBreakMode = lineBreakMode
        self.textAlignment = alignment
    }

    func setSize(withWidth width: CGFloat) {
        guard let t = self.text,
            !t.isEmpty,
            let attText = self.attributedText else { return }

        let attributes = attText.attributes(at: 0,
                                            longestEffectiveRange: nil,
                                            in: NSRange(location: 0, length: attText.length))

        let maxSize = CGSize(width: width, height: CGFloat.infinity)

        let labelSize: CGSize = t.boundingRect(with: maxSize,
                                               options: .usesLineFragmentOrigin,
                                               attributes: attributes,
                                               context: nil).size

        self.size = labelSize
    }
}
