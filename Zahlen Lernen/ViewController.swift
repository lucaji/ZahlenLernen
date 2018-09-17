//
//  ViewController.swift
//  Zahlen Lernen
//
//  Created by lookaji on 14/09/2017.
//  Copyright © 2017 lookaji. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private static var DieZahlContext = 0

    static let locale = Locale(identifier: "de")
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    @objc dynamic var DieZahl = NSNumber(value: 10)
    var utteranceRate : Float = 0.5
    var spelledOut : String = ""
    
    static let spelloutNumberFormatter: NumberFormatter = {
        let formatters = NumberFormatter()
        formatters.locale = locale
        formatters.numberStyle = .spellOut
        return formatters
    }()
    
    static let decimalNumberFormatter: NumberFormatter = {
        let formatterd = NumberFormatter()
        formatterd.numberStyle = .currency
        formatterd.alwaysShowsDecimalSeparator = true
        return formatterd
    }()

    
    @IBOutlet weak var spelledOutTextView: UITextView!
    
    func spellOutInt(number: Int32) -> String {
        return ViewController.spelloutNumberFormatter.string(for: number) ?? ""

    }
    
    func regenerateRandom() -> (Int32) {
        return Int32(arc4random_uniform(1000000))
    }
    
    
    @IBAction func utteranceRateSliderAction(_ sender: UISlider) {
        utteranceRate = sender.value
    }
    @IBAction func regenerateButtonAction(_ sender: Any) {
        DieZahl = NSNumber(value: regenerateRandom())
        
    }
    @IBOutlet weak var auftragSlider: UISlider!
    @IBAction func auftragSliderAction(_ sender: UISlider) {
        DieZahl =  NSNumber(value: Int32(powf(10.0,sender.value)))
    }
    
    @IBOutlet weak var zahlenTextField: UITextField!
    
    @IBOutlet weak var auftragStepper: UIStepper!
    @IBAction func auftragStepperValueChanged(_ sender: UIStepper) {
        DieZahl = NSNumber(value: Int32(sender.value))
        logarithmicilySetSlider()
    }
    @IBAction func sagmalButtonAction(_ sender: Any) {
        if (synth.isSpeaking) {
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        myUtterance = AVSpeechUtterance(string: spelledOut)
        myUtterance.rate = utteranceRate
        synth.speak(myUtterance)
    }
    
    func logarithmicilySetSlider() -> () {
        let flo = DieZahl.floatValue
        auftragSlider.value = powf(10.0, flo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zahlenTextField.layer.cornerRadius = 8.0
        zahlenTextField.clipsToBounds = true
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &ViewController.DieZahlContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if let newValue = change?[.newKey] as? NSNumber {
            let intVal = newValue.int32Value

            zahlenTextField.text = ViewController.decimalNumberFormatter.string(for: intVal)
            spelledOut = spellOutInt(number: intVal)
            spelledOutTextView.text = spelledOut
            
            auftragStepper.value = newValue.doubleValue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver(self, forKeyPath: #keyPath(DieZahl), options: [.new], context: &ViewController.DieZahlContext)

        DieZahl = NSNumber(value: regenerateRandom())
        logarithmicilySetSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver(self, forKeyPath: #keyPath(DieZahl), context: &ViewController.DieZahlContext)
    }

}

