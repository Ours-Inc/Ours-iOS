//
//  ChannelCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 8/14/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelCoordinator: PresentableCoordinator<Void> {

    let channelType: ChannelType
    lazy var channelVC = ChannelViewController(channelType: self.channelType, delegate: self)

    init(router: Router, channelType: ChannelType) {
        self.channelType = channelType
        if case let .channel(channel) = channelType {
            ChannelManager.shared.selectedChannel = channel
        }
        super.init(router: router, deepLink: nil)
    }

    override func toPresentable() -> DismissableVC {
        return self.channelVC
    }

    override func start() {
        self.channelVC.didDismiss = { [unowned self] in
            self.finishFlow(with: ())
        }
    }
}

extension ChannelCoordinator: ChannelDetailBarDelegate {

    func channelDetailBarDidTapClose(_ view: ChannelDetailBar) {
        self.toPresentable().dismiss(animated: true, completion: nil)
    }

    func channelDetailBarDidTapMenu(_ view: ChannelDetailBar) {
        //Present channel menu
    }
}