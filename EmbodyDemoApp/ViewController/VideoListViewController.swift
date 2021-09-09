//
//  VideoListViewController.swift
//  EmbodyDemoApp
//

import UIKit
import Foundation
import AVKit
import AVFoundation

class VideoListViewController: UIViewController {
    
    //  MARK: - IBOulets
    @IBOutlet weak var videoListTableView: UITableView!
    
    //  MARK: - Variables
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var stream = Stream.offline
    var videoListModel: VideoModel?
    
    //  MARK: - Life Cycle Methods
    override func viewDidLoad() {
        self.configureUI()
    }
    
    func configureUI() {
        guard let videoModel = VideoData.jsonFile.getDetailsFromJson(VideoModel.self) else {
            self.showAlert(withMessage: Message.jsonNotParse, title: Title.errorTitle, rightButton: AlertButton.ok) { (_) in
            }
            return
        }
        videoListTableView.estimatedRowHeight = 200.0
        videoListModel = videoModel
        videoListTableView.reloadData()
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

//MARK:-TableView
extension VideoListViewController:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stream == .online ? videoListModel?.online.count ?? 0 : videoListModel?.offline.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClassName: VideoTableViewCell.self, for: indexPath)

        if stream == .offline {
            let offlineVideoModel = videoListModel?.offline[indexPath.row]
            cell.cellConfiguration(for: offlineVideoModel)
        } else {
            let onlineVideoModel = videoListModel?.online[indexPath.row]
            cell.cellConfiguration(for: onlineVideoModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var videoUrl: URL?
        
        if stream == .offline {
            guard let videoLink = videoListModel?.offline[indexPath.row].getVideoUrl() else {
                self.showAlert(withMessage: Message.noVideoUrlAvailable, title: Title.errorTitle, rightButton: AlertButton.ok) { (_) in
                }
                return
            }
            videoUrl = videoLink
        } else {
            guard let videoLink = videoListModel?.online[indexPath.row].link else {
                self.showAlert(withMessage: Message.noVideoUrlAvailable, title: Title.errorTitle, rightButton: AlertButton.ok) { (_) in
                }
                return
            }
            videoUrl = URL(string: videoLink)
        }
        
        if let url = videoUrl {
            playerView = AVPlayer(url: url)
            playerViewController.player = playerView
            self.present(playerViewController, animated: true) {
                self.playerViewController.player?.play()
            }
        } else {
            self.showAlert(withMessage: Message.noVideoUrlAvailable, title: Title.errorTitle, rightButton: AlertButton.ok) { (_) in
            }
        }
    }
}
