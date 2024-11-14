//
//  ScrollIndicatorView.swift
//
//  Created by 張啟裕 on 2024/11/14.
//

import UIKit

extension UIScrollView {
    /// 將小 Indicator 加到自己 superview 上
    /// 請於有 superview 的時候執行
    func addSmallIndicator() {
        guard let superview else { return }
        let view = ScrollIndicatorView(scrollView: self)
        view.backgroundColor = .lightGray
        superview.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 5),
            view.widthAnchor.constraint(equalToConstant: 50),
            view.topAnchor.constraint(equalTo: bottomAnchor, constant: 4),
            view.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

class ScrollIndicatorView: UIView {
    
    private(set) weak var scrollView: UIScrollView?
    
    private(set) lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = indicatorColor
        addSubview(view)
        return view
    }()
    
    private var indicatorWidth: CGFloat {
        if let contentWidth = scrollView?.contentSize.width,
           let frameWidth = scrollView?.frame.width {
            return frameWidth / contentWidth * frame.width
        }
        return 0
    }
    
    public var indicatorColor: UIColor = .red {
        willSet {
            indicatorView.backgroundColor = indicatorColor
        }
    }
    
    private var observation: NSKeyValueObservation?
    
    init(frame: CGRect = .zero, scrollView: UIScrollView) {
        super.init(frame: frame)
        self.scrollView = scrollView
        observation = scrollView.observe(
            \.contentOffset,
             options: [.new, .initial]
        ){
            [weak self] _, _ in
            self?.updateIndicatorShown()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.layer.cornerRadius = frame.height / 2
        layer.cornerRadius = frame.height / 2
    }
    
    private func updateIndicatorShown() {
        
        guard let scrollView = scrollView else { return }
        
        let indicatorSpace = frame.width - indicatorWidth
        let contentDistance = scrollView.contentSize.width
        let visibleDistance = scrollView.frame.width
        let contentOffset = scrollView.contentOffset.x
        
        isHidden = !(indicatorSpace > 0 && contentDistance > visibleDistance)
        guard !isHidden else { return }
        
        let scrollViewWithIndicatorRatio = (contentDistance - visibleDistance) / indicatorSpace
        var x = contentOffset / scrollViewWithIndicatorRatio
        x = max(0, min(x, indicatorSpace))
        
        indicatorView.frame = CGRect(
            x: x,
            y: 0,
            width: indicatorWidth,
            height: frame.height
        )
    }
    
    deinit {
        observation?.invalidate()
    }
}
