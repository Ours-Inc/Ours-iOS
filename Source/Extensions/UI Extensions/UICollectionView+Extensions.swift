//
//  UICollectionView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UICollectionView {

    func reload<T: Diffable>(previousItems: [T],
                             newItems: [T],
                             equalityOption: IGListDiffOption,
                             completion: ((Bool) -> Swift.Void)? = nil) {
        let previousBoxItems: [ListDiffable] = previousItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }
        let newBoxItems: [ListDiffable] = newItems.map { (item) -> ListDiffable in
            return DiffableBox<T>(value: item, equal: ==)
        }

        self.reload(previousItems: previousBoxItems,
                    newItems: newBoxItems,
                    equalityOption: equalityOption,
                    completion: completion)
    }

    func reload(previousItems: [ListDiffable],
                newItems: [ListDiffable],
                equalityOption: IGListDiffOption,
                completion: ((Bool) -> Swift.Void)? = nil) {


        let diffResult: ListIndexPathResult = ListDiffPaths(fromSection: 0,
                                                            toSection: 0,
                                                            oldArray: previousItems,
                                                            newArray: newItems,
                                                            option: equalityOption)
        self.reloadItems(withDiffResult: diffResult, completion: completion)
    }

    private func reloadItems(withDiffResult diffResult: ListIndexPathResult,
                             completion: ((Bool) -> Swift.Void)? = nil) {

        // Don't reload the collection view if no changes have been made to the items array
        guard diffResult.hasChanges else { return }

        let sanitizedResults: ListIndexPathResult = diffResult.forBatchUpdates()

        self.performBatchUpdates({
            self.deleteItems(at: sanitizedResults.deletes)
            self.insertItems(at: sanitizedResults.inserts)
            self.reloadItems(at: sanitizedResults.updates)
            for moveIndexPath in sanitizedResults.moves {
                self.moveItem(at: moveIndexPath.from, to: moveIndexPath.to)
            }
        }, completion: { (completed) in
            // Force collection view to update otherwise the cells will reflect the old layout
            self.collectionViewLayout.invalidateLayout()
            completion?(completed)
        })
    }
}