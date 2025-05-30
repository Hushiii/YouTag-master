//
//  DownloadWebViewController.swift
//  YouTag
//
//  Created by Youstanzr on 3/17/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit
import WebKit

protocol DownloadWebViewDelegate: class {
    func requestedDownloadLink(link: String, contentType fileExtension: String)
}

class DownloadWebViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    weak var delegate: DownloadWebViewDelegate!
    let webView = WKWebView()
    let urlFieldView = UIView()
    let urlField: UITextField = {
        let txtField = UITextField()
        txtField.text = "https://www.youtube.com"
        txtField.backgroundColor = GraphicColors.backgroundWhite
        txtField.textAlignment = .left
        txtField.font = UIFont.init(name: "DINCondensed-Bold", size: 17)
        txtField.autocorrectionType = .no
        txtField.placeholder = "Search or enter website name"
        txtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 34))  // Add padding
        txtField.leftViewMode = .always
        txtField.returnKeyType = .go
        txtField.layer.cornerRadius = 5
        txtField.keyboardType = .webSearch
        txtField.clearButtonMode = .whileEditing
        return txtField
    }()
    let progressBar: UIProgressView = {
        let pBar = UIProgressView()
        pBar.tintColor = GraphicColors.orange
        return pBar
    }()
    let webToolbar = UIToolbar()
    var downloadButton = UIBarButtonItem()
    var currentMIMEType = ""
    private let supportedMIME = ["audio/mpeg": "mp3",
                                 "audio/x-mpeg-3": "mp3",
                                 "video/mp4": "mp4",
                                 "application/mp4": "mp4",
                                 "audio/wav": "wav",
                                 "audio/x-wav": "wav"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GraphicColors.backgroundWhite

        webToolbar.barStyle = .default
        webToolbar.isTranslucent = true
        webToolbar.tintColor = .black
        webToolbar.barTintColor = GraphicColors.gray
        let doneButton = UIBarButtonItem(title: "✔︎", style: .plain, target: self, action: #selector(dismissBtn))
        downloadButton = UIBarButtonItem(title: "↓", style: .plain, target: self, action: #selector(downloadBtn))
        downloadButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)], for: .normal)
        let prevButton = UIBarButtonItem(title: "◀︎", style: .plain, target: self, action: #selector(prevBtn))
        let nextButton = UIBarButtonItem(title: "▶︎", style: .plain, target: self, action: #selector(nextBtn))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        webToolbar.setItems([prevButton, space, nextButton, space, downloadButton, space, doneButton], animated: false)
        self.view.addSubview(webToolbar)
        webToolbar.translatesAutoresizingMaskIntoConstraints = false
        webToolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        webToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        webToolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webToolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        urlFieldView.backgroundColor = GraphicColors.gray
        self.view.addSubview(urlFieldView)
        urlFieldView.translatesAutoresizingMaskIntoConstraints = false
        urlFieldView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        urlFieldView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        urlFieldView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        urlFieldView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        urlField.delegate = self
        urlFieldView.addSubview(urlField)
        urlField.translatesAutoresizingMaskIntoConstraints = false
        urlField.topAnchor.constraint(equalTo: urlFieldView.topAnchor, constant: 40).isActive = true
        urlField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        urlField.leadingAnchor.constraint(equalTo: urlFieldView.leadingAnchor, constant: 5).isActive = true
        urlField.trailingAnchor.constraint(equalTo: urlFieldView.trailingAnchor, constant: -5).isActive = true

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: URL(string: urlField.text!)!))
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: urlFieldView.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webToolbar.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.bottomAnchor.constraint(equalTo: urlFieldView.bottomAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func prevBtn(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func nextBtn(_ sender: UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func dismissBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func downloadBtn(_ sender: UIBarButtonItem) {
        guard let videoUrl = webView.url?.absoluteString else { return }
        
        // YouTube 视频链接判断
        if videoUrl.extractYoutubeId() != nil {
            // 调用 yt-dlp 后端
            guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendAPIBaseURL") as? String,
                  let apiURL = URL(string: "\(baseURL)/api/yt-audio") else {
                print("❌ BackendAPIBaseURL 未配置或格式错误")
                return
            }
            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["url": videoUrl]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let audioUrl = json["audio_url"] as? String,
                      let title = json["title"] as? String else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Download Failed", message: "Could not extract audio URL", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                let safeTitle = title
                    .replacingOccurrences(of: "[\\\\/:*?\"<>|]", with: "", options: .regularExpression)
                    .prefix(50) // 限制长度避免路径过长
                    let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        .appendingPathComponent(safeTitle + ".m4a")
                    
                    guard let audioDownloadURL = URL(string: audioUrl) else {
                        print("❌ Invalid audio URL")
                        return
                    }

                    URLSession.shared.downloadTask(with: audioDownloadURL) { tempURL, response, error in
                        guard let tempURL = tempURL, error == nil else {
                            print("❌ Audio download failed: \(error?.localizedDescription ?? "unknown error")")
                            return
                        }
                        
                        do {
                            try? FileManager.default.removeItem(at: destinationURL)
                            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                            print("✅ Audio saved to: \(destinationURL.path)")
                            DispatchQueue.main.async {
                                self.delegate?.requestedDownloadLink(link: destinationURL.path, contentType: "m4a")
                                self.dismiss(animated: true, completion: nil)
                            }
                        } catch {
                            print("❌ Failed to save audio: \(error.localizedDescription)")
                        }
                    }.resume()
                    
                    if let thumbnail = json["thumbnail"] as? String,
                       let imageUrl = URL(string: thumbnail) {
                        let imageDestination = destinationURL.deletingPathExtension().appendingPathExtension("jpg")
                        URLSession.shared.downloadTask(with: imageUrl) { imgTemp, _, _ in
                            if let imgTemp = imgTemp {
                                try? FileManager.default.removeItem(at: imageDestination)
                                try? FileManager.default.moveItem(at: imgTemp, to: imageDestination)
                                print("🖼 Saved thumbnail to: \(imageDestination.path)")
                            }
                        }.resume()
                    }
                }
            }.resume()
        } else if supportedMIME.keys.contains(currentMIMEType) {
            loadUrl("about:blank")
            self.dismiss(animated: false, completion: {
                self.delegate?.requestedDownloadLink(link: videoUrl, contentType: self.supportedMIME[self.currentMIMEType]!)
            })
        } else {
            let alert = UIAlertController(title: "Cannot Download",
                                          message: "This app only supports:\n- " +
                                          Array(Set(supportedMIME.values)).joined(separator: "\n- "),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default,  handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message:  error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default,  handler: nil))
        present(alert, animated: true, completion: nil)
        progressBar.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as? HTTPURLResponse
        if let contentType = response?.allHeaderFields["Content-Type"] as? String {
            currentMIMEType = contentType
            updateDownloadButtonStatus()
        } else {
            currentMIMEType = ""
        }
        print("Website content type: " + currentMIMEType)
        decisionHandler(.allow);
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView.estimatedProgress)
            progressBar.isHidden = (webView.estimatedProgress == 1.0)
        } else if keyPath == "URL" {
            urlField.text = webView.url?.absoluteString
            updateDownloadButtonStatus()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let urlString = urlField.text else { return true }
        
        if urlString != webView.url?.absoluteString {
            if urlString.starts(with: "http://") || urlString.starts(with: "https://") {
                loadUrl(urlString)
            } else if urlString.contains("www") {
                loadUrl("https://\(urlString)")
            } else {
                searchTextOnGoogle(urlString)
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func loadUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {    return    }
        
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    func searchTextOnGoogle(_ text: String) {
        // check if text contains more then one word separated by space
        let textComponents = text.components(separatedBy: " ")
        
        // we replace space with plus to validate the string for the search url
        let searchString = textComponents.joined(separator: "+")
        
        guard let url = URL(string: "https://www.google.com/search?q=" + searchString) else { return }
        
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    func updateDownloadButtonStatus() {
        if supportedMIME.keys.contains(currentMIMEType) {
            downloadButton.tintColor = GraphicColors.darkGreen
        } else if ((webView.url?.absoluteString.extractYoutubeId()) != nil) {
            downloadButton.tintColor = GraphicColors.darkGreen
        } else {
            downloadButton.tintColor = .black
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't handle button taps
        return !(touch.view is UIButton)
    }

}
