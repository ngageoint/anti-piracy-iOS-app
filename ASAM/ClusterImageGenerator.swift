//
//  ClusterImageGenerator.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 4/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

struct ClusterImageGenerator {

    static func textToImage(drawText: NSString, inImage: UIImage)->UIImage{
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont.systemFontOfSize(12.0)
        
        
        let textFontAttributes = [NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor]
        
        //Put the image into a rectangle as large as the original image.
        let imageRectangle: CGRect = CGRectMake(0, 0, inImage.size.width, inImage.size.height)
        inImage.drawInRect(imageRectangle)
        
        //center text
        let size: CGSize = drawText.sizeWithAttributes(textFontAttributes)
        let rect: CGRect = CGRectMake(imageRectangle.origin.x + (imageRectangle.size.width - size.width)/2.0,
            imageRectangle.origin.y + (imageRectangle.size.height - size.height)/2.0,
            imageRectangle.size.width, imageRectangle.size.height)
        
        //Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
}