//
//  ChannelManager+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 4/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROFutures

typealias CompletionHandler = (_ success: Bool, _ error: Error?) -> Void
typealias ClientCompletion = (_ client: TwilioChatClient, _ error: Error?) -> Void
typealias ChannelsCompletion = (_ channel: [TCHChannel], _ error: Error?) -> Void
typealias ChannelCreationCompletion = (_ channel: TCHChannel?, _ error: Error?) -> Void

struct ChatClientUpdate {
    var client: TwilioChatClient
    var status: Status

    enum Status {
        case connectionState(TCHClientConnectionState)
        case userUpdate(TCHUser, TCHUserUpdate)
        case toastSubscribed
        case toastRegistrationFailed(TCHError)
        case error(TCHError)
    }
}

struct ChannelUpdate {
    var channel: TCHChannel
    var status: Status

    enum Status {
        case added
        case changed
        case deleted
    }
}

struct ChannelSyncUpdate {
    var channel: TCHChannel
    var status: TCHChannelSynchronizationStatus
}

struct MessageUpdate {
    var channel: TCHChannel
    var message: TCHMessage
    var status: Status

    enum Status {
        case added
        case changed
        case deleted
        case toastReceived
    }
}

struct ChannelMemberUpdate {
    var channel: TCHChannel
    var member: TCHMember
    var status: Status

    enum Status {
        case joined
        case left
        case changed
        case typingEnded
        case typingStarted
    }
}

extension ChatClientManager: TwilioChatClientDelegate {

    @discardableResult
    func initialize(token: String) -> Future<Void> {
        let promise = Promise<Void>()
        TwilioChatClient.chatClient(withToken: token,
                                    properties: nil,
                                    delegate: self,
                                    completion: { (result, client) in

                                        if let error = result.error {
                                            promise.reject(with: error)
                                        } else if let strongClient = client {
                                            self.client = strongClient
                                            //TwilioChatClient.setLogLevel(.debug)
                                            promise.resolve(with: ())
                                        } else {
                                            promise.reject(with: ClientError.message(detail: "Failed to initialize chat client."))
                                        }
        })

        return promise
    }

    @discardableResult
    func update(token: String) -> Future<Void> {
        let promise = Promise<Void>()
        if let client = self.client {
            client.updateToken(token, completion: { (result) in
                if result.isSuccessful() {
                    promise.resolve(with: ())
                } else if let e = result.error {
                    promise.reject(with: e)
                } else {
                    promise.reject(with: ClientError.message(detail: "Failed to update chat token."))
                }
            })
        }

        return promise
    }

    //MARK: CLIENT UDPATES

    func chatClientTokenExpired(_ client: TwilioChatClient) {
        self.getNewChatTokent()
    }

    func chatClientTokenWillExpire(_ client: TwilioChatClient) {
        self.getNewChatTokent()
    }

    private func getNewChatTokent() {
        GetChatToken()
            .makeRequest(andUpdate: [], viewsToIgnore: [])
            .observeValue { (token) in
                self.update(token: token)
        }
    }

    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        self.clientSyncUpdate = status
    }

    func chatClient(_ client: TwilioChatClient, connectionStateUpdated state: TCHClientConnectionState) {
        self.clientUpdate = ChatClientUpdate(client: client, status: .connectionState(state))
    }

    func chatClient(_ client: TwilioChatClient, user: TCHUser, updated: TCHUserUpdate) {
        self.clientUpdate = ChatClientUpdate(client: client, status: .userUpdate(user, updated))
    }

    func chatClientToastSubscribed(_ client: TwilioChatClient!) {
        self.clientUpdate = ChatClientUpdate(client: client, status: .toastSubscribed)
    }

    func chatClient(_ client: TwilioChatClient!, toastRegistrationFailedWithError error: TCHError!) {
        self.clientUpdate = ChatClientUpdate(client: client, status: .toastRegistrationFailed(error))
    }

    func chatClient(_ client: TwilioChatClient, errorReceived error: TCHError) {
        self.clientUpdate = ChatClientUpdate(client: client, status: .error(error))
    }

    //MARK: CHANNEL UPDATES

    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        self.channelsUpdate = ChannelUpdate(channel: channel, status: .added)
    }

    func chatClient(_ client: TwilioChatClient!, channelChanged channel: TCHChannel!) {
        self.channelsUpdate = ChannelUpdate(channel: channel, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        self.channelsUpdate = ChannelUpdate(channel: channel, status: .deleted)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        self.channelSyncUpdate = ChannelSyncUpdate(channel: channel, status: status)
    }

    //MARK: MEMBER UDPATES

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .left)
        self.handle(member: member, in: channel, status: .left)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .joined)
        self.handle(member: member, in: channel, status: .left)
    }

    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberChanged member: TCHMember!) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, typingEndedOn channel: TCHChannel, member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .typingEnded)
    }

    func chatClient(_ client: TwilioChatClient, typingStartedOn channel: TCHChannel, member: TCHMember) {
        self.memberUpdate.value = ChannelMemberUpdate(channel: channel, member: member, status: .typingStarted)
        self.handle(member: member, in: channel, status: .typingStarted)
    }

    private func handle(member: TCHMember, in channel: TCHChannel, status: ChannelMemberUpdate.Status) {
        guard ChannelSupplier.shared.activeChannel.isNil else { return }
        member.getMemberAsUser()
            .observeValue { (user) in
                runMain {
//                    ToastScheduler.shared.schedule(toastType: .userStatusUpdateInChannel(user, status, channel))
                }
        }
    }

    //MARK: MESSAGE UPDATES

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .added)

        if ChannelSupplier.shared.activeChannel.isNil, !message.isFromCurrentUser, message.context != .emergency {
//            ToastScheduler.shared.schedule(toastType: .message(message, channel))
        }
    }

    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, messageChanged message: TCHMessage!) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .changed)
    }

    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageDeleted message: TCHMessage) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .deleted)
    }

    func chatClient(_ client: TwilioChatClient!, toastReceivedOn channel: TCHChannel!, message: TCHMessage!) {
        self.messageUpdate.value = MessageUpdate(channel: channel, message: message, status: .toastReceived)
    }
}

