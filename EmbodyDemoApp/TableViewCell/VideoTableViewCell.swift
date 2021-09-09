//
//  VideoTableViewCell.swift
//  EmbodyDemoApp
//

import UIKit
import AVKit
import AVFoundation

class VideoTableViewCell: UITableViewCell {
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!

    func cellConfiguration(for offlineStream: Offline?) {
        videoTitleLabel.text = offlineStream?.title

        if let videoPath = offlineStream?.getVideoUrl() {
            configureWith(url: videoPath)
        }
    }
    
    func cellConfiguration(for onlineStream: Online?) {
        if let videoLink = onlineStream?.link,
           let url = URL(string: videoLink) {
            videoTitleLabel.text = onlineStream?.title
            configureWith(url: url)
        }
    }
    
    func configureWith(url: URL) {
        //Thumbnail
        DispatchQueue.main.async {
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            if let cgImage = try? imgGenerator.copyCGImage(at: CMTime.init(value: 0, timescale: 1), actualTime: nil) {
                let uiImage = UIImage.init(cgImage: cgImage)
                self.videoImageView.image = uiImage
            } else {
                print("No image")
            }
        }
    }
}
