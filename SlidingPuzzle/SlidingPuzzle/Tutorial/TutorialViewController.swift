//
//  TutorialViewController.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 11/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//


import Foundation
import UIKit
import paper_onboarding
import SwiftyGif

final class TutorialViewController: UIViewController {
    
    @IBOutlet weak var onboardingView: PaperOnboarding!
    
    let pagesNumber = 1
    
    let titles = ["How to play?"]
    
    let descriptions = ["Slide the tiles in order to arrange them in an ascending order.\n\n Start with the '1' in the top left corner."]

    let images = [UIImage(gifName: "tutorial")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setHasSeenTutorial()
        onboardingView.currentIndex(0, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension TutorialViewController: PaperOnboardingDelegate {
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        if let imageView = item.imageView as UIImageView? {
            imageView.setGifImage(images[index])
            imageView.startAnimatingGif()
        }
    }
}

extension TutorialViewController: PaperOnboardingDataSource {
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
         return OnboardingItemInfo(informationImage: images[index],
                                   title: titles[index],
                                   description: descriptions[index],
                                   pageIcon: UIImage(),
                                   color: .white,
                                   titleColor: UIColor(red: 23/255, green: 23/255, blue: 56/255, alpha: 1.0),
                                   descriptionColor: UIColor(red: 86/255, green: 86/255, blue: 110/255, alpha: 1.0),
                                   titleFont: UIFont.boldSystemFont(ofSize: 16),
                                   descriptionFont: UIFont.systemFont(ofSize: 15))

    }
    
    func onboardingItemsCount() -> Int {
        return pagesNumber
    }
}

