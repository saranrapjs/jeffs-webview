//
//  ContentView.swift
//  Shared
//
//  Created by Jeff Sisson on 11/2/21.
//

import SwiftUI

import Foundation
import UIKit
import WebKit
import SwiftUI

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<UIViewControllerPreview<ViewController>>) {
        return
    }
}


class Browser: UIViewController {
    var webView: WKWebView = WKWebView()
    var userScriptCount = 0;
    var evalJavascriptCount = 0;
    func addScript(asWkUserScript: Bool = false) {
        if (asWkUserScript) {
            userScriptCount = userScriptCount + 1;
        } else {
            evalJavascriptCount = evalJavascriptCount + 1;
        }
        // when executing via WKUserScript, it's blue and on the left
        // when executing via evaluateJavascript, it's red and on the right
        // vertical positions should be consistent even if a given execution doesn't "make it" to the webview
        // (e.g. if a counter is skipped, that should be reflected vertically)
        let color = asWkUserScript ? "blue" : "red";
        let left = asWkUserScript ? "0" : "calc(100% - 20px)";
        let count = asWkUserScript ? userScriptCount : evalJavascriptCount;
        let js = """
            var el = document.createElement('h1');
            el.textContent = "\(count)";
            el.setAttribute("style", "color:\(color);position:absolute; top: \(count * 10)px; left: \(left); width: 100%;z-index: 100000;");
            document.body.appendChild(el);
            """
        if (asWkUserScript) {
            let script = WKUserScript(
                source: js,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
            let controller = webView.configuration.userContentController
            controller.addUserScript(script)
        } else {
            webView.evaluateJavaScript(js)
        }
    }
    func testScripts() {
        addScript(asWkUserScript: true)
        addScript(asWkUserScript: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        testScripts()

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.testScripts()
        }
        
        self.webView.backgroundColor = .systemPink
        self.webView.load(URLRequest(url: URL(string: "https://www.nytimes.com")!))
    }
}

func previewWithNavigationController(_ webViewController: UIViewController) -> some View {
    UIViewControllerPreview {
        let n = UINavigationController()
        n.pushViewController(webViewController, animated: true)
        return n
    }
}


struct WebbbView: UIViewControllerRepresentable {

    // 2.
    func makeUIViewController(context: Context) -> Browser {
        return Browser()
    }
    
    // 3.
    func updateUIViewController(_ uiViewController: Browser, context: Context) {
        
    }
}

struct ContentView: View {
    var body: some View {
        WebbbView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        previewWithNavigationController(Browser())
    }
}
