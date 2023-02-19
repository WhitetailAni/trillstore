//
//  ContentView.swift
//  trillstore
//
//  Created by RealKGB on 2/17/23.
//

import SwiftUI
import AVFAudio
import AVFoundation
import AVKit

struct ContentView: View {
    @State private var cydiaShow = false
    @State private var sileoShow = false
    @State private var panicShow = false
    @State private var trollShow = false
    @State private var movie = false
    @State private var play = false
    @State private var showLoading = false
    
    var body: some View {
        VStack {
            Image("notyoursim")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Trust me bro this app is signed with a legitimate certificate")
            
            HStack{
            ZStack {
                if showLoading {
                    ProgressView()
                } else {
                    Button("install cydia") {
                        showLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            showLoading = false
                            cydiaShow = true
                        }
                    }
                    .alert("install failed!", isPresented: $cydiaShow){
                        Button(":(", role: .cancel) {}
                    }
                }
            }
            Button("install sileo") {
                sileoShow = true
            }
            .disabled(showLoading)
            .alert("amfi got in your way!", isPresented: $sileoShow) {
                Button("quit", role: .cancel) { }
            }
            Button("install trollstore") {
                exit(420)
            }.disabled(showLoading)
            }
            
            HStack{
            Button("respring apple TV") {
                let window = UIApplication.shared.windows.first!
                        while true {
                            window.snapshotView(afterScreenUpdates: false)
                        }
            }.disabled(showLoading)
            Button("panic apple TV") {
                panicShow = true
            }
            .disabled(showLoading)
            .alert("panic failed!", isPresented: $panicShow) {
                Button("quit app", role: .cancel) {
                    exit(69)
                }
            }
            }
            Button("go to the movies") {
                play = true
            }
            .disabled(showLoading)
            .sheet(isPresented: $play) {
                VideoList()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import AVKit
import SwiftUI
import UIKit

struct VideoPlayerView: View {
    @State private var player = AVPlayer()
    @State var videoURL: URL
    @State private var isPlaying = false
    @State private var speedToggle = false
    @State private var isReversed = false
    
    @State private var currentTime: Double = 0.0
    @State private var duration: Double = 0.0
    
    @State private var question = false
    @State private var endShow = false
    
    @State private var rewindIncrement: Int = 1
    @State private var fastIncrement: Int = 1
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        VStack {
    VideoPlayer(player: player)
        .onAppear() {
            player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            player.play()
        }
        .focusable(true)
    HStack {
        Button(action: {
                    // Rewind the video by 10 seconds
                    let newTime = max(player.currentTime() - CMTime(seconds: 10, preferredTimescale: 1), CMTime.zero)
                    player.seek(to: newTime)
                }) {
                    Image(systemName: "gobackward.10")
                        .foregroundColor(.pink)
                }
                
                Text(timeString(time: currentTime))
                
                Button(action: {
                    // Fast-forward the video by 10 seconds
                    let newTime = min(player.currentTime() + CMTime(seconds: 10, preferredTimescale: 1), player.currentItem!.duration)
                    player.seek(to: newTime)
                }) {
                    Image(systemName: "goforward.10")
                        .foregroundColor(.cyan)
                }
    }
    HStack {
        Button(action: {
            let newTime = max(player.currentTime() - player.currentTime(), CMTime.zero)
            player.seek(to: newTime)
        }) {
        Image(systemName: "backward.end.fill")
                .resizable()
                .frame(width:36, height:32)
                .foregroundColor(.white)
        }
        
        Spacer()
        
        Button(action: {
            if player.rate == 1.0 {
                if rewindIncrement == 1 {
                    player.rate = -1.0
                } else if rewindIncrement == 2 {
                    player.rate = -2.0
                } else if rewindIncrement == 3 {
                    player.rate = -4.0
                } else if rewindIncrement == 4 {
                    player.rate = -8.0
                }
            } else {
                player.rate = 1.0
            }
            if(rewindIncrement == 4){
                rewindIncrement = 1
            } else {
                rewindIncrement += 1
            }
        }) {
            Image(systemName: player.rate < 0 ? "backward.fill" : "backward")
                .resizable()
                .frame(width:54, height:31)
                .foregroundColor(.red)
        }
        
        Button(action: {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width:50, height:50)
                .foregroundColor(.green)
        }
        
        Button(action: {
            if player.rate == 1.0 {
                if fastIncrement == 1 {
                    player.rate = 2.0
                } else if fastIncrement == 2 {
                    player.rate = 4.0
                } else if fastIncrement == 3 {
                    player.rate = 8.0
                }
            } else {
                player.rate = 1.0
            }
            if(fastIncrement == 3){
                fastIncrement = 1
            } else {
                fastIncrement += 1
            }
        })
        {
            Image(systemName: player.rate == 2.0 ? "forward.fill" : "forward")
                .resizable()
                .frame(width:54, height:31)
                .foregroundColor(.blue)
        }
        
        Spacer()
        
        Button(action: {
            endShow = true
        }) {
        Image(systemName: "forward.end.fill")
                .resizable()
                .frame(width:36, height:32)
                .foregroundColor(.black)
        }
        .alert("idk what to put here", isPresented: $endShow) {
                Button("so this button does nothing") {
                    endShow = true
                }
            }
        
    }
    .padding(.horizontal)
    .onPlayPauseCommand {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    .onReceive(player.publisher(for: \.timeControlStatus)) { timeControlStatus in
        isPlaying = timeControlStatus == .playing
    }
    .onReceive(player.publisher(for: \.currentItem)) { item in
        guard let item = item else { return }
        duration = item.duration.seconds
    }
    .onReceive(timer) { _ in
            currentTime = player.currentTime().seconds
        }
}
        .onReceive(player.publisher(for: \.timeControlStatus)) { timeControlStatus in
            isPlaying = timeControlStatus == .playing
        }
        .onReceive(player.publisher(for: \.currentItem)) { item in
            guard let item = item else { return }
            duration = item.duration.seconds
        }
    }

    private func timeString(time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = time < 3600 ? "mm:ss" : "HH:mm:ss"
        return formatter.string(from: date)
    }
}


struct VideoList: View {
    //let videos = ["stw true end", "celeste", "farewell", "dr strangelove", "oceans eleven", "true facts about the mantis shrimp", "undertale concert", "try not to laugh #14", "deja vu", "divine beast, vah medoh"]
    
    let videos = ["stw true end", "farewell"]
    
    var body: some View {
        Text("__mooovies__")
        List(videos, id: \.self) { video in
            Button(action: {
                if let url = Bundle.main.url(forResource: video, withExtension: "mp4") {
                    let videoPlayerView = VideoPlayerView(videoURL: url)
                    let controller = UIHostingController(rootView: videoPlayerView)
                    UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(controller, animated: true, completion: {
                        
                    })
                }
            }) {
                Text(video)
            }
        }
    }
}
