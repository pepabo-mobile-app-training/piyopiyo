//
//  ViewController.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/09/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //画面遷移時にURLを設定する実装にひとまずしてある状態
        let vc = segue.destination as? UserFeedViewController
        vc!.userFeedURL = URL(string: "https://www.google.com")
    }
}
