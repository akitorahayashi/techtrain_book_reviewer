//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

actor UserProfileService {
    
    static var yourAccount: TBRUser? = nil
    
    private let apiClient: TechTrainAPIClient
    
    init(apiClient: TechTrainAPIClient = .shared) {
        self.apiClient = apiClient
    }
    
    static func decodeUserProfile(token: String, profileData: Data) throws(TechTrainAPIError) -> TBRUser {
        guard let jsonUserData = try? JSONSerialization.jsonObject(with: profileData, options: []) as? [String: Any],
              let name = jsonUserData["name"] as? String,
              let iconUrl = jsonUserData["iconUrl"] as? String? else {
            
            throw TechTrainAPIError.decodingError
        }
        
        return TBRUser(token: token, name: name, iconUrl: iconUrl)
    }

    
    
    /// ユーザー名を更新する
    static func updateUserName(
        withToken token: String,
        newName: String
    ) async throws(TechTrainAPIError.ServiceError) -> Void {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters = [
            "name": newName
        ]
        
        do {
            let _ = try await TechTrainAPIClient.shared.makeRequestAsync(to: endpoint, method: "PUT", headers: headers, body: parameters)
            UserProfileService.yourAccount?.name = newName
            print("UserProfileService: ユーザー名の更新に成功しました")
        } catch {
            throw error.toServiceError()
        }
    }
    
    /// ユーザープロファイルを取得する
    static func fetchUserProfileAndSetSelfAccount(
        withToken token: String
    ) async throws(TechTrainAPIError.ServiceError) -> Void {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        do {
            let profileData = try await TechTrainAPIClient.shared.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedUserData = try decodeUserProfile(token: token, profileData: profileData)
            UserProfileService.yourAccount = decodedUserData
        } catch {
            throw error.toServiceError()
        }
    }
}
