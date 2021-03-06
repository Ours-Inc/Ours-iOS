//
//  Subscribeable.swift
//  Ours
//
//  Created by Benji Dodgson on 2/15/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import ParseLiveQuery
import Combine

protocol Subscribeable where Self: PFObject {
    func subscribe() -> Future<Event<Self>, Error>
}

extension Subscribeable {
    func subscribe() -> Future<Event<Self>, Error> {
        return Future { promise in
            let query = Self.query() as? PFQuery<Self>
            query?.whereKey("objectId", equalTo: self.objectId!)
            let subscription = Client.shared.subscribe(query!)
            subscription.handleEvent { (query, event) in
                promise(.success(event))
            }
        }
    }
}
