//
//  FeedIndicatorView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/19/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol FeedIndicatorViewDelegate: AnyObject {
    func feedIndicator(_ view: FeedIndicatorView, didFinishProgressFor index: Int)
}

class FeedIndicatorView: View {

    private let offset: CGFloat = 10
    private var elements: [IndicatorView] = []
    private unowned let delegate: FeedIndicatorViewDelegate

    init(with delegate: FeedIndicatorViewDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.clipsToBounds = false
    }

    func configure(with count: Int) {

        self.removeAllSubviews()
        self.elements = []

        guard count > 0 else { return }
        
        for _ in 1...count {
            let element = IndicatorView()
            self.elements.append(element)
            self.addSubview(element)
        }

        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard self.elements.count > 0 else { return }

        var totalOffsets = self.offset * CGFloat(self.elements.count - 1)
        totalOffsets = clamp(totalOffsets, min: self.offset)
        var itemWidth = (self.width - totalOffsets) / CGFloat(self.elements.count)
        itemWidth = clamp(itemWidth, min: 1)
        
        let itemSize = CGSize(width: itemWidth, height: self.height)

        for (index, element) in self.elements.enumerated() {
            let offset = CGFloat(index) * (itemSize.width + self.offset)
            element.size = itemSize
            element.left =  offset
            element.centerOnY()
            element.makeRound()
        }
    }

    func update(to index: Int, with duration: TimeInterval) {

        // TODO: ADD DURATION FOR EACH TYPE
        guard let element = self.elements[safe: index] else {
            self.delegate.feedIndicator(self, didFinishProgressFor: index)
            return
        }

        element.animateProgress(with: duration) { [unowned self] in
            self.delegate.feedIndicator(self, didFinishProgressFor: index)
        }
    }

    func resetAllIndicators() {
        for (index, view) in self.elements.enumerated() {
            self.finishAnimator(at: index, shouldFinish: true)
            view.progressWidth = 0
            view.layoutNow()
        }
    }

    func pauseProgress(at index: Int) {
        guard let element = self.elements[safe: index] else { return }
        element.animator?.pauseAnimation()
    }

    func finishProgress(at index: Int, finishAnimator: Bool = false) {
        self.finishAnimator(at: index, shouldFinish: finishAnimator)
        self.delegate.feedIndicator(self, didFinishProgressFor: index)
    }

    private func finishAnimator(at index: Int, shouldFinish: Bool) {
        guard let element = self.elements[safe: index],
              let animator = element.animator,
              animator.state == .active else { return }

        animator.stopAnimation(false)
        if shouldFinish {
            animator.finishAnimation(at: .end)
        }
    }
}

private class IndicatorView: View {

    let progressView = View()
    var progressWidth: CGFloat = 0
    private(set) var animator: UIViewPropertyAnimator?

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .background2)
        self.addSubview(self.progressView)
        self.progressView.set(backgroundColor: .teal)
        self.progressView.showShadow(withOffset: 2, color: Color.teal.color)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.progressView.expandToSuperviewHeight()
        self.progressView.pin(.left)
        self.progressView.width = self.progressWidth
    }

    func animateProgress(with duration: TimeInterval, completion: CompletionOptional) {
        
        if let current = self.animator {
            if current.state == .active {
                current.stopAnimation(true)
                current.finishAnimation(at: .end)
            } else if current.state == .stopped {
                current.finishAnimation(at: .current)
            } else if current.isRunning {
                current.stopAnimation(true)
                current.finishAnimation(at: .end)
            }
        }

        self.animator = UIViewPropertyAnimator(duration: duration,
                                               curve: .linear,
                                               animations: {
            self.progressWidth = self.width
            self.layoutNow()
        })

        self.animator?.isInterruptible = true
        self.animator?.addCompletion({ (position) in
            guard position == .end else { return }
            completion?()
        })

        self.animator?.startAnimation()
    }
}
