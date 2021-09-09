//
//  VideoModel.swift
//  EmbodyDemoApp
//

import Foundation

enum Stream {
    case offline
    case online
}

// MARK: - Welcome
struct VideoModel: Codable {
    var online: [Online]
    var offline: [Offline]

    enum CodingKeys: String, CodingKey {
        case online = "Online"
        case offline = "Offline"
    }
}

// MARK: - Offline
struct Offline: Codable {
    var title, videoName: String
    
    func getVideoUrl() -> URL? {
        if let path = Bundle.main.path(forResource: (videoName), ofType:"mp4") {
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
}

// MARK: - Online
struct Online: Codable {
    var title: String
    var link: String
}
