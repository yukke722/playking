//
//  ActingController.swift
//  playking
//
//  Created by yusuke hashimoto on 2017/12/28.
//  Copyright © 2017年 Yusuke Hashimoto. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos

class ActingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
  
  /* 画面共通 */
  let scWid: CGFloat = UIScreen.main.bounds.width
  let scHei: CGFloat = UIScreen.main.bounds.height
  
  /* 動画撮影 */
  var recording: Bool = false // 録画状態フラグ
  var myVideoOutput: AVCaptureMovieFileOutput! // ビデオのアウトプット
  var myVideoLayer: AVCaptureVideoPreviewLayer! // ビデオレイヤー
  var button: UIButton! // 撮影ボタン
  var outputURLs: [URL] = [] // 動画ファイル参照URL
  
  /* タイマー */
  let actingTime: Int = 3 // 演技時間
  var minuteCount: Int = 0
  var secondCount: Int = 0
  var count: Int = 0
  
  var timer : Timer!
  var timeLabel: UILabel! // タイマー表示
  var startTime:Double = 0.0 // 開始時刻
  var keyword = [String: String]() // keyword
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(keyword)
    
    if (false) { // simulater
      /* 動画撮影 */
      let session = AVCaptureSession() // セッションの作成
      let myImageOutput = AVCapturePhotoOutput() // 出力先の生成
      
      let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) // バックカメラの取得
      print(camera)
      let videoInput = try! AVCaptureDeviceInput.init(device: camera!)
      session.addInput(videoInput) // ビデオをセッションのInputに追加
      
      let mic = AVCaptureDevice.default(.builtInMicrophone, for: AVMediaType.audio, position: .unspecified) // マイク取得
      let audioInput = try! AVCaptureDeviceInput.init(device: mic!)
      session.addInput(audioInput) // オーディオをセッションに追加
      
      session.addOutput(myImageOutput) // セッションに追加
      myVideoOutput = AVCaptureMovieFileOutput() // 動画の保存
      session.addOutput(myVideoOutput) // ビデオ出力をOutputに追加
      
      // 動画を表示するレイヤーを生成
      myVideoLayer = AVCaptureVideoPreviewLayer.init(session: session)
      myVideoLayer?.frame = self.view.bounds // layerのサイズを変更できる？
      myVideoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
      self.view.layer.addSublayer(myVideoLayer!) // Viewに追加
      
      /* レイヤーを削除
       * https://goo.gl/K7Y8s2
       */
      
      
      // セッション開始.
      session.startRunning()
      
    } // simulater
    
    // ボタン作成
    button = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
    button.backgroundColor = .red
    button.layer.masksToBounds = true
    button.setTitle("START", for: .normal)
    button.layer.cornerRadius = 20.0
    button.layer.position = CGPoint(x: scWid/2, y: scHei-50)
    button.addTarget(self, action: #selector(ActingViewController.onTapButton), for: .touchUpInside)
    self.view.addSubview(button)
    
    // タイマーラベル作成
    timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    timeLabel.backgroundColor = UIColor.orange
    timeLabel.text = String(format: "%02d:00", actingTime)
    timeLabel.textColor = UIColor.white
    timeLabel.font = UIFont.boldSystemFont(ofSize: 24)
    timeLabel.textAlignment = NSTextAlignment.center
    timeLabel.layer.position = CGPoint(x: scWid/2, y: 200)
    self.view.addSubview(timeLabel)
  }
  
  
  @objc internal func onTapButton(sender: UIButton){
    if (self.recording) {
      stopTimer()
    } else {
      print("start")
      startTimer() // タイマー開始
      
      let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
      let filePath: String = path + "/test.mov"
      let fileURL: URL = URL(fileURLWithPath: filePath)
      outputURLs.append(fileURL)
      
      // 録画開始
      myVideoOutput.startRecording(to: fileURL, recordingDelegate: self)
      button.setTitle("STOP", for: .normal)
    }
    
    self.recording = !self.recording
  }
  
  
  
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
    print("start fileOutput")
    
    // ベースとなる動画のコンポジション作成
    let mixComposition : AVMutableComposition = AVMutableComposition()
    let compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    // 結合前の動画取得
    // 使う時に解除
    //    if let befPath: String = Bundle.main.path(forResource: "test01", ofType: "mov") {
    //      let befURL = URL(fileURLWithPath: befPath)
    //      outputURLs.insert(befURL, at: 0)
    //    }
    
    var videoStartTime: CMTime = kCMTimeZero
    for url in outputURLs {
      // 動画URLからアセットを生成
      let videoAsset: AVURLAsset = AVURLAsset(url: url, options: nil)
      
      // アセットからトラックを取得
      let videoTrack: AVAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
      let audioTrack: AVAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
      
      
      // コンポジションの設定
      // https://goo.gl/KwdRCN
      
      try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                                 of: videoTrack,
                                                 at: videoStartTime)
      compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
      
      try! compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                                 of: audioTrack,
                                                 at: videoStartTime)
      
      videoStartTime = CMTimeAdd(videoStartTime, videoAsset.duration)
      
      // 動画のサイズを取得
      //      let videoSize: CGSize = videoTrack.naturalSize
      //    var isPortrait: Bool = false
      
      // ビデオを縦横方向 - 横にしたいのでコメントアウト
      //    if myVideoLayer.connection?.videoOrientation == .portrait {
      //      isPortrait = true
      //      videoSize = CGSize(width: videoSize.height, height: videoSize.width)
      //    }
      
      /* ロゴのCALayerの作成
       * timeLabelを載せて合成する
       */
      //    let logoImage: UIImage = UIImage(named: "logologo.png")!
      //      let logoLayer: CALayer = CALayer()
      //    logoLayer.frame = CGRect(x: scWid/2, y: scHei-50, width: 200*2, height: 50*2)
      //    logoLayer.backgroundColor = UIColor.orange.cgColor
      //      logoLayer.contents = timeLabel.layer
      //    logoLayer.opacity = 0.9
      
      // 親レイヤーを作成
      //      let parentLayer: CALayer = CALayer()
      //      let videoLayer: CALayer = CALayer()
      //      parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
      //      videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
      //      parentLayer.addSublayer(videoLayer)
      //      parentLayer.addSublayer(logoLayer)
      //      parentLayer.addSublayer(timeLabel.layer)
      
      // 合成用コンポジション作成
      //      var videoComp: AVMutableVideoComposition = AVMutableVideoComposition()
      //      videoComp.renderSize = videoSize
      //      videoComp.frameDuration = CMTimeMake(1, 30)
      //      videoComp.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
      
      // インストラクション作成
      //      var instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
      //      instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
      //      var layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
      //      instruction.layerInstructions = [layerInstruction]
      
      // 縦方向で撮影なら90度回転させる
      //    if isPortrait {
      //      let FirstAssetScaleFactor:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0);
      //      layerInstruction.setTransform(videoTrack.preferredTransform.concatenating(FirstAssetScaleFactor), at: kCMTimeZero)
      //    }
      
      // インストラクションを合成用コンポジションに設定
      //      videoComp.instructions = [instruction]
    } // {}の範囲と１ファイルにまとめることが課題
    
    // 動画のコンポジションをベースにAVAssetExportを生成
    let assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
    // 合成用コンポジションを設定
    //    assetExport?.videoComposition = videoComp
    
    // エクスポートファイルの設定
    let videoName: String = "test.mov" // ユーザーに入力させる
    let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let exportPath: String = documentPath + "/" + videoName
    let exportUrl: URL = URL(fileURLWithPath: exportPath)
    assetExport?.outputFileType = AVFileType.mov
    assetExport?.outputURL = exportUrl
    assetExport?.shouldOptimizeForNetworkUse = true
    
    
    // ファイルが存在している場合は削除
    if FileManager.default.fileExists(atPath: exportPath) {
      try! FileManager.default.removeItem(atPath: exportPath)
    }
    
    // エクスポート実行
    assetExport?.exportAsynchronously(completionHandler: {() -> Void in
      
      // 端末に保存
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportUrl)
      }, completionHandler: {(success, err) -> Void in
        var message = ""
        if success {
          message = "保存しました"
        } else {
          message = "保存に失敗しました"
        }
        
        // アラートを表示
        DispatchQueue.main.async(execute: {
          let alert = UIAlertController.init(title: "保存", message: message, preferredStyle: UIAlertControllerStyle.alert)
          let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            self.button.setTitle("START", for: .normal)
            self.button.isEnabled = true
            self.button.isHidden = false
          }
          alert.addAction(action)
          self.present(alert, animated: true, completion: nil)
        });
      })
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // タイマースタート
  func startTimer() {
    print("startTimer")
    minuteCount = actingTime
    count = actingTime * 60
    
    let str = String(format: "%02d:%02d", minuteCount, secondCount)
    timeLabel.text = str
    print("str: \(str)")
    
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(ActingViewController.updateLabel),
      userInfo: nil,
      repeats: true
    )
  }
  
  @objc func updateLabel() {
    print("updateLabel")
    count -= 1 // 起動までに１秒かかるため
    
    minuteCount = count / 60
    secondCount = count % 60
    
    let str = String(format: "%02d:%02d", minuteCount, secondCount)
    print(str)
    timeLabel.text = str
    
    // 残り0秒になった時の処理
    if count == 0 {
      stopTimer()
    }
    
  }
  
  func stopTimer() {
    print("stop timer")
    timer.invalidate()
    //      let alert = UIAlertController(title: "完了", message: "経ちました。", preferredStyle: .alert)
    //      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    //      alert.addAction(okAction)
    //      present(alert, animated: true, completion: nil)
    
    // 撮影を止める
    myVideoOutput.stopRecording()
    print("stop recording")
    button.isEnabled = false
    button.isHidden = true
  }
  
}

