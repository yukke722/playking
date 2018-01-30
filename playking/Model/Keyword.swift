//
//  Keyword.swift
//  playking
//
//  Created by yusuke hashimoto on 2018/01/26.
//  Copyright © 2018年 Yusuke Hashimoto. All rights reserved.
//

/* TODO: jsonパース機能未実装 */
struct Keyword : Codable {
  
  
  struct Card : Codable {
    var name: String
    var level: Int
    var point: Int
  }
  
  enum typeKeys: String, Codable {
    case When, Who, Where, What, Will, Theme
  }
  
  struct keyword : Codable {
    var When: Card
    var Who: Card
    var Where: Card
    var What: Card
    var Will: Card
    var Theme: Card
  }
  
  var keywords : [typeKeys]
}
