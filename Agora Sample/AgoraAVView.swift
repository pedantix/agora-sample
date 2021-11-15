//
//  AgoraAVView.swift
//  Agora Sample
//
//  Created by shaun on 11/3/21.
//

import AgoraRtcKit
import UIKit
import SwiftUI
import Combine

// NOTE: For reviewers. It may seem a bit odd to do part of the App in SwiftUI and Part of the App in UIKit,
// when clearly LocalView and RemoteView could be constructed via a UIViewControllerRepresentable and brought
// into SwiftUI as view primitives. However, considering the goal of this projectI felt it was important to
// demonstrate basic competence in both major UI frameworks.
// tl;dr this would not a be the right way to implement this outside of a sample

private class StatsLabel: UIView {
    var statName: String = "" {
        didSet {
            setFPSValue()
        }
    }

    private let label = UILabel()
    var statValue = 0 {
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
        if  statValue != 0 {
            label.text = "\(statName): \(statValue)"
        } else {
            label.text = "\(statName)"
        }
    }

    override func draw(_ rect: CGRect) {
        layer.cornerRadius = rect.height / 2
    }
}

private class AgoraRTCView: UIView {
    var localView: UIView = RoundedUIView()
    var remoteView: UIView = UIView()
    var localFPSView: StatsLabel = .init()
    var remoteFPSView: StatsLabel = .init()
    var channelStatsView: StatsLabel = .init()
    var txKBitRateView: StatsLabel = .init()
    var txKBitRateMeanView: StatsLabel = .init()
    var rxKBitRateView: StatsLabel = .init()
    var rxKBitRateMeanView: StatsLabel = .init()
    var lastMileDelayView: StatsLabel = .init()
    var lastMileDelayMeanView: StatsLabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not being used")
    }

    private func setupView() {
        addViewsToLayout()
        makeConstraints()
    }

    private func addViewsToLayout() {
        [remoteView, localView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        [localFPSView, remoteFPSView, txKBitRateView, txKBitRateMeanView].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        remoteView.addSubview(remoteFPSView)
        localView.addSubview(localFPSView)

        [channelStatsView,
         txKBitRateView, txKBitRateMeanView,
         rxKBitRateView, rxKBitRateMeanView,
         lastMileDelayView, lastMileDelayMeanView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            remoteView.addSubview($0)
        }

        [remoteFPSView, localFPSView].forEach { $0.statName = "FPS" }

        channelStatsView.statName = "Channel Stats"
        txKBitRateView.statName = "txKBitRate"
        txKBitRateMeanView.statName = "txKBitRateMean"
        rxKBitRateView.statName = "rxKBitRate"
        rxKBitRateMeanView.statName = "rxKBitRateViewMean"
        lastMileDelayView.statName = "lastMileDelay"
        lastMileDelayMeanView.statName = "lastMileDelayMean"
    }

    private var views: [String: Any] {
        [
            "remoteView": remoteView,
            "localView": localView,
            "remoteFPSView": remoteFPSView,
            "localFPSView": localFPSView,
            "localTxKBitRateView": txKBitRateView,
            "localTxKBitRateMeanView": txKBitRateMeanView,
            "channelStatsView": channelStatsView,
            "rxKBitRateView": rxKBitRateView,
            "rxKBitRateMeanView": rxKBitRateMeanView,
            "lastMileDelayView": lastMileDelayView,
            "lastMileDelayMeanView": lastMileDelayMeanView
        ]
    }

    private func makeConstraints() {
        let widthLocalView = UIScreen.main.bounds.width * 0.2
        let heightLocalView = widthLocalView * 16 / 9

        let widthFPS: CGFloat = 50
        let heightFPS: CGFloat = 20

        let statsBarArray = [
            "channelStatsView", "localTxKBitRateView", "localTxKBitRateMeanView",
            "rxKBitRateView", "rxKBitRateMeanView", "lastMileDelayView", "lastMileDelayMeanView"
        ]

        let statsBarHorizontalContraints = statsBarArray.map {
            NSLayoutConstraint.constraints(withVisualFormat: "H:[\($0)(\(widthFPS * 3))]-3-|",
                                           options: [], metrics: .none, views: views)
        }.flatMap { $0 }

        let statsBarVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:" + (statsBarArray.map { "[\($0)]" } + ["|"]).joined(separator: "-3-"),
            options: [],
            metrics: .none,
            views: views
        )

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
                                           options: [], metrics: .none, views: views) +
            statsBarHorizontalContraints +
            statsBarVerticalConstraints
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        localView.bringSubviewToFront(localFPSView)
        remoteView.bringSubviewToFront(remoteFPSView)

        [channelStatsView,
         txKBitRateView, txKBitRateMeanView,
         rxKBitRateView, rxKBitRateMeanView,
         lastMileDelayView, lastMileDelayMeanView].forEach { remoteView.bringSubviewToFront($0) }
    }

}

class AgoraRTCViewController: UIViewController {
    private var txBitRateStatsMonitor = StatsMonitor()
    private var rxBitRateStatsMonitor = StatsMonitor()
    private var lastMileDelayStatsMonitor = StatsMonitor()

    private var cancellables = [AnyCancellable]()

    fileprivate var agoraRTCView: AgoraRTCView? {
        return view as? AgoraRTCView
    }

    var agoraKit: AgoraRtcEngineKit?

    override func loadView() {
        super.loadView()

        view = AgoraRTCView()

        let txCancellable = txBitRateStatsMonitor.subject.subscribe(on: DispatchQueue.main).sink { [weak self] values in
            self?.agoraRTCView?.txKBitRateView.statValue = values.current
            self?.agoraRTCView?.txKBitRateMeanView.statValue = values.average
        }

        let rxCancellable = rxBitRateStatsMonitor.subject.subscribe(on: DispatchQueue.main).sink { [weak self] values in
            self?.agoraRTCView?.rxKBitRateView.statValue = values.current
            self?.agoraRTCView?.rxKBitRateMeanView.statValue = values.average
        }

        let lastMileCancellable = lastMileDelayStatsMonitor.subject
            .subscribe(on: DispatchQueue.main).sink { [weak self] values in
            self?.agoraRTCView?.lastMileDelayView.statValue = values.current
            self?.agoraRTCView?.lastMileDelayMeanView.statValue = values.average
        }

        [txCancellable, rxCancellable, lastMileCancellable].forEach { cancellables.append($0) }
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
        let encoderConfiguration = AgoraVideoEncoderConfiguration()

        encoderConfiguration.frameRate = 30
        encoderConfiguration.dimensions = .init(width: 960, height: 720)

        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraConfig.sampleAppID, delegate: self)
        agoraKit?.setVideoEncoderConfiguration(encoderConfiguration)

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

    deinit {
        cancellables.forEach { $0.cancel() }
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
        agoraRTCView?.localFPSView.statValue = Int(stats.rendererOutputFrameRate)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        agoraRTCView?.remoteFPSView.statValue = Int(stats.rendererOutputFrameRate)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        txBitRateStatsMonitor.receive(value: stats.txKBitrate)
        rxBitRateStatsMonitor.receive(value: stats.rxKBitrate)
        lastMileDelayStatsMonitor.receive(value: stats.lastmileDelay)
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
