//
//  ViewController.swift
//  reKara Player
//
//  Created by makoty on 2018/10/08.
//  Copyright © 2018 makoty. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistLabel: UITextField!
    @IBOutlet weak var albumLabel: UITextField!
    @IBOutlet weak var songLabel: UITextField!

    var player = MPMusicPlayerController.systemMusicPlayer

    // ViewControllerが準備できたら最初に呼ばれる
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // 再生中のItemが変わった時に通知を受け取る
        let notificationCenter = NotificationCenter.default
        
        // MPMusicPlayerControllerNowPlayingItemDidChangeが呼ばれたらselfのselectorを呼ぶ
        notificationCenter.addObserver(
            self,
            selector: #selector(ViewController.nowPlayingItemChanged(notification:)),
            name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player
        )
        // 通知の有効化
        player.beginGeneratingPlaybackNotifications()
    }

    /// 再生中の曲が変更になったときに呼ばれる
    @objc func nowPlayingItemChanged(notification: NSNotification)
    {
        if let mediaItem = player.nowPlayingItem {
            updateSongInformationUI(mediaItem: mediaItem)
        }
    }

    /// 曲情報を表示する
    @objc func updateSongInformationUI(mediaItem: MPMediaItem)
    {
        // 曲情報表示
        artistLabel.text = mediaItem.artist ?? "不明なアーティスト"
        albumLabel.text = mediaItem.albumTitle ?? "不明なアルバム"
        songLabel.text = mediaItem.title ?? "不明な曲"
        
        // アートワーク表示
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: imageView.bounds.size)
            imageView.image = image
        } else {
            // アートワークがないとき
            // (今回は灰色表示としました)
            imageView.image = nil
            imageView.backgroundColor = UIColor.gray
        }
        
    }

    @IBAction func pick(_ sender: Any) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択にする。（falseにすると、単数選択になる）
        picker.allowsPickingMultipleItems = true
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
        
    }

    /// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)
    {
        // プレイヤーを止める
        player.stop()
        
        // 選択した曲情報がmediaItemCollectionに入っているので、これをplayerにセット。
        player.setQueue(with: mediaItemCollection)
        
        // 選択した曲から最初の曲の情報を表示
        if let mediaItem = mediaItemCollection.items.first {
            updateSongInformationUI(mediaItem: mediaItem)
        }
        
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
        
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }

    @IBAction func pushPlay(_ sender: Any) {
        player.play()
    }
    @IBAction func pushPause(_ sender: Any) {
        player.pause()
    }
    @IBAction func pushStop(_ sender: Any) {
        player.stop()
    }

    // デストラクタ
    deinit {
        // 再生中アイテム変更に対する監視をはずす
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(
            self,
            name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player
        )
        // ミュージックプレーヤー通知の無効化
        player.endGeneratingPlaybackNotifications()
    }
}

