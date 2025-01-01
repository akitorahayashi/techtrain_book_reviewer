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
    
    private func decodeUserProfile(token: String, profileData: Data) throws(TechTrainAPIError) -> TBRUser {
        do {
            if let jsonUserData = try JSONSerialization.jsonObject(with: profileData, options: []) as? [String: Any],
               let name = jsonUserData["name"] as? String,
               let iconUrl = jsonUserData["iconUrl"] as? String {
                let user = TBRUser(token: token, name: name, iconUrl: iconUrl)
                return user
            } else {
                throw TechTrainAPIError.decodingError
            }
        } catch {
            throw TechTrainAPIError.decodingError
        }
    }
    
    
    /// ユーザー名を更新する
    func updateUserName(
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
            let _ = try await apiClient.makeRequestAsync(to: endpoint, method: "PUT", headers: headers, body: parameters)
            print("UserProfileService: ユーザー名の更新に成功しました")
        } catch {
            throw error.toServiceError()
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
            let profileData = try await apiClient.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedUserData = try decodeUserProfile(token: token, profileData: profileData)
            UserProfileService.yourAccount = decodedUserData
        } catch {
            throw error.toServiceError()
        }
    }
}
