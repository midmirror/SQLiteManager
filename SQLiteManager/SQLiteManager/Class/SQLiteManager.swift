//
//  Created by mellow on 2017/3/1.
//  Copyright © 2017年 HPRT. All rights reserved.
//

import Foundation

public class ORMModel: NSObject {
    
    func ORMClassName() -> String {
        return self.classForCoder.description().components(separatedBy: ".").last!
    }
    
    class func ORMName() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var id = String()
}

public class ORMTool {
    class func className(of aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}

fileprivate extension FileManager {
    class func createDirectory(atPath path: String) {
        
        let isExist = FileManager.default.fileExists(atPath: path)
        
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError{
                print("Error: " + error.debugDescription)
            }
        }
    }
}

/// 实际上应该叫： FMDBManager
public class SQLiteManager: NSObject {
    
    static let shared = SQLiteManager()
    var db: FMDatabase?
    var dbQueue: FMDatabaseQueue?
    let identifier = "id"
    
    fileprivate override init() {
        let dir = NSHomeDirectory()+"/Documents/database/"
        FileManager.createDirectory(atPath: dir)
        let dbPath: String = dir + "printer.db"
        db = FMDatabase.init(path: dbPath)
        dbQueue = FMDatabaseQueue.init(path: dbPath)
    }
    
    public func executeUpdate(sql: String, args: [Any]?) -> Bool {
        var result = false
        if db?.open() == true{
            result = (db?.executeUpdate(sql, withArgumentsIn: args))!
            db?.close()
        }
        return result
    }
    
    /// 表是否存在
    ///
    /// - Parameter tableName: 表名
    /// - Returns: 结果
    public func isExist(table tableName: AnyClass) -> Bool {
        
        var result = false
        if db?.open() == true {
            result = (db?.tableExists(ORMTool.className(of: tableName)))!
        }
        db?.close()
        return result
    }
    
    public func create(table tableName: AnyClass) -> Bool {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(ORMTool.className(of: tableName))(\(tableName.orm_createTableSqlProperty()!))"
        return executeUpdate(sql: sql, args: nil)
    }
    
    public func drop(table tableName: String) -> Bool {
        let sql = "DROP TABLE IF EXISTS \(tableName)"
        return executeUpdate(sql: sql, args: nil)
    }
    
    // MARK: - Insert
    
    public func insert(object obj: ORMModel) {
        insert(table: obj.classForCoder, valuesDict: obj.modelToJSONObject() as! [String : Any])
    }
    
    public func insert(table tableName: AnyClass, valuesDict: [String: Any]) {
        insert(table: tableName, valuesDict: valuesDict, replace: true)
    }
    
    public func insert(table tableName: AnyClass, valuesDict: [String: Any], replace: Bool) {
        
        if isExist(table: tableName) == false {
            if create(table: tableName) == false {
                return
            }
        }
        
        var columns = [String]()
        var values = [Any]()
        var placeholder = [String]()
        
        for dict in valuesDict.enumerated() {
            
            columns.append(dict.element.key)
            values.append(dict.element.value)
            placeholder.append("?")
        }
        let sql = String.init(format: "INSERT%@ INTO %@ (%@) VALUES (%@)", replace ? " OR REPLACE" : "", ORMTool.className(of: tableName), columns.joined(separator: ","), placeholder.joined(separator: ","))
        let _ = executeUpdate(sql: sql, args: values)
    }
    
    // MARK: - Update
    
    public func update(object obj: ORMModel) -> Bool {
        return update(table: obj.ORMClassName(), valueDict: obj.modelToJSONObject() as! [String: Any])
    }
    
    public func update(table tableName: String, valueDict: [String: Any]) -> Bool {
        return update(table: tableName, valueDict: valueDict, whereSql: String.init(format: "%@=%@", identifier, valueDict[identifier] as! String))
    }
    
    public func update(table tableName: String, valueDict: [String: Any], whereSql: String) -> Bool {

        var settings = [String]()
        var values = [Any]()
        for dict in valueDict.enumerated() {
            settings.append(String.init(format: "%@=?", dict.element.key))
            values.append(dict.element.value)
        }
        let sql = String.init(format: "UPDATE %@ SET %@ WHERE %@", tableName, settings.joined(separator: ","), whereSql)
        return executeUpdate(sql: sql, args: values)
    }
    
    // MARK: - Remove
    
    public func remove(table tableName: String) {
        remove(table: tableName, whereSql: "1=1")
    }
    
    public func remove(object obj: ORMModel) {
        remove(table: obj.ORMClassName(), byId: obj.id)
    }
    
    public func remove(table tableName: String, byId id: String) {
        remove(table: tableName, whereSql: "\(identifier)='\(id)'")
    }
    
    public func remove(table tableName: String, whereSql: String) {
        let sql = "DELETE FROM \(tableName) WHERE \(whereSql)"
        let _ = executeUpdate(sql: sql, args: nil)
    }
    
    // MARK: - Select
    
    public func select(table tableName: String) -> [[AnyHashable: Any]] {
        return select(table: tableName, whereSql: "1=1")
    }
    
    public func select(table tableName: String, byId id: String) -> [AnyHashable: Any]? {
        let result = select(table: tableName, whereSql: "\(identifier)=\(id)")
        return result.count > 0 ? result.first : nil
    }
    
    public func select(table tableName: String, whereSql: String) -> [[AnyHashable: Any]] {
        var result = [[AnyHashable: Any]]()
        if db?.open() == true {
            let fmResult = try! db?.executeQuery("SELECT * FROM \(tableName) WHERE \(whereSql)", values: nil)
            while fmResult?.next() == true {
                result.append((fmResult?.resultDictionary())!)
            }
            db?.close()
        }
        return result
    }
    
    
}
