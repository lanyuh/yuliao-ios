import UIKit
import WebKit

/// 屿聊的壳：一个全屏网页，没有地址栏。
/// 域名换了咋办：长按左上角那块（看不见的 44×44）两秒，能改地址。
final class 聊天: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var 网页: WKWebView!
    private let 存址 = "屿聊地址"
    private let 默认址 = "https://suspected-resulting-require-pharmaceuticals.trycloudflare.com"

    private var 地址: String {
        let 存 = UserDefaults.standard.string(forKey: 存址) ?? ""
        return 存.isEmpty ? 默认址 : 存
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.043, green: 0.067, blue: 0.094, alpha: 1)

        let 配 = WKWebViewConfiguration()
        配.allowsInlineMediaPlayback = true
        配.mediaTypesRequiringUserActionForPlayback = []
        网页 = WKWebView(frame: .zero, configuration: 配)
        网页.uiDelegate = self
        网页.navigationDelegate = self
        网页.allowsBackForwardNavigationGestures = true
        网页.isOpaque = false
        网页.backgroundColor = .clear
        网页.scrollView.backgroundColor = .clear
        网页.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(网页)

        NSLayoutConstraint.activate([
            网页.topAnchor.constraint(equalTo: view.topAnchor),
            网页.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            网页.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            网页.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let 刷 = UIRefreshControl()
        刷.addTarget(self, action: #selector(重载), for: .valueChanged)
        网页.scrollView.refreshControl = 刷

        // 看不见的改地址入口：长按左上角两秒
        let 角 = UIView(frame: .zero)
        角.translatesAutoresizingMaskIntoConstraints = false
        角.backgroundColor = .clear
        view.addSubview(角)
        NSLayoutConstraint.activate([
            角.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            角.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            角.widthAnchor.constraint(equalToConstant: 44),
            角.heightAnchor.constraint(equalToConstant: 44),
        ])
        let 长 = UILongPressGestureRecognizer(target: self, action: #selector(改址(_:)))
        长.minimumPressDuration = 1.5
        角.addGestureRecognizer(长)

        开()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func 开() {
        guard let u = URL(string: 地址) else { return }
        网页.load(URLRequest(url: u))
    }

    @objc private func 重载() {
        if 网页.isLoading {
            网页.stopLoading()
        }
        开()
        网页.scrollView.refreshControl?.endRefreshing()
    }

    @objc private func 改址(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began else { return }
        let 框 = UIAlertController(title: "屿聊的地址", message: "域名换了就填新的", preferredStyle: .alert)
        框.addTextField { [weak self] t in
            t.text = self?.地址
            t.keyboardType = .URL
            t.autocapitalizationType = .none
            t.autocorrectionType = .no
        }
        框.addAction(UIAlertAction(title: "用这个", style: .default) { [weak self, weak 框] _ in
            guard let self else { return }
            let v = (框?.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !v.isEmpty else { return }
            UserDefaults.standard.set(v, forKey: self.存址)
            self.开()
        })
        框.addAction(UIAlertAction(title: "算了", style: .cancel, handler: nil))
        present(框, animated: true, completion: nil)
    }

    // MARK: - 网页代理

    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let 框 = UIAlertController(title: "屿聊", message: message, preferredStyle: .alert)
        框.addAction(UIAlertAction(title: "好", style: .default) { _ in completionHandler() })
        present(框, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let 框 = UIAlertController(title: "屿聊", message: message, preferredStyle: .alert)
        框.addAction(UIAlertAction(title: "好", style: .default) { _ in completionHandler(true) })
        框.addAction(UIAlertAction(title: "算了", style: .cancel) { _ in completionHandler(false) })
        present(框, animated: true, completion: nil)
    }

    // 页面里点链接开新窗口的，就在当前窗口开
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let 框 = UIAlertController(title: "打不开", message: "连不上 \(地址)\n长按左上角可以改地址", preferredStyle: .alert)
        框.addAction(UIAlertAction(title: "再试一次", style: .default) { [weak self] _ in self?.开() })
        框.addAction(UIAlertAction(title: "算了", style: .cancel, handler: nil))
        present(框, animated: true, completion: nil)
    }
}
