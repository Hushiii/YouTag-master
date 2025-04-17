//
//  LibraryTableView.swift
//  YouTag
//
//  Created by Smartphone Group9 on 2025.
//  
//

import UIKit

class LibraryTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
 
    var LM: LibraryManager!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        LM = LibraryManager.init()

        self.register(LibraryCell.self, forCellReuseIdentifier: "LibraryCell")
        self.delegate = self
        self.dataSource = self
    }

    func refreshTableView() {
        self.LM.refreshLibraryArray()
        self.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LM.libraryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath as IndexPath) as! LibraryCell
        
        let songDict = LM.libraryArray.object(at: LM.libraryArray.count - 1 - indexPath.row) as! Dictionary<String, Any>
        cell.songDict = songDict
        cell.refreshCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell number: \(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath) as! LibraryCell
        let songDict = cell.songDict
 
        let playlistManager = PlaylistManager()
        playlistManager.playlistLibraryView.playlistArray = NSMutableArray(array: [songDict])
        playlistManager.refreshPlaylistLibraryView()
        let player = playlistManager.audioPlayer!

        let nowPlayingView = NowPlayingView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 120, width: UIScreen.main.bounds.width, height: 120), audioPlayer: player)
        nowPlayingView.songID = songDict["id"] as? String ?? ""

        let currentController = UIApplication.getCurrentViewController()
        currentController?.view.addSubview(nowPlayingView)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let cell = tableView.cellForRow(at: indexPath) as! LibraryCell
            LM.deleteSongFromLibrary(songID: cell.songDict["id"] as? String ?? "")
            LM.refreshLibraryArray()
            tableView.reloadData()
        }
    }
    
}
