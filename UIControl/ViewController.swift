//
//  ViewController.swift
//  UIControl
//
//  Created by 董知樾 on 2022/8/30.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ui_segm: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ui_segm.layer.cornerRadius = 16
//        ui_segm.layer.masksToBounds = true
//        ui_segm.layer.shadowPath = UIBezierPath(roundedRect: ui_segm.bounds, cornerRadius: 16).cgPath
        
        let segmentedControl = YYHSegmentedControl(titles: ["茶语", "评论", "回复"])
        segmentedControl.backgroundColor = UIColor(rgb: 0xF0F0F0)
        segmentedControl.layer.cornerRadius = 16
        segmentedControl.textFont = UIFont.boldSystemFont(ofSize: 16)
        segmentedControl.setTitleColor(UIColor(rgb: 0x333333), for: .selected)
        segmentedControl.setTitleColor(UIColor(rgb: 0xACACAC), for: .normal)
//        segmentedControl.setTitleColor(UIColor.orange, for: .disabled)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
//        segmentedControl.setEnabled(false, forSegmentAt: 1)
        
        
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: segmentedControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
     
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        view.backgroundColor = UIColor.black
        
        let slider = YYHVideoSlider()
        
        slider.setThumbColor(UIColor.white, for: .normal)
        slider.setThumbSize(CGSize.zero, for: .normal)
        slider.setBackgroundColor(UIColor(rgb: 0xF8F8F8), for: .normal)
        slider.setProgressColor(UIColor(rgb: 0xCCCCCC), for: .normal)
        
        slider.setThumbColor(UIColor.white, for: .touching)
        slider.setThumbSize(CGSize(width: 12, height: 12), for: .touching)
        slider.setBackgroundColor(UIColor(rgb: 0xCCCCCC), for: .touching)
        slider.setProgressColor(UIColor.white, for: .touching)
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.isHiddenThumbInNormal = true
        
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30),
            slider.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 60),
            slider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (t) in
            self?.progress += 1
            slider.value = self?.progress ?? 0
            if self?.progress ?? 0 >= 100 {
                t.invalidate()
            }
        }
//        timer?.fire()
    }

    private var timer: Timer?
    private var progress: Float = 0
    
    @objc private func segmentedControlValueChanged(_ control: YYHSegmentedControl) {
        print(control.selectedIndex)
    }
    @objc private func sliderValueChanged(_ slider: YYHVideoSlider) {
        progress = slider.value
        print(slider.value)
    }
}

