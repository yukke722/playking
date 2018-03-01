//
//  AnswerButton.swift
//  playking
//
//  Created by yusuke hashimoto on 2018/02/22.
//  Copyright © 2018年 Yusuke Hashimoto. All rights reserved.
//

import UIKit
import AudioToolbox


class AnswerButton: UIButton {
  
  var selectView: UIView! = nil
  var color: UIColor?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  init(frame: CGRect, color: UIColor, label: String, position: CGPoint) {
    super.init(frame: frame)
    self.color = color
    
    self.setTitle(label, for: .normal)
    self.backgroundColor = .gray
    self.setTitleColor(color, for: .normal)
    self.layer.borderColor = color.cgColor
    self.layer.masksToBounds = true
    self.layer.cornerRadius = 20.0
    self.layer.position = position
    self.isEnabled = false
    
    selectView = UIView(frame: self.bounds)
    selectView.backgroundColor = UIColor.black
    selectView.alpha = 0.0
    self.addSubview(selectView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    selectView.frame = self.bounds
  }
  
  // タッチ開始
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in
      
      self.selectView.alpha = 0.5
      
    }, completion: {(finished: Bool) -> Void in
      self.backgroundColor = self.color!
      self.setTitleColor(.white, for: .normal)
      self.isEnabled = false
      
      self.playSound()
    })
  }
  
  // タッチ終了
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in
      
      self.selectView.alpha = 0.0
      
    }, completion: {(finished: Bool) -> Void in
    })
    
    
  }
  
  func playSound() {
    //    let bgmPath: String = Bundle.main.path(forResource: musicType, ofType: "mp3")!
    //    let bgmURL: URL = URL(fileURLWithPath: bgmPath)
    //
    //    do {
    //      audioPlayerInstance = try AVAudioPlayer(contentsOf: bgmURL, fileTypeHint: nil)
    //    } catch {
    //      print("AVAudioPlayerインスタンス作成失敗")
    //    }
    //    // バッファに保持していつでも再生できるようにする
    //    audioPlayerInstance.prepareToPlay()
    //
    //    audioPlayerInstance.volume = 1.0 // volume調整 0~1
    //    audioPlayerInstance.play()
    //    print("playSound")
    
    var soundIdRing: SystemSoundID = 0
    let soundUrl = NSURL(fileURLWithPath: "/System/Library/Audio/UISounds/new-mail.caf")
    AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
    AudioServicesPlaySystemSound(soundIdRing)
  }
}
