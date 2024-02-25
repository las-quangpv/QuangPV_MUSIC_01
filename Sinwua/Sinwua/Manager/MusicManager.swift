import AVFoundation

enum MusicState {
    case Play
    case Pause
}
protocol MusicManagerDelegate {
    func  progressMusic(currentTime: Double, duration: TimeInterval)
    func musicState(state: MusicState)
}
class MusicManager: NSObject {

    override init() {
    }
    static let getInstance = MusicManager()
    var playlist: [MusicModel] = []
    var addedItems: [Int] = [] // dạm sách list ngẫu nhiên
    var currentPlayer: AVAudioPlayer?
    var currentIndex: Int = 0
    var pausedTime: TimeInterval = 0
    var currentTime: TimeInterval {
        return currentPlayer?.currentTime ?? 0
    }
    var duration: TimeInterval {
        return currentPlayer?.duration ?? 0
    }
    var isLoop: Bool = false
    var isShufle: Bool = false
    var displayLink: CADisplayLink?
    var delegate: MusicManagerDelegate?

    func playMusicWithNewList(musicList: [MusicModel]) {
        currentIndex = 0
        playlist = musicList
        play()
    }

    func addMusicModelAndPlay(musicModel: MusicModel) {
        currentIndex = 0
        let index = playlist.firstIndex { findMusicModel in
            return findMusicModel.name == musicModel.name && musicModel.file_path == musicModel.file_path
        } ?? -1
        if(index == -1) {
            playlist.insert(musicModel, at: 0)
        }else {
            currentIndex = index
        }
        
        play()
    }
    func addRandomItem() {
        if(isLoop) {
            return
        }
        if addedItems.count >= playlist.count {
            addedItems.removeAll()
        }
        let randomIndex = Int.random(in: 0..<playlist.count)
        if !addedItems.contains(randomIndex) {
            addedItems.append(randomIndex)
            currentIndex = randomIndex
        }
    }
    
    func currentMusicModel()-> MusicModel? {
        if(playlist.count > 0 && currentIndex < playlist.count) {
            let musicModel = playlist[currentIndex]
            return musicModel
        }
        return nil
    }
    func seek(to time: TimeInterval) {
        if let currentPlayer = currentPlayer {
            currentPlayer.currentTime = time
            currentPlayer.play()
        }
    }
    func isPlaying()-> Bool {
        if let currentPlayer = currentPlayer {
           return currentPlayer.isPlaying
        }
        return false
    }
    
    func play() {
        if(isShufle) {
            addRandomItem()
        }
        guard let currentSong = playlist[safe: currentIndex] else {
            return
        }
        
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docURL.appendingPathComponent(currentSong.file_path)
        do {
            currentPlayer = try AVAudioPlayer(contentsOf: url)
            currentPlayer?.delegate = self
            currentPlayer?.play()
            if(self.delegate != nil) {
                self.delegate?.musicState(state: MusicState.Play)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: currentSong)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicState"), object: MusicState.Play)
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
        
    }

    func pause() {
        if let currentPlayer = currentPlayer {
            currentPlayer.pause()
            pausedTime = currentPlayer.currentTime
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicState"), object: MusicState.Pause)
            if(self.delegate != nil) {
                self.delegate?.musicState(state: MusicState.Pause)
            }
        }
    }
    func resume() {
        if let currentPlayer = currentPlayer {
            currentPlayer.currentTime = pausedTime
            currentPlayer.play()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "musicState"), object: MusicState.Play)
            if(self.delegate != nil) {
                self.delegate?.musicState(state: MusicState.Play)
            }
        }
    }
    
    func next() {
        currentIndex = (currentIndex + 1) % playlist.count
        play()
    }
    
    func previous() {
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        play()
    }
    
    func repeatSong() {
        // Tính năng lặp lại bài hát
    }
    func setupTimeObserver() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateTime))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateTime() {
        guard let currentPlayer = currentPlayer else { return }
        
        let totalDuration = currentPlayer.duration
        let currentTime = currentPlayer.currentTime
        let progress = Float(currentTime / duration)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "progress"), object: progress)
        if(self.delegate != nil) {
            self.delegate?.progressMusic(currentTime: currentTime, duration: totalDuration)
        }
    }
}
extension MusicManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if(isLoop) {
                play()
            }else {
                next()
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
