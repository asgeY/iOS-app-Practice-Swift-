//
//  CustomThumbView.swift
//  Backpack
//
//  Created by Anik on 20/4/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//

import UIKit

final class CustomThumbView: UIView {
    
    fileprivate(set) var thumbImageView = UIImageView(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.thumbImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(self.thumbImageView)
        
    }
    
    
}

extension CustomThumbView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.thumbImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.thumbImageView.layer.cornerRadius = self.layer.cornerRadius
        self.thumbImageView.clipsToBounds = self.clipsToBounds
        
        
    }
    
}
