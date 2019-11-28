//
//  ChannelViewController+Updates.swift
//  Benji
//
//  Created by Benji Dodgson on 11/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelViewController {

    func loadMessages() {
        self.collectionViewManager.reset()

        switch self.channelType {
        case .system(let channel):
            self.loadSystem(channel: channel)
        case .channel(_):
            self.loadTwilioMessages()
        }
    }

    private func loadTwilioMessages() {
        guard let channel = ChannelManager.shared.selectedChannel.value else { return }

        MessageSupplier.shared.getLastMessages(for: channel)
            .observe { (result) in
                switch result {
                case .success(let sections):
                    self.collectionView.activityIndicator.stopAnimating()
                    self.collectionViewManager.set(newSections: sections) { [unowned self] in
                        self.collectionView.scrollToBottom()
                    }
                case .failure(_):
                    break
                }
        }
    }

    private func loadSystem(channel: SystemChannel) {

        let sections = MessageSupplier.shared.mapMessagesToSections(for: channel.messages, in: .system(channel))

        self.collectionViewManager.set(newSections: sections) { [weak self] in
            guard let `self` = self else { return }
            self.collectionView.scrollToBottom()
        }
    }

    func subscribeToClient() {
        ChannelManager.shared.clientSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self, let clientUpdate = update else { return }

            switch clientUpdate {
            case .started, .channelsListCompleted:
                self.collectionView.activityIndicator.startAnimating()
            case .completed:
                self.collectionView.activityIndicator.stopAnimating()
                self.subscribeToUpdates()
            case .failed:
                self.collectionView.activityIndicator.stopAnimating()
            @unknown default:
                break
            }
        }
        .start()
    }


    private func subscribeToUpdates() {

        if ChannelManager.shared.isSynced {
            self.loadMessages()
        }

        ChannelManager.shared.messageUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let channelUpdate = update,
                channelUpdate.channel == ChannelManager.shared.selectedChannel.value else { return }

            switch channelUpdate.status {
            case .added:
                if self.collectionView.isTypingIndicatorHidden {
                    self.collectionViewManager.updateLastItem(with: channelUpdate.message) {
                        self.collectionView.scrollToBottom()
                    }
                } else {
                    self.collectionViewManager.setTypingIndicatorViewHidden(true, performUpdates: { [weak self] in
                        guard let `self` = self else { return }
                        self.collectionViewManager.updateLastItem(with: channelUpdate.message,
                                                                  replaceTypingIndicator: true,
                                                                  completion: nil)
                    })
                }
            case .changed:
                self.collectionViewManager.update(item: channelUpdate.message)
            case .deleted:
                self.collectionViewManager.delete(item: channelUpdate.message)
            case .toastReceived:
                break
            }
            }.start()

        ChannelManager.shared.memberUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let memberUpdate = update,
                memberUpdate.channel == ChannelManager.shared.selectedChannel.value else { return }

            switch memberUpdate.status {
            case .joined:
                break
            case .left:
                break
            case .changed:
                self.loadMessages()
            case .typingEnded:
                if let memberID = memberUpdate.member.identity, memberID != User.current()?.objectId {
                    self.collectionViewManager.setTypingIndicatorViewHidden(true)
                }
            case .typingStarted:
                if let memberID = memberUpdate.member.identity, memberID != User.current()?.objectId {
                    self.collectionViewManager.setTypingIndicatorViewHidden(false, performUpdates: nil)
                }
            }
        }.start()

        ChannelManager.shared.channelSyncUpdate.producer.on { [weak self] (update) in
            guard let `self` = self else { return }

            guard let syncUpdate = update else { return }

            switch syncUpdate.status {
                case .none, .identifier, .metadata, .failed:
                    break
                case .all:
                    self.loadMessages()
                @unknown default:
                    break
            }

        }.start()
    }
}