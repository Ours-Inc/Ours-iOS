//
//  HomeTabView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class HomeTabView: View {

    private(set) var profileItem = Button()
    private(set) var feedItem = Button()
    private(set) var channelsItem = Button()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)
    
    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .clear)

        self.addSubview(self.profileItem)
        self.profileItem.tintColor = Color.white.color
        self.profileItem.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        self.profileItem.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .selected)

        self.addSubview(self.feedItem)
        self.feedItem.tintColor = Color.white.color
        self.feedItem.setImage(UIImage(systemName: "square.stack"), for: .normal)
        self.feedItem.setImage(UIImage(systemName: "square.stack.fill"), for: .selected)

        self.addSubview(self.channelsItem)
        self.channelsItem.tintColor = Color.white.color
        self.channelsItem.setImage(UIImage(systemName: "bubble.left.and.bubble.right"), for: .normal)
        self.channelsItem.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .selected)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let itemWidth = self.width * 0.33

        self.profileItem.size = CGSize(width: itemWidth, height: self.height)
        self.profileItem.centerOnY()
        self.profileItem.left = 0

        self.feedItem.size = CGSize(width: itemWidth, height: self.height)
        self.feedItem.centerOnY()
        self.feedItem.left = self.profileItem.right

        self.channelsItem.size = CGSize(width: itemWidth, height: self.height)
        self.channelsItem.centerOnY()
        self.channelsItem.left = self.feedItem.right
    }

    func updateTabItems(for contentType: HomeContent) {
        self.selectionFeedback.impactOccurred()
        
        switch contentType {
        case .feed:
            self.feedItem.isSelected = true
            self.profileItem.isSelected = false
            self.channelsItem.isSelected = false
        case .channels:
            self.feedItem.isSelected = false
            self.profileItem.isSelected = false
            self.channelsItem.isSelected = true
        case .profile:
            self.feedItem.isSelected = false
            self.profileItem.isSelected = true
            self.channelsItem.isSelected = false
        }
    }
}