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
    
    init(apiClient: TechTrainAPIClient = TechTrainAPIClientImpl.shared) {
        self.apiClient = apiClient
    }
    
    func getAccountData() -> TBRUser? {
        return UserProfileService.yourAccount
    }
    
    func updateAccountState(newState: TBRUser?) {
        UserProfileService.yourAccount = newState
    }
    
    func decodeUserProfile(token: String, profileData: Data) throws(TechTrainAPIError) -> TBRUser {
        guard let jsonUserData = try? JSONSerialization.jsonObject(with: profileData, options: []) as? [String: String],
              let name = jsonUserData["name"] else {
            throw TechTrainAPIError.decodingError
        }
        
        // アイコンのurlはオプショナル
        let iconUrl = jsonUserData["iconUrl"]
        
        return TBRUser(token: token, name: name, iconUrl: iconUrl)
    }
    
    /// ユーザー名を更新する
    func updateAndSetUserName(
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
            let newNameData = try await self.apiClient.makeRequestAsync(to: endpoint, method: "PUT", headers: headers, body: body)
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
            let profileData = try await self.apiClient.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedUserData = try decodeUserProfile(token: token, profileData: profileData)
            updateAccountState(newState: decodedUserData)
        } catch {
            throw error.toServiceError()
        }
    }
}
