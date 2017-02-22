//
//  BBEditAudioControlView.swift
//  BoBo
//
//  Created by alimysoyang on 16/12/20.
//  Copyright © 2016年 bobo. All rights reserved.
//

import Foundation

@objc protocol BBEditAudioControlViewDelegate
{
    func editAudioControlView(videoAudioVolumn:Float, didValueChanged mixAudioVolumn:Float);
}

// 编辑视频中的声音控制
class BBEditAudioControlView: UIView 
{
    // MARK: - properties
    weak var delegate:BBEditAudioControlViewDelegate?;
    
    var volumn:Float {
        get {
            return self.audioSlider.value;
        }
    }
    
    fileprivate lazy var lbVideoAudio:UILabel = {
        let label:UILabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 36.0));
        label.text = "原声";
        label.font = BBHelper.p14;
        label.textColor = UIColor.blue;
        label.textAlignment = .center;
        return label;
    }();
    
    fileprivate lazy var lbMixAudio:UILabel = { [unowned self] in
        let label:UILabel = UILabel(frame: CGRect(x: self.frame.size.width - 60.0, y: 0.0, width: 60.0, height: 36.0));
        label.text = "混音";
        label.font = BBHelper.p14;
        label.textColor = UIColor.red;
        label.textAlignment = .center;
        return label;
    }();
    
    fileprivate lazy var audioSlider:UISlider = {
        let slider:UISlider = UISlider(frame: CGRect(x: 60.0, y: 0.0, width: self.frame.size.width - 120.0, height: 36.0));
        slider.maximumValue = 1.0;
        slider.minimumValue = 0.0;
        slider.value = 0.0;
        slider.minimumTrackTintColor = UIColor.blue;
        slider.maximumTrackTintColor = UIColor.red;
        slider.addTarget(self, action: #selector(BBEditAudioControlView.eventSliderValueChanged(_:)), for: .valueChanged);
        return slider;
    }();

    // MARK: - life cycle
    override init(frame:CGRect)
    {
		super.init(frame:frame);
        
        self.initViews();
    }
	
    required init?(coder aDecoder:NSCoder)
    {
		super.init(coder:aDecoder);
    }

    deinit
    {
        self.delegate = nil;
    }

    // MARK: - public methods
    internal func updateVolumn(volumn:Float)
    {
        self.audioSlider.value = volumn;
    }
    
    // MARK: - event response
    internal func eventSliderValueChanged(_ sender:UISlider)
    {
        let vaVolumn:Float = sender.value;
        let mixVolumn:Float = 1.0 - vaVolumn;
        guard let _ = self.delegate?.editAudioControlView(videoAudioVolumn: vaVolumn, didValueChanged: mixVolumn) else {
            return;
        }
    }
    
    // MARK: - private methods
    fileprivate func initViews()
    {
        self.backgroundColor = UIColor.white;
        self.addSubview(self.lbVideoAudio);
        self.addSubview(self.audioSlider);
        self.addSubview(self.lbMixAudio);
    }
}
