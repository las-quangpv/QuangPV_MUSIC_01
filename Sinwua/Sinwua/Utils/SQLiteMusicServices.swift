import UIKit
import FMDB

let shared = SQLiteMusicServices()

class SQLiteMusicServices: NSObject {
    
    var db:FMDatabase? = nil
    
    class func newInstance() -> SQLiteMusicServices
    {
        shared.db = FMDatabase(path: App.getUrlPath(fileName: "conversation.db"))
        return shared
    }
    
    func insertMusic(musicModel: MusicModel) {
        shared.db!.open()
        shared.db!.executeUpdate("INSERT INTO song (id_album, favourite, file_path, name, category) VALUES (?, ?, ?, ?, ?)", withArgumentsIn: [musicModel.id_album, musicModel.favourite, musicModel.file_path, musicModel.name, musicModel.category])
        shared.db!.close()
    }
    func deleteBookMark(musicModel: MusicModel) {
        shared.db!.open()
        shared.db!.executeUpdate("DELETE FROM song where name = ?", withArgumentsIn: [musicModel.name])
        shared.db!.close()
    }
    
    func updateMusic(musicModel: MusicModel) {
        shared.db!.open()
        shared.db!.executeUpdate("UPDATE song SET id_album = ?, favourite = ?, file_path = ?, name = ?, category = ? where name = ?", withArgumentsIn: [musicModel.id_album, musicModel.favourite, musicModel.file_path, musicModel.name, musicModel.category ,musicModel.name])
        shared.db!.close()
    }
    func updateAllMusic(musicList: [MusicModel], completion:(()->Void?)) {
        musicList.forEach { musicModel in
            updateMusic(musicModel: musicModel)
        }
        completion()
    }
    
    func getMusics(category: String) -> [MusicModel] {
        shared.db!.open()
        var query = ""
        if category == "" {
            query = "SELECT * FROM song"
        } else {
            query = "SELECT * FROM song where category like '\(category)'"
        }
        let resultSet:FMResultSet! = shared.db!.executeQuery(query, withArgumentsIn: [0])
        
        var items = [MusicModel]()
        if (resultSet != nil)
        {
            while resultSet.next() {
                let item = MusicModel()
                item.id_album = String(resultSet.string(forColumnIndex: 1) ?? "")
                item.favourite = Int(resultSet.int(forColumnIndex: 2))
                item.file_path = String(resultSet.string(forColumnIndex: 3) ?? "")
                item.name = String(resultSet.string(forColumnIndex: 4) ?? "")
                item.category = String(resultSet.string(forColumnIndex: 5) ?? "")
                items.append(item)
            }
        }
        
        shared.db!.close()
        return items
    }
    func insertAlbum(albumModel: AlbumModel) -> Int{
        shared.db!.open()
        var isInserted = 0
        let check =  shared.db!.executeUpdate("INSERT INTO album (name, category, image) VALUES (?, ?, ?)", withArgumentsIn: [albumModel.name, albumModel.category, albumModel.image])
        if check == true {
            isInserted = Int(shared.db!.lastInsertRowId)
        }
        shared.db!.close()
        return isInserted
    }
    func deleteAlbum(albumModel: AlbumModel) {
        shared.db!.open()
        shared.db!.executeUpdate("DELETE FROM album where name = ?", withArgumentsIn: [albumModel.name])
        shared.db!.close()
    }
    func updateAlbum(albumModel: AlbumModel) {
        shared.db!.open()
        shared.db!.executeUpdate("UPDATE song SET name = ?, category = ?, image = ? where id = ?", withArgumentsIn: [albumModel.name, albumModel.category, albumModel.image])
        shared.db!.close()
    }
    
    func getAlbums() -> [AlbumModel] {
        shared.db!.open()
        let query = "SELECT * FROM album"
        let resultSet:FMResultSet! = shared.db!.executeQuery(query, withArgumentsIn: [0])
        var items = [AlbumModel]()
        if (resultSet != nil) {
            while resultSet.next() {
                let item = AlbumModel()
                item.id = Int(resultSet.int(forColumnIndex: 0))
                item.name = String(resultSet.string(forColumnIndex: 1) ?? "")
                item.category = String(resultSet.string(forColumnIndex: 2) ?? "")
                item.image = String(resultSet.string(forColumnIndex: 3) ?? "")
                items.append(item)
            }
        }
        
        shared.db!.close()
        return items
    }
    
}
