//
//  WChoiceController.swift
//  playking
//
//  Created by yusuke hashimoto on 2017/12/28.
//  Copyright © 2017年 Yusuke Hashimoto. All rights reserved.
//

import Foundation
import UIKit

class WChoiceController: UIViewController {
  
  let whens: [String] = ["卒業式", "誕生日", "正月"]
  let whos: [String] = ["親友", "店員", "夫婦"]
  let wheres: [String] = ["交番", "駅", "会社"]
  let whats: [String] = ["告白", "出産", "結婚"]
  let wills: [String] = ["ハイタッチ", "万歳", "頭を下げる"]
  let themes: [String] = ["男と女", "出会いと別れ"]
  var keyword = [String: String]()
  
  @IBOutlet weak var themeLabel: UILabel!
  @IBOutlet weak var willLabel: UILabel!
  
  override func viewDidLoad() {
    setKeyword()
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showKeyword(_ sender: UIButton) {
    /* set keyword */
    var title: String!
    var msg: String!
    
    switch sender.tag {
    case 0:
      title = "WHEN"
      msg = keyword["when"]
    case 1:
      title = "WHERE"
      msg = keyword["where"]
    case 2:
      title = "WHO"
      msg = keyword["who"]
    case 3:
      title = "WHAT"
      msg = keyword["what"]
    default:break
    }
    
    /* show keyword*/
    let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
      print("Hello")
    }
    alertController.addAction(okAction)
    present(alertController,animated: true,completion: nil)
  }
  
  
  
  
  /* Set keyword */
  func setKeyword() {
    print("start")
    
    keyword.removeAll()
    keyword["when"] = whens[(Int)(arc4random_uniform(UInt32(whens.count)))]
    keyword["who"] = whos[(Int)(arc4random_uniform(UInt32(whos.count)))]
    keyword["where"] = wheres[(Int)(arc4random_uniform(UInt32(wheres.count)))]
    keyword["what"] = whats[(Int)(arc4random_uniform(UInt32(whats.count)))]
    keyword["will"] = wills[(Int)(arc4random_uniform(UInt32(wills.count)))]
    keyword["theme"] = themes[(Int)(arc4random_uniform(UInt32(themes.count)))]
    
    themeLabel.text = keyword["theme"]
    willLabel.text = keyword["will"]
    
    
    /* TODO: jsonパース時に利用予定 */
    //    let path = Bundle.main.path(forResource: "keywords", ofType: "json")
    //    if path != nil {
    //      let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
    //      print(jsonData)
    //
    //      let jsonDecoder = JSONDecoder()
    //      let keywords = try! jsonDecoder.decode(Keyword.self, from: jsonData)
    //      print(keywords)
    //
    print(keyword)
    //    }
  }
  
}
