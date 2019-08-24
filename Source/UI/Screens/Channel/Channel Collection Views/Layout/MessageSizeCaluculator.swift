//
//  MessageSizeCaluculator.swift
//  Benji
//
//  Created by Benji Dodgson on 7/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageSizeCalculator: CellSizeCalculator {

    var avatarSize = CGSize(width: 30, height: 30)
    var avatarLeadingPadding: CGFloat = 8
    var messageTextViewVerticalPadding: CGFloat = 10
    var messageTextViewHorizontalPadding: CGFloat = 20
    var bubbleViewHorizontalPadding: CGFloat = 14
    private let widthRatio: CGFloat = 0.8

    init(layout: ChannelCollectionViewFlowLayout? = nil) {
        super.init()

        self.channelLayout = layout
    }

    override func configure(attributes: UICollectionViewLayoutAttributes) {
        guard let attributes = attributes as? ChannelCollectionViewLayoutAttributes,
        let layout = self.channelLayout else { return }

        let dataSource = layout.dataSource
        let indexPath = attributes.indexPath
        guard let message = dataSource.item(at: indexPath) else { return }

        attributes.isFromCurrentUser = message.isFromCurrentUser

        attributes.avatarSize = self.avatarSize
        attributes.avatarLeadingPadding = self.avatarLeadingPadding

        let textViewSize = self.getMessageTextViewSize(for: message)
        attributes.messageTextViewSize = textViewSize
        attributes.messageTextViewVerticalPadding = self.messageTextViewVerticalPadding
        attributes.messageTextViewMaxWidth = layout.itemWidth * self.widthRatio

        let leadingPaddingForIncoming = self.avatarSize.width + self.avatarLeadingPadding + self.messageTextViewHorizontalPadding
        let leadingPadding = message.isFromCurrentUser ? self.messageTextViewHorizontalPadding + self.avatarLeadingPadding : leadingPaddingForIncoming
        attributes.messageTextViewHorizontalPadding = leadingPadding

        let bubbleHeight = textViewSize.height + (self.messageTextViewVerticalPadding * 2)
        let bubbleWidth = textViewSize.width + (self.bubbleViewHorizontalPadding * 2)
        attributes.bubbleViewSize = CGSize(width: bubbleWidth, height: bubbleHeight)
        attributes.bubbleViewHorizontalPadding = self.bubbleViewHorizontalPadding
    }

    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = self.channelLayout,
            let message = layout.dataSource.item(at: indexPath) else { return .zero }
        
        let itemHeight = self.cellContentHeight(for: message)
        return CGSize(width: layout.itemWidth, height: itemHeight)
    }

    private func cellContentHeight(for message: MessageType) -> CGFloat {
        return self.getMessageTextViewSize(for: message).height + (self.messageTextViewVerticalPadding * 2)
    }

    private func getMessageTextViewSize(for message: MessageType) -> CGSize {
        guard let layout = self.channelLayout else { return .zero }

        let attributed = AttributedString(message.body,
                                          fontType: .regular,
                                          color: .white)

        let attributedString = attributed.string
        for emojiRange in attributedString.string.getEmojiRanges() {
            attributedString.removeAttributes(atRange: emojiRange)
            if let emojiFont = UIFont(name: "AppleColorEmoji", size: attributed.style.fontType.size) {
                attributedString.addAttributes([NSAttributedString.Key.font: emojiFont], range: emojiRange)
            }
        }

        let maxWidth = (layout.itemWidth * self.widthRatio) - self.avatarLeadingPadding - self.avatarSize.width
        let size = attributedString.getSize(withWidth: maxWidth)
        return size
    }
}
