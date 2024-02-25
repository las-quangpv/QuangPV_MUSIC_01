
import UIKit
import BoxSDK
import AuthenticationServices

enum MediaBoxError: Error {
    case NotAuthorized
}


class MusicBoxService: NSObject {
    private var mBoxSdk: BoxSDK!
    private var musicClient: BoxClient?
    private var window: UIWindow?
    var boxAuthorized: Bool {
        return musicClient != nil
    }
    
    var user: User?
    
    static let getInstance = MusicBoxService()
    
    override init() {
    }
    
    func awake() {
        mBoxSdk = BoxSDK(clientId: clientId, clientSecret: clientSecret)
        KeychainTokenStore().read { (result) in
            switch result {
            case .success(_):
                self.signInBoxDriver { success in
                    self.requestBoxAccount { (user) in }
                }
            case .failure(_): break
            }
        }
    }
    
    func requestBoxAccount(_ completion: @escaping (_ user: User?) -> Void) {
        guard let cl = musicClient else {
            self.user = nil
            completion(nil)
            return
        }
        cl.users.getCurrent(fields: ["name", "login"]) { (result: Result<User, BoxSDKError>) in
            guard case let .success(user) = result else {
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }
            DispatchQueue.main.async {
                self.user = user
                completion(user)
            }
        }
    }
    
    func signInBoxDriver(_ completion: @escaping (_ success: Bool) -> Void) {
        if #available(iOS 13, *) {
            mBoxSdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.musicClient = client
                case .failure(_):
                    self?.musicClient = nil
                }
                DispatchQueue.main.async {
                    completion(self?.musicClient != nil)
                }
            }
        } else {
            mBoxSdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.musicClient = client
                case .failure(_):
                    self?.musicClient = nil
                }
                DispatchQueue.main.async {
                    completion(self?.musicClient != nil)
                }
            }
        }
    }
    
    func signOutBoxDriver() {
        musicClient = nil
        user = nil
        KeychainTokenStore().clear { (result) in
            switch result {
            case .success(): break
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    func searchAudio(completion: @escaping (_ files: [File], _ error: Error?) -> Void) {
        guard let cl = musicClient else {
            completion([], MediaBoxError.NotAuthorized)
            return
        }
        let q = "*.mp3 OR *.m4a OR *.wav"
        // only get max 200 items
        let iterator = cl.search.query(query: q, itemType: .file, limit: 200)
        
        iterator.next { results in
            switch results {
            case let .success(page):
                var result: [File] = []
                
                for item in page.entries {
                    switch item {
                    case let .file(file):
                        result.append(file)
                    default: break
                    }
                }
                
                completion(result, nil)
                
            case let .failure(err):
                completion([], err.error)
            }
        }
    }
    
    func downloadMusic(_ fileItem: File?, progressBlock: @escaping (Progress) -> Void, completion: @escaping ((Bool, String) -> Void)) {
        guard let fileItem = fileItem, let cl = musicClient, let name = fileItem.name else {
            completion(false, "")
            return
        }
        let newName = name.replacingOccurrences(of: " ", with: "")

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsURL.appendingPathComponent(newName)
        
        cl.files.download(fileId: fileItem.id, destinationURL: url, version: nil, progress: progressBlock) { (result: Result<Void, BoxSDKError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(true, newName)
                case .failure(_):
                    completion(false, "")
                }
            }
        }
    }
}

extension MusicBoxService: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.window ?? ASPresentationAnchor()
    }
}
