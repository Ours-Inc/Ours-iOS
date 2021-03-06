//
//  ChannelsViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Combine
import TMROLocalization

protocol ChannelsViewControllerDelegate: AnyObject {
    func channelsView(_ controller: ChannelsViewController, didSelect channelType: ChannelType)
    func channelsView(_ controller: ChannelsViewController, didSelect reservation: Reservation)
    func channelsViewControllerDidTapAdd(_ controller: ChannelsViewController)
}

class ChannelsViewController: CollectionViewController<ChannelsCollectionViewManager.SectionType, ChannelsCollectionViewManager> {

    weak var delegate: ChannelsViewControllerDelegate?

    private let addButton = Button()

    private lazy var channelsCollectionView = ChannelsCollectionView()
    private let gradientView = GradientView()

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background1)

        self.view.insertSubview(self.addButton, aboveSubview: self.collectionViewManager.collectionView)
        self.addButton.set(style: .icon(image: UIImage(systemName: "plus")!, color: .lightPurple))
        self.addButton.didSelect { [unowned self] in
            self.delegate?.channelsViewControllerDidTapAdd(self)
        }

        self.view.insertSubview(self.gradientView, belowSubview: self.addButton)

        self.collectionViewManager.$onSelectedItem.mainSink { (result) in
            guard let selection = result else { return }
            switch selection.section {
            case .channels:
                if let channel = selection.item as? DisplayableChannel {
                    self.delegate?.channelsView(self, didSelect: channel.channelType)
                }
            case .reservations:
                if let reservation = selection.item as? Reservation {
                    self.didSelect(reservation: reservation)
                }
            }
        }.store(in: &self.cancellables)
    }

    override func getCollectionView() -> CollectionView {
        return self.channelsCollectionView
    }

    private func didSelect(reservation: Reservation) {
        reservation.prepareMetaData(andUpdate: [])
            .mainSink(receiveValue: { (_) in
                self.delegate?.channelsView(self, didSelect: reservation)
            }, receiveCompletion: { (_) in }).store(in: &self.cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.addButton.squaredSize = 60
        self.addButton.makeRound()
        self.addButton.pin(.right, padding: Theme.contentOffset)
        self.addButton.pinToSafeArea(.bottom, padding: 0)

        self.gradientView.expandToSuperviewWidth()
        self.gradientView.height = self.view.height - self.addButton.top + 20
        self.gradientView.pin(.bottom)
        self.gradientView.pin(.left)
    }
}
