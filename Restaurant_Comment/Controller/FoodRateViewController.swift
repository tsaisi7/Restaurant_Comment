//
//  FoodRateViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/19.
//

import UIKit

class FoodRateViewController: UIViewController {
    
    @IBOutlet var rateButtons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        for rateButton in rateButtons{
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0.0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        var delay: Double = 0.2
        for rateButton in rateButtons{
            UIView.animate(withDuration: 0.7, delay: delay, options: [], animations: {
                rateButton.alpha = 1.0
                rateButton.transform = .identity
            }, completion: nil)
            delay += 0.1
        }
    }
}
