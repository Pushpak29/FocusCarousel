//
//  CarouselView.swift
//  Atlys
//
//  Created by Pushpak Athawale on 25/08/24.
//

import UIKit

class CarouselView: UIView, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var imageViews = [UIImageView]()
    private var images: [UIImage] = []
    
    init(frame: CGRect, images: [UIImage]) {
        self.images = images
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupScrollView()
        setupImageViews()
        setupPageControl()
        scrollToInitialPosition()
    }
    
    private func setupScrollView() {
        scrollView.frame = bounds
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.addSubview(scrollView)
    }
    
    private func setupImageViews() {
        guard !images.isEmpty else { return }
        
        let imageWidth: CGFloat = 0.6*(frame.height)
        let imageHeight: CGFloat = imageWidth
        
        scrollView.contentSize = CGSize(width: imageWidth * CGFloat(images.count) + frame.width - imageWidth, height: frame.height)
        
        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            
            let xPosition = CGFloat(index) * imageWidth + frame.width / 2 - imageWidth / 2
            imageView.frame = CGRect(x: xPosition, y: 0, width: imageWidth, height: imageHeight)
            
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
        
        updateImageViewSizes()
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = images.count
        pageControl.currentPage = images.count / 2
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func scrollToInitialPosition() {
        let initialOffsetX = (scrollView.contentSize.width - scrollView.frame.width) / 2
        scrollView.setContentOffset(CGPoint(x: initialOffsetX, y: 0), animated: false)
    }
    
    private func updateImageViewSizes() {
        let centerX = scrollView.contentOffset.x + scrollView.frame.width / 2
        var closestImageView: UIImageView?
        var smallestDistance: CGFloat = .greatestFiniteMagnitude
        
        for imageView in imageViews {
            let distanceFromCenter = abs(imageView.center.x - centerX)
            let scale = max(1.0, 1.3 - distanceFromCenter / scrollView.frame.width)
            
            // Apply scaling transform while keeping the Y-axis center fixed
            let currentCenter = imageView.center
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            imageView.center = CGPoint(x: currentCenter.x, y: scrollView.frame.height / 2)
            
            if distanceFromCenter < smallestDistance {
                smallestDistance = distanceFromCenter
                closestImageView = imageView
            }
        }
        
        // Bring the closest image view (the center one) to the front
        if let centerImageView = closestImageView {
            scrollView.bringSubviewToFront(centerImageView)
        }
    }
    
    private func updatePageControl(for currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    // MARK: - Snapping and Paging Behavior
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = scrollView.frame.width / 2
        let targetXContentOffset = targetContentOffset.pointee.x
        let targetPage = Int((targetXContentOffset + pageWidth / 2) / pageWidth)
        
        let adjustedTargetX = CGFloat(targetPage) * pageWidth
        
        targetContentOffset.pointee = CGPoint(x: adjustedTargetX, y: 0)
        
        snapToCenter(targetOffset: targetContentOffset.pointee)
    }
    
    private func snapToCenter(targetOffset: CGPoint) {
        let centerX = targetOffset.x + scrollView.frame.width / 2
        var closestImageView: UIImageView?
        var smallestDistance: CGFloat = .greatestFiniteMagnitude
        var currentPage = 0
        
        for (index, imageView) in imageViews.enumerated() {
            let distance = abs(imageView.center.x - centerX)
            if distance < smallestDistance {
                smallestDistance = distance
                closestImageView = imageView
                currentPage = index
            }
        }
        
        if let targetImageView = closestImageView {
            let targetOffsetX = targetImageView.center.x - scrollView.frame.width / 2
            scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
            updatePageControl(for: currentPage) // Update page control after snapping
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateImageViewSizes()
    }
}


