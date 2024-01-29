import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    private init() {
        
    }
    
    func startBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.play()
            } catch {
                print("erro no load da musica de fundo \(error.localizedDescription)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        if let soundEffectURL = Bundle.main.url(forResource: "som_transicao", withExtension: "mp3") {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: soundEffectURL)
                soundEffectPlayer?.play()
            } catch {
                print("erro no load do efeito sonoro de passagem de fase \(error.localizedDescription)")
            }
        }
    }
    
    func changeBackgroundMusic() {
        stopBackgroundMusic()
        startBackgroundMusic()
    }
}
