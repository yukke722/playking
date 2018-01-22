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

class ActingController: UIViewController, AVCaptureFileOutputRecordingDelegate {
  
  /* 画面共通 */
  let scWid: CGFloat = UIScreen.main.bounds.width
  let scHei: CGFloat = UIScreen.main.bounds.height
  
  /* 動画撮影 */
  var recording: Bool = false // 録画状態フラグ
  var myVideoOutput: AVCaptureMovieFileOutput! // ビデオのアウトプット
  var myVideoLayer: AVCaptureVideoPreviewLayer! // ビデオレイヤー
  var button: UIButton! // 撮影ボタン
  
  /* タイマー */
  var actingTime : Int = 3 // 演技時間
  var timer : Timer!
  var timeLabel: UILabel! // タイマー表示
  var startTime:Double = 0.0 // 開始時刻
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* 動画撮影 */
    let session = AVCaptureSession() // セッションの作成
    let myImageOutput = AVCapturePhotoOutput() // 出力先の生成
    
    let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) // バックカメラの取得
    let videoInput = try! AVCaptureDeviceInput.init(device: camera!)
    session.addInput(videoInput) // ビデオをセッションのInputに追加
    
    let mic = AVCaptureDevice.default(.builtInMicrophone, for: AVMediaType.audio, position: .unspecified) // マイク取得
    let audioInput = try! AVCaptureDeviceInput.init(device: mic!)
    session.addInput(audioInput) // オーディオをセッションに追加
    
    session.addOutput(myImageOutput) // セッションに追加
    myVideoOutput = AVCaptureMovieFileOutput() // 動画の保存
    session.addOutput(myVideoOutput) // ビデオ出力をOutputに追加
    
    // 画像を表示するレイヤーを生成
    myVideoLayer = AVCaptureVideoPreviewLayer.init(session: session)
    myVideoLayer?.frame = self.view.bounds
    myVideoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    self.view.layer.addSublayer(myVideoLayer!) // Viewに追加
    
    // セッション開始.
    session.startRunning()
    
    // ボタン作成
    button = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
    button.backgroundColor = .red
    button.layer.masksToBounds = true
    button.setTitle("START", for: .normal)
    button.layer.cornerRadius = 20.0
    button.layer.position = CGPoint(x: scWid/2, y: scHei-50)
    button.addTarget(self, action: #selector(ActingController.onTapButton), for: .touchUpInside)
    self.view.addSubview(button)
    
    // タイマーラベル作成
    timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    timeLabel.backgroundColor = UIColor.orange
    timeLabel.text = String(format: "00:%02d", actingTime)
    timeLabel.textColor = UIColor.white
    timeLabel.font = UIFont.boldSystemFont(ofSize: 24)
    timeLabel.textAlignment = NSTextAlignment.center
    timeLabel.layer.position = CGPoint(x: scWid/2, y: 200)
    self.view.addSubview(timeLabel)
  }
  
  
  @objc internal func onTapButton(sender: UIButton){
    if (self.recording) {
      myVideoOutput.stopRecording()
      print("stop recording")
      button.isEnabled = false
      button.isHidden = true
    } else {
      print("start")
      startTimer() // タイマー開始
      
      let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
      let filePath: String = path + "/test.mov"
      let fileURL: URL = URL(fileURLWithPath: filePath)
      
      // 録画開始
      myVideoOutput.startRecording(to: fileURL, recordingDelegate: self)
      button.setTitle("STOP", for: .normal)
    }
    
    self.recording = !self.recording
  }
  
  
  
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
    print("start fileOutput")
    // 動画URLからアセットを生成
    let videoAsset: AVURLAsset = AVURLAsset(url: outputFileURL, options: nil)
    
    // ベースとなる動画のコンポジション作成
    let mixComposition : AVMutableComposition = AVMutableComposition()
    let compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    // アセットからトラックを取得
    let videoTrack: AVAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
    let audioTrack: AVAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
    
    
    // コンポジションの設定
    try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoTrack, at: kCMTimeZero)
    compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
    
    try! compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: audioTrack, at: kCMTimeZero)
    
    // 動画のサイズを取得
    let videoSize: CGSize = videoTrack.naturalSize
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
    let logoLayer: CALayer = CALayer()
//    logoLayer.frame = CGRect(x: scWid/2, y: scHei-50, width: 200*2, height: 50*2)
//    logoLayer.backgroundColor = UIColor.orange.cgColor
    logoLayer.contents = timeLabel.layer
//    logoLayer.opacity = 0.9
    
    // 親レイヤーを作成
    let parentLayer: CALayer = CALayer()
    let videoLayer: CALayer = CALayer()
    parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
    videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
    parentLayer.addSublayer(videoLayer)
    parentLayer.addSublayer(logoLayer)
    parentLayer.addSublayer(timeLabel.layer)

    
    // 合成用コンポジション作成
    let videoComp: AVMutableVideoComposition = AVMutableVideoComposition()
    videoComp.renderSize = videoSize
    videoComp.frameDuration = CMTimeMake(1, 30)
    videoComp.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    
    // インストラクション作成
    let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
    let layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
    instruction.layerInstructions = [layerInstruction]
    
    // 縦方向で撮影なら90度回転させる
//    if isPortrait {
//      let FirstAssetScaleFactor:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0);
//      layerInstruction.setTransform(videoTrack.preferredTransform.concatenating(FirstAssetScaleFactor), at: kCMTimeZero)
//    }
    
    // インストラクションを合成用コンポジションに設定
    videoComp.instructions = [instruction]
    
    // 動画のコンポジションをベースにAVAssetExportを生成
    let assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
    // 合成用コンポジションを設定
    assetExport?.videoComposition = videoComp
    
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
    startTime = Date().timeIntervalSince1970
    print("startTime: \(actingTime)")
    let str = String(format: "00:%02d", actingTime)
    print("str: \(str)")

    // 別フォーマットの書き方
//    let now = NSDate()
//    let formatter = DateFormatter()
//    formatter.dateFormat = "mm:ss"
//    let string = formatter.string(from: now as Date)
//    print(string)
    
    timeLabel.text = str
    
    timer = Timer.scheduledTimer(
      timeInterval: 1.0, target: self,
      selector: #selector(ActingController.updateLabel),
      userInfo: nil,
      repeats: true
    )
  }
  
  @objc func updateLabel() {
    print("updateLabel")
    let elapsedTime = Date().timeIntervalSince1970 - startTime
    let flooredErapsedTime = Int(floor(elapsedTime))
    let leftTime = Int(actingTime) - flooredErapsedTime
    let displayString = NSString(format: "00:%02d", leftTime) as String
    timeLabel.text = displayString
    
    // 残り0秒になった時の処理
    if leftTime == 0 {
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
  
}

