//
//  BottomSheetTransferable.swift
//  DJCoreApp
//
//  Created by 張啟裕 on 2025/9/1.
//  Copyright © 2025 SysJust. All rights reserved.
//

import UIKit

/// UIView conform 這個 protocol 就可以有良好 UI UX 的半螢幕 present show 方法，具有點擊陰影處關閉畫面及陰影處向下滑動關閉功能
/// - 要注意該 view present 高度會是 min(view 自身高度, 螢幕高度 * 0.7)
protocol BottomSheetTransferable: UIView {
    /// 會幫你產生好不需要實作該屬性，將用於 show 方法中 transitioningDelegate
    var halfScreenTransitioning: HalfScreenTransitioningDelegate { get }
    /// 畫面左上角右上角 CornerRadius 預設 16
    var sheetCornerRadius: CGFloat? { get }
    /// handler 顏色
    var sheetHandlerColor: UIColor? { get }
}

extension BottomSheetTransferable {
    func show() {
        layer.cornerRadius = sheetCornerRadius ?? 0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        
        let vc = UIViewController()
        vc.view.addSubview(self)
        let view = subviews.first { $0.backgroundColor != nil }
        vc.view.backgroundColor = view?.backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: vc.view.topAnchor),
            bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor),
            leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        ])
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = halfScreenTransitioning
        UIViewController.currentDisplayVC?.present(vc, animated: true)
    }
    
    func dismiss(completion: (()->Void)? = nil) {
        viewController?.dismiss(animated: true, completion: completion)
    }
}

private struct BottomSheetTransferableAssociatedKeys {
    static var transitioning = UInt8()
}

extension UIView {
    var sheetCornerRadius: CGFloat? {
        16
    }
    
    var sheetHandlerColor: UIColor? {
        .systemGray3
    }
    
    var halfScreenTransitioning: HalfScreenTransitioningDelegate {
        get {
            if let result = objc_getAssociatedObject(self, &BottomSheetTransferableAssociatedKeys.transitioning) as? HalfScreenTransitioningDelegate {
                return result
            }
            
            let delegate = HalfScreenTransitioningDelegate()
            objc_setAssociatedObject(self, &BottomSheetTransferableAssociatedKeys.transitioning, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return delegate
        }
    }
}

class HalfScreenTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        HalfScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class HalfScreenPresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    
    private let maxAlpha: CGFloat = 0.6
    
    private let handlerSize = CGSize(width: 40, height: 6)
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = targetView?.sheetHandlerColor ?? .white
        view.layer.cornerRadius = handlerSize.height / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var targetView: BottomSheetTransferable? = {
        presentedView?.containBottomSheetTransferableView
    }()
    
    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        // 點擊陰影區關閉
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
        
        // 拖曳陰影區關閉
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dimmingViewPanned(_:)))
        dimmingView.addGestureRecognizer(panGesture)
        
        presentedView?.layer.cornerRadius = targetView?.sheetCornerRadius ?? 0
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView else { return }
        
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        
        presentedViewController.view.clipsToBounds = false
        presentedViewController.view.addSubview(handleView)
        NSLayoutConstraint.activate([
            handleView.bottomAnchor.constraint(equalTo: presentedViewController.view.topAnchor, constant: -8),
            handleView.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: handlerSize.width),
            handleView.heightAnchor.constraint(equalToConstant: handlerSize.height)
        ])
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { fff in
            self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(self.maxAlpha)
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        
        presentedViewController.view.layoutIfNeeded()
        let targetHeight = presentedViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let maxHeight = containerView.bounds.height * 0.7
        let finalHeight = min(targetHeight, maxHeight)
        
        return CGRect(
            x: 0,
            y: containerView.bounds.height - finalHeight,
            width: containerView.bounds.width,
            height: finalHeight
        )
    }
    
    @objc private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true)
    }
    
    @objc private func dimmingViewPanned(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView else { return }
        let translation = gesture.translation(in: dimmingView)
        
        switch gesture.state {
        case .changed:
            let offsetY = max(translation.y, 0)
            presentedView.transform = CGAffineTransform(translationX: 0, y: offsetY)
            
            let progress = max(0, presentedView.frame.size.height - offsetY) / presentedView.frame.size.height
            let alpha = progress * self.maxAlpha
            self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: dimmingView).y
            if translation.y > 100 || velocity > 1000 {
                presentedViewController.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(self.maxAlpha)
                    presentedView.transform = .identity
                }
            }
        default:
            break
        }
    }
}

fileprivate extension UIView {
    var containBottomSheetTransferableView: BottomSheetTransferable? {
        for subview in subviews {
            if let found = subview as? BottomSheetTransferable {
                return found
            }
        }
        return nil
    }
}

extension UIView {
    /// 取得當前所在的 ViewController
    /// Note: 該屬性遍歷響應者鏈，這可能需要 O(n) 的時間，
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

extension UIViewController {
    
    /// 取得當前顯示  viewController
    static var currentDisplayVC: UIViewController? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first { $0 is UIWindowScene } as? UIWindowScene
            window = scene?.windows.first { $0.isKeyWindow }
        } else {
            window = UIApplication.shared.keyWindow
        }
        
        return window?.rootViewController?.topMostViewController
    }
    
    // 當前最上層 ViewController
    var topMostViewController: UIViewController {
        
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        
        return self
    }
}
