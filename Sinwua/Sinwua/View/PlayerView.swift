

import UIKit

class PlayerView: UIView {
    @IBOutlet weak var vSlider: UISlider!
    @IBOutlet weak var btnPlayer: UIButton!
    @IBOutlet weak var lblNameMusic: UILabel!

    var controller: UIViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "PlayerView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
            vSlider.minimumValue = 0
            vSlider.maximumValue = 1
            NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlayerUpdate), name: Notification.Name(rawValue: "reloadData"), object: nil);
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlayerProgress), name: Notification.Name(rawValue: "progress"), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlayerState), name: Notification.Name(rawValue: "musicState"), object: nil);
            
            
            setupView()
            
        }
    }
    @objc func musicPlayerState(_ notification: Notification) {
        if let state = notification.object as? MusicState {
            if(state == MusicState.Pause) {
                print("12345678")
                btnPlayer.setImage(UIImage(named: "ic_play_player"), for: .normal)
            }else {
                print("asdhj")
                btnPlayer.setImage(UIImage(named: "ic_pause_player"), for: .normal)
            }
        }
    }
    @objc func musicPlayerProgress(_ notification: Notification) {
        if let progress = notification.object as? Float {
            vSlider.value = progress
        }
    }
    
     @objc func musicPlayerUpdate(_ notification: Notification) {
         if let _ = notification.object as? MusicModel {
             setupView()
         }
     }
    
    func setupView() {
        if let musicModel = MusicManager.getInstance.currentMusicModel() {
            lblNameMusic.text = musicModel.name
            togetherPlayButton()
        }
    }
    func togetherPlayButton() {
        if(MusicManager.getInstance.isPlaying()) {
            btnPlayer.setImage(UIImage(named: "ic_pause_Player"), for: .normal)
        }else {
            btnPlayer.setImage(UIImage(named: "ic_play_player"), for: .normal)
        }
    }
    @IBAction func actionToPlayer(_ sender: Any) {
        if let controller = controller {
            let vc = PlayerVC()
            controller.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let time = Double(sender.value) * MusicManager.getInstance.duration
        MusicManager.getInstance.seek(to: time)
        togetherPlayButton()
    }
    
    @IBAction func actionTogether(_ sender: Any) {
        if(MusicManager.getInstance.isPlaying()) {
            MusicManager.getInstance.pause()
            btnPlayer.setImage(UIImage(named: "ic_play_player"), for: .normal)
        }else {
            MusicManager.getInstance.resume()
            btnPlayer.setImage(UIImage(named: "ic_pause_Player"), for: .normal)
        }
    }
    
    @IBAction func actionPrevious(_ sender: Any) {
        MusicManager.getInstance.previous()
        setupView()
    }
    @IBAction func actionNext(_ sender: Any) {
        MusicManager.getInstance.next()
        setupView()
    }

}
 
