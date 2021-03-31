//
//  SymblAI.swift
//  APIExample
//
//  Created by Shams Ahmed on 29/03/2021.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import Foundation
import Combine

/// API to talk to Symbl.ai
final class SymblAI {
    
    // MARK: - Model
    
    /// Upload response
    struct Upload: Decodable {
        
        // MARK: - Property
        
        /// Conversation Id
        let conversationId: String
        
        /// Job Id
        let jobId: String
    }
    
    /// Transcript
    struct Message: Decodable {
        
        // MARK: - Property
        
        /// id
        let id: String
        
        /// Text from audio
        let text: String
    }
    
    /// Status response
    enum Status: String, Decodable {
        case scheduled, in_progress, completed, failed
    }
    
    // MARK: - Enum
    
    /// API
    private enum Path: String {
        case audio = "v1/process/audio"
        case status = "v1/job/"
        case transcript = "v1/conversations/%@/messages"
    }
    
    // MARK: - Property
    
    /// Symbl.ai token, see: https://docs.symbl.ai/docs/developer-tools/authentication
    private let token: String
    
    /// Base URL
    private let baseURL = "https://api.symbl.ai"
    
    // MARK: - Init
    
    /// Create Audio controller and start the audio session
    /// - Parameter token: Symbl.ai token, see: https://docs.symbl.ai/docs/developer-tools/authentication
    init(with token: String)  {
        self.token = token
        
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        guard !token.isEmpty || token != " " else {
            print("Symbl: token is empty")
            
            return
        }
        
        print("SymblAI: setup complete")
    }
    
    // MARK: - Upload
    
    /// Upload MP3 for processing
    /// - Parameters:
    ///   - mp3: mp3 file
    ///   - completionHandler: completion handler results
    func upload(_ mp3: Data, _ completionHandler: @escaping (Result<Upload, Error>) -> Void) {
        guard var url = URL(string: baseURL) else { fatalError("Failed to create Symbl.ai URL") }
        
        print("SymblAI: Starting upload")
        
        url.appendPathComponent(Path.audio.rawValue)
        
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "x-api-key")
        request.addValue("audio/mp3", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: mp3) { data, _, error in
            if let error = error {
                completionHandler(.failure(error))
                
                return
            }
            
            print("SymblAI: Upload complete")
            
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(Upload.self, from: data)
                    
                    completionHandler(.success(model))
                } catch {
                    print(String(data: data, encoding: .utf8) ?? "Data error")
                    
                    completionHandler(.failure(error))
                }
            } else {
                completionHandler(.failure(NSError(domain: "SymblAI", code: 0, userInfo: ["Error": "Invalid upload response"])))
            }
        }

        task.resume()
    }
    
    // MARK: - Status
    
    func status(for upload: Upload, _ completionHandler: @escaping (Status) -> Void) {
        guard var url = URL(string: baseURL) else { fatalError("Failed to create Symbl.ai URL") }
        
        print("SymblAI: Starting upload status check")
        
        url.appendPathComponent(Path.status.rawValue)
        url.appendPathComponent(upload.jobId)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.addValue(token, forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            print("SymblAI: Upload status check complete")
            
            if let data = data {
                do {
                    struct Model: Decodable {
                        
                        // MARK: - Property
                        
                        let status: Status
                    }
                    
                    let model = try JSONDecoder().decode(Model.self, from: data)
                    
                    completionHandler(model.status)
                } catch {
                    print(String(data: data, encoding: .utf8) ?? "Data error")
                    
                    completionHandler(.failed)
                }
            } else {
                completionHandler(.failed)
            }
        }

        task.resume()
    }
    
    // MARK: - Transcript
    
    func transcript(for upload: Upload, _ completionHandler: @escaping (Result<[Message], Error>) -> Void) {
        guard var url = URL(string: baseURL) else { fatalError("Failed to create Symbl.ai URL") }
        
        print("SymblAI: Starting transcript fetch")
        
        let path = String(format: Path.transcript.rawValue, upload.conversationId)
        url.appendPathComponent(path)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.addValue(token, forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            print("SymblAI: Transcription complete")
            
            if let data = data {
                do {
                    struct Model: Decodable {
                        
                        // MARK: - Property
                        
                        let messages: [Message]
                    }
                    
                    let model = try JSONDecoder().decode(Model.self, from: data)
                    
                    completionHandler(.success(model.messages))
                } catch {
                    print(String(data: data, encoding: .utf8) ?? "Data error")
                    
                    completionHandler(.failure(error))
                }
            } else {
                completionHandler(.failure(NSError(domain: "SymblAI", code: 0, userInfo: ["Error": "Invalid transcript response"])))
            }
        }

        task.resume()
    }
}
