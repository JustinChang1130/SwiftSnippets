//
//  NibView.swift
//  SCM_MOMOSHOP
//
//  Created by 張啟裕 on 2022/12/12.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit

class NibView: UIView {
    private(set) var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }

    private func xibSetup() {
        guard let view = Self.loadNib(owner: self) else { return }
        self.view = view
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private static func loadNib(owner: Any) -> UIView? {
        let nibName = String(describing: self)
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: owner, options: nil).first as? UIView
    }
}
