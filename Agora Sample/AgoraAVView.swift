//
//  AgoraAVView.swift
//  Agora Sample
//
//  Created by shaun on 11/3/21.
//

import AgoraRtcKit
import UIKit
import SwiftUI

// NOTE: For reviewers. It may seem a bit odd to do part of the App in SwiftUI and Part of the App in UIKit,
// when clearly LocalView and RemoteView could be constructed via a UIViewControllerRepresentable and brought
// into SwiftUI as view primitives. However, considering the goal of this projectI felt it was important to
// demonstrate basic competence in both major UI frameworks.
// tl;dr this would not a be the right way to implement this outside of a sample

private class FPSView: UIView {
    private let label = UILabel()
    var currentFPS = 0 {
        didSet {
            setFPSValue()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not being used")
    }

    func setupView() {
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor
        clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .caption2)
        setFPSValue()

        addSubview(label)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[label]-1-|",
                                           options: [], metrics: .none, views: ["label": label]) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[label]-3-|",
                                           options: [], metrics: .none, views: ["label": label])
        )
    }

    func setFPSValue() {
        label.text = "FPS: \(currentFPS)"
    }

    override func draw(_ rect: CGRect) {
        layer.cornerRadius = rect.height / 2
    }
}

private class AgoraRTCView: UIView {
    var localView: UIView = RoundedUIView()
    var remoteView: UIView = UIView()
    var localFPSView: FPSView = .init()
    var remoteFPSView: FPSView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not being used")
    }

    func setupView() {
        [remoteView, localView].compactMap { $0 }.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        [localFPSView, remoteFPSView].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
        remoteView.addSubview(remoteFPSView)
        localView.addSubview(localFPSView)

        let views: [String: Any] = [
            "remoteView": remoteView,
            "localView": localView,
            "remoteFPSView": remoteFPSView,
            "localFPSView": localFPSView
        ]

        let widthLocalView = UIScreen.main.bounds.width * 0.2
        let heightLocalView = widthLocalView * 16 / 9

        let widthFPS: CGFloat = 50
        let heightFPS: CGFloat = 20

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[localView(\(heightLocalView))]",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:[localView(\(widthLocalView))]-8-|",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[remoteView]|",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[remoteView]|",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[remoteFPSView(\(heightFPS))]",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[remoteFPSView(\(widthFPS))]",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[localFPSView(\(heightFPS))]",
                                           options: [], metrics: .none, views: views) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[localFPSView(\(widthFPS))]",
                                           options: [], metrics: .none, views: views)

        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        localView.bringSubviewToFront(localFPSView)
        remoteView.bringSubviewToFront(remoteFPSView)
    }

}

class AgoraRTCViewController: UIViewController {
    fileprivate var agoraRTCView: AgoraRTCView? {
        return view as? AgoraRTCView
    }

    var agoraKit: AgoraRtcEngineKit?

    override func loadView() {
        super.loadView()

        view = AgoraRTCView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeAndJoinChannel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }

    func initializeAndJoinChannel() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraConfig.sampleAppID, delegate: self)
        agoraKit?.enableVideo()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = agoraRTCView?.localView
        agoraKit?.setupLocalVideo(videoCanvas)

        let status = agoraKit?.joinChannel(byToken: AgoraConfig.testingToken,
                              channelId: AgoraConfig.testingChannel, info: nil, uid: 0, joinSuccess: .none)

        print("Channel status \(status ?? 0)")
    }
}

extension AgoraRTCViewController: AgoraRtcEngineDelegate {
     func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
         let videoCanvas = AgoraRtcVideoCanvas()
         videoCanvas.uid = uid
         videoCanvas.renderMode = .hidden
         videoCanvas.view = agoraRTCView?.remoteView
         agoraKit?.setupRemoteVideo(videoCanvas)
     }

    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStats stats: AgoraRtcLocalVideoStats) {
        agoraRTCView?.localFPSView.currentFPS = Int(stats.rendererOutputFrameRate)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        agoraRTCView?.remoteFPSView.currentFPS = Int(stats.rendererOutputFrameRate)
    }
 }

struct AgoraAVView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<AgoraAVView>) -> AgoraRTCViewController {
        return AgoraRTCViewController()
    }

    func updateUIViewController(
        _ uiViewController: AgoraRTCViewController,
        context: UIViewControllerRepresentableContext<AgoraAVView>) {
        /* noop */
    }
}

private class RoundedUIView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not being used")
    }
}
