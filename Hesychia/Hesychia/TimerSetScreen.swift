//
//  TimerSetScreen.swift
//  Hesychia
//
//  Created by Seth Phillips on 4/9/19.
//
import Foundation
import UIKit
import AVFoundation

var rel_val = 1560.0

class TimerSetScreen: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()

    
    // Proto-settings
    var duckOthers = false
    var darkMode = false
    //    Set the status bar font color depending on theme
    //    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var datepicker: UIDatePicker!
    @IBOutlet weak var templabel: UILabel!
    @IBOutlet weak var pwr_btn: PowerButton!
    @IBOutlet weak var start_stop_btn: UIButton!
    @IBOutlet weak var abs_rel_state: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datepicker.setValue(UIColor.white, forKey: "textColor")
        datepicker.countDownDuration = rel_val
        
        handleRouteChange()
        
        //Monitor for changes in the audio routing, call routeChangeMonitor(which calls handleRouteChange)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(routeChangeMonitor(notification:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil)
        
        // Set audio session properties
        do {
            if duckOthers {
                try audioSession.setCategory(
                    AVAudioSession.Category.playback,
                    options: AVAudioSession.CategoryOptions.duckOthers)
            } else {
                try audioSession.setCategory(
                    AVAudioSession.Category.playback)
            }
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }
    }
    
    @objc func routeChangeMonitor(notification: Notification) {
        handleRouteChange()
    }
    
    // Triggered on load and when the system notifies Hesychia of a route change,
    // This function checks the current audio route to determine whether headphones
    // are plugged in.
    func handleRouteChange() {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for description in currentRoute.outputs {
            switch description.portType {
            case AVAudioSession.Port.headphones:
                DispatchQueue.main.async {
                    self.templabel.text = "headphones"
                }
            case AVAudioSession.Port.usbAudio:
                DispatchQueue.main.async {
                    self.templabel.text = "usb"
                }
            case AVAudioSession.Port.builtInSpeaker:
                DispatchQueue.main.async {
                    self.templabel.text = "speaker"
                }
            default:
                break
            }
        }
    }
    
    
    @IBAction func pwr_btn_pressed(_ sender: Any) {
        ring_alarm()
    }
    
    // Switches the datepicker between absolute (Time) mode or
    // relative (Countdown timer) mode
    @IBAction func abs_rel_switched(_ sender: UISegmentedControl) {
        switch abs_rel_state.selectedSegmentIndex{
        case 0:
            datepicker.datePickerMode = UIDatePicker.Mode.time
        case 1:
            datepicker.datePickerMode = UIDatePicker.Mode.countDownTimer
            datepicker.countDownDuration = rel_val
        default:
            break
        }
    }
    
    func ring_alarm() {
        // Set audio player properties
        do {
            if let wavURL = Bundle.main.path(forResource: "sunnyday", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: wavURL))
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            }
        } catch let error {
            print("Cant play audio, error \(error.localizedDescription)")
        }
    }
}

// Defines a control for the power button to give it rounded corners
@IBDesignable class PowerButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
        layer.allowsEdgeAntialiasing = true
    }
}
