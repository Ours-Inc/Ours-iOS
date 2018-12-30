//
//  ChannelViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelViewController: FullScreenViewController {

    lazy var collectionView: ChannelCollectionView = {
        let flowLayout = BouncyLayout(style: .subtle)
        flowLayout.scrollDirection = .vertical
        return ChannelCollectionView(flowLayout: flowLayout)
    }()

    lazy var manager: ChannelCollectionViewManager = {
        return ChannelCollectionViewManager(with: self.collectionView, items: self.items)
    }()

    let messageInputView = MessageInputView()

    var items: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let item1 = Message(id: "1",
                            text: "Hey wanna grab coffee?",
                            backgroundColor: .lightGray)

        let item2 = Message(id: "2",
                            text: "Sure! Where would you like to meet up?",
                            backgroundColor: .blue)

        let item3 = Message(id: "3",
                            text: "I actually know of a really good place in Freemont. Milstead! Have you been?",
                            backgroundColor: .blue)

        let item4 = Message(id: "4",
                            text: "No I haven't but I have always wanted to try it!",
                            backgroundColor: .lightGray)

        let item5 = Message(id: "5",
                            text: "Friday morning at 10am?",
                            backgroundColor: .lightGray)

        let item6 = Message(id: "6",
                            text: "Sounds great! See you then.",
                            backgroundColor: .blue)

        self.items.append(contentsOf: [item1, item2, item3, item4, item5, item6, item1, item2, item3, item4, item5, item6, item1, item2, item3, item4, item5, item6, item1, item2, item3, item4, item5, item6])

        self.collectionView.dataSource = self.manager
        self.collectionView.delegate = self.manager

        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.messageInputView)
    }

    override func viewIsReadyForLayout() {
        super.viewIsReadyForLayout()

        self.collectionView.frame = self.view.bounds
        
        self.messageInputView.size = CGSize(width: 300, height: 50)
        self.messageInputView.bottom = self.view.height - 40
        self.messageInputView.centerOnX()
    }
}
