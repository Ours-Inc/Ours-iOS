//
//  AttachmentView.swift
//  Ours
//
//  Created by Benji Dodgson on 1/22/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Combine

class AttachmentView: View {

    private let imageView = DisplayableImageView()
    private var cancellables = Set<AnyCancellable>()

    static let expandedHeight: CGFloat = 100

    @Published var messageKind: MessageKind?
    private(set) var attachment: Attachment?

    override func initializeSubviews() {
        super.initializeSubviews()

        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.imageView)
        self.imageView.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
    }

    func configure(with item: Attachment?) {

        self.attachment = item
        
        guard let attachement = item else {
            self.messageKind = nil
            self.attachment = nil 
            self.imageView.displayable = nil 
            self.layoutNow()
            return
        }

        AttachmentsManager.shared.getMessageKind(for: attachement, body: String())
            .mainSink { (result) in
                switch result {
                case .success(let kind):
                    self.messageKind = kind
                    self.imageView.displayable = kind.displayable
                    self.layoutNow()
                case .error(_):
                    break
                }
            }.store(in: &self.cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.expandToSuperviewSize()
    }
}
