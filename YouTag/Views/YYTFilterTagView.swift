//
//  YYTFilterTagView.swift
//  YouTag
//
//  Created by Youstanzr on 3/26/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit

class YYTFilterTagView: YYTTagView {
    
    init(frame: CGRect, tagsList: NSMutableArray, isDeleteEnabled: Bool) {
        super.init(frame: frame, tagsList: tagsList, isAddEnabled: false, isMultiSelection: false, isDeleteEnabled: isDeleteEnabled, suggestionDataSource: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getImageForType(_ type: String) -> UIImage {
        switch type {
            case "tags":
                return UIImage(named: "tag")!
            case "artists":
                return UIImage(named: "artist")!
            case "album":
                return UIImage(named: "album")!
            case "releaseYearRange":
                return UIImage(named: "calendar")!
            case "releaseYear":
                return UIImage(named: "calendar")!
            case "duration":
                return UIImage(named: "duration")!
            default:
                return UIImage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! YYTTagCell
        tagCell.textField.delegate = self
        if isAddEnabled && indexPath.row == 0 {
            tagCell.backgroundColor = GraphicColors.green
            tagCell.layer.borderColor = GraphicColors.darkGreen.cgColor
            tagCell.textField.textColor = .white
            tagCell.textField.placeholder = addTagPlaceHolder
            tagCell.titleLabel.textColor = .white
            tagCell.titleLabel.text = "+"
            tagCell.titleLabel.font = UIFont.init(name: "DINCondensed-Bold", size: 24)
            // Make the textField first responder when tapping "+"
            tagCell.textField.becomeFirstResponder()
        } else {
            tagCell.image = UIImage(named: "list")
            tagCell.backgroundColor = .clear
            tagCell.titleLabel.textColor = .darkGray
            tagCell.textField.textColor = .darkGray
            tagCell.titleLabel.font = UIFont.init(name: "DINCondensed-Bold", size: 16)
            tagCell.layer.borderColor = GraphicColors.orange.cgColor
            
            let index = isAddEnabled ? indexPath.row - 1 : indexPath.row
            let tuple = tagsList.object(at: index) as? NSMutableArray
            tagCell.titleLabel.text = tuple?.object(at: 1) as? String
            tagCell.desc = tuple?.object(at: 0) as? String ?? ""
            tagCell.image = getImageForType(tagCell.desc)
        }
        return tagCell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isAddEnabled && indexPath.row == 0 {
            let cellSize = isEditingEnabled ? CGSize(width: 90, height: 32):CGSize(width: 30, height: 32)
            isEditingEnabled = false
            return cellSize
        }
        let index = isAddEnabled ? indexPath.row - 1 : indexPath.row
        let tuple = tagsList.object(at: index) as? NSMutableArray
        var titleWidth = (tuple?.object(at: 1) as? String)!.estimateSizeWidth(font: UIFont.init(name: "DINCondensed-Bold", size: 16)!, padding: 5.0)
        titleWidth = titleWidth > collectionView.frame.width * 0.475 ? collectionView.frame.width * 0.475 : titleWidth
        return CGSize(width: titleWidth + 34, height: 32)
    }
    
    override func reloadData() {
        super.reloadData()
        print("✅ YYTFilterTagView.reloadData() triggered with \(tagsList.count) tags")
    }

    // UITextFieldDelegate method to handle adding a new tag from the input field
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let input = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else {
            return false
        }
        let type = "tags" // You may modify this logic if dynamic type detection is required
        let newTag = NSMutableArray(array: [type, input])
        self.tagsList.add(newTag)
        textField.text = ""
        self.reloadData()
        return true
    }
}
