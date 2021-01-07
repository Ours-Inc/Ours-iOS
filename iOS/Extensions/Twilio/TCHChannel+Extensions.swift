//
//  TCHChannel+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROFutures

extension TCHChannel: ManageableCellItem {

    var id: String {
        return self.sid!
    }
    
    var backgroundColor: Color {
        return .blue
    }

    var isOwnedByMe: Bool {
        guard let currentUser = User.current() else { return false }
        return self.createdBy == currentUser.objectId
    }

    func diffIdentifier() -> NSObjectProtocol {
        return String(optional: self.sid) as NSObjectProtocol
    }

    func getNonMeMembers() -> Future<[TCHMember]> {

        let promise = Promise<[TCHMember]>()
        if let members = self.members?.membersList() {
            var nonMeMembers: [TCHMember] = []
            members.forEach { (member) in
                if member.identity != User.current()?.objectId {
                    nonMeMembers.append(member)
                }
            }
        } else {
            promise.reject(with: ClientError.message(detail: "There was a problem fetching other members."))
        }

        return promise
    }

    func getAuthorAsUser() -> Future<User> {
        let promise = Promise<TCHChannel>(value: self)
        return promise.getAuthorAsUser()
    }

    func getMembersAsUsers() -> Future<[User]> {
        let promise = Promise<TCHChannel>(value: self)
        return promise.getUsers()
    }

    var channelDescription: String {
        guard let attributes = self.attributes(),
            let text = attributes.dictionary?[ChannelKey.description.rawValue] as? String else { return String() }
        return text
    }

    func getUnconsumedAmount() -> Future<FeedType> {
        let promise = Promise<FeedType>()
        var totalUnread: Int = 0
        if let messagesObject = self.messages {
            self.getMessagesCount { (result, count) in
                if result.isSuccessful() {
                    messagesObject.getLastWithCount(count) { (messageResult, messages) in

                        if messageResult.isSuccessful(), let msgs = messages {
                            msgs.forEach { (message) in
                                if !message.isFromCurrentUser, !message.isConsumed, message.canBeConsumed {
                                    totalUnread += 1
                                }
                            }
                            promise.resolve(with: .unreadMessages(self, totalUnread))
                        } else {
                            promise.reject(with: ClientError.message(detail: "Unable to get messages."))
                        }
                    }
                } else {
                    promise.reject(with: ClientError.message(detail: "Failed to get message count."))
                }
            }
        } else {
            promise.reject(with: ClientError.message(detail: "There were no messages."))
        }

        return promise
    }
}

extension Future where Value == TCHChannel {

    func getAuthorAsUser() -> Future<User> {
        return self.then(with: { (channel) in
            let promise = Promise<User>()
            if let authorID = channel.createdBy {
                User.localThenNetworkQuery(for: authorID)
                    .observeValue(with: { (user) in
                        promise.resolve(with: user)
                    })
            } else {
                promise.reject(with: ClientError.message(detail: "This channel has no author ID."))
            }

            return promise
        })
    }

    func getUsers() -> Future<[User]> {
        return self.then { (channel) in
            let promise = Promise<[User]>()
            if let members = channel.members?.membersList() {

                var identifiers: [String] = []
                members.forEach { (member) in
                    if let identifier = member.identity {
                        identifiers.append(identifier)
                    }
                }

                User.localThenNetworkArrayQuery(where: identifiers,
                                            isEqual: true,
                                            container: .channel(identifier: channel.sid!))
                .observeValue(with: { (users) in
                    promise.resolve(with: users)
                })
            }

            return promise
        }
    }
}

extension TCHChannel: Avatar {

    var givenName: String {
        return String()
    }

    var familyName: String {
        return String()
    }

    var user: User? {
        return nil
    }

    var image: UIImage? {
        return nil
    }
    
    var userObjectID: String? {
        return self.createdBy
    }
}

extension TCHChannel: Comparable {
    public static func < (lhs: TCHChannel, rhs: TCHChannel) -> Bool {
        guard let lhsDate = lhs.dateUpdatedAsDate, let rhsDate = rhs.dateUpdatedAsDate else { return false }
        return lhsDate > rhsDate
    }
}
