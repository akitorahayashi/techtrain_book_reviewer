//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

actor UserProfileService {
    private let apiClient: TechTrainAPIClient
    
    static var yourAccount: TBRUser? = nil
    
    init(apiClient: TechTrainAPIClient = TechTrainAPIClientImpl.shared) {
        self.apiClient = apiClient
    }
    
    func decodeUserProfile(token: String, profileData: Data) throws(TechTrainAPIError) -> TBRUser {
        guard let jsonUserData = try? JSONSerialization.jsonObject(with: profileData, options: []) as? [String: Any],
              let name = jsonUserData["name"] as? String,
              let iconUrl = jsonUserData["iconUrl"] as? String? else {
            
            throw TechTrainAPIError.decodingError
        }
        
        return TBRUser(token: token, name: name, iconUrl: iconUrl)
    }

    
    
    /// ユーザー名を更新する
    func updateUserName(
        withToken token: String,
        enteredNewName: String
    ) async throws(TechTrainAPIError.ServiceError) -> Void {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let body = [
            "name": enteredNewName
        ]
        
        do {
            let newNameData = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "PUT", headers: headers, body: body)
            guard let newNameJson = try JSONSerialization.jsonObject(with: newNameData) as? [String: String], let newName = newNameJson["name"] else {
                throw TechTrainAPIError.ServiceError.underlyingError(.decodingError)
            }
            UserProfileService.yourAccount?.name = newName
            print("UserProfileService: ユーザー名の更新に成功しました")
        } catch let error as TechTrainAPIError {
            throw error.toServiceError()
        } catch {
            throw TechTrainAPIError.ServiceError.unknown
        }
    }
    
    /// ユーザープロファイルを取得する
    func fetchUserProfileAndSetSelfAccount(
        withToken token: String
    ) async throws(TechTrainAPIError.ServiceError) -> Void {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        do {
            let profileData = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedUserData = try decodeUserProfile(token: token, profileData: profileData)
            UserProfileService.yourAccount = decodedUserData
        } catch {
            throw error.toServiceError()
        }
    }
}
