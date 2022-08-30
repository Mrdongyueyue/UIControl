
import UIKit

open class YYHVideoSlider: UIControl {

    public enum SlidState {
        case normal
        case touching
    }
    
    private struct StateConfig {
        var progressColor: UIColor?
        var backgroundColor: UIColor?
        var thumbColor: UIColor?
        var thumbSize: CGSize = .zero
    }
    
    private lazy var colorsForState: [SlidState : StateConfig] = [:]
    private(set) open var currentState: SlidState = .normal
    open var value: Float = 0 { didSet {
        valueDidChange()
    }}
    open var minimumValue: Float = 0 { didSet {
        valueDidChange()
    }}
    open var maximumValue: Float = 0 { didSet {
        valueDidChange()
    }}
    open var isHiddenThumbInNormal: Bool = false
    open lazy var thumbImageView: UIImageView = UIImageView()
    private lazy var progressView: UIProgressView = UIProgressView(progressViewStyle: .bar)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpUI() {
        addSubview(progressView)
        addSubview(thumbImageView)
//        valueDidChange()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        progressView.bounds = self.bounds
        progressView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        thumbImageView.center = CGPoint(x: CGFloat(progressView.progress) * progressView.bounds.width, y: self.bounds.midY)
    }
    
    open func setProgressColor(_ color: UIColor?, for state: SlidState) {
        var config: StateConfig
        if let cfg = colorsForState[state] {
            config = cfg
        } else {
            config = StateConfig()
        }
        config.progressColor = color
        colorsForState[state] = config
        stateDidChange()
    }
    
    open func setBackgroundColor(_ color: UIColor?, for state: SlidState) {
        var config: StateConfig
        if let cfg = colorsForState[state] {
            config = cfg
        } else {
            config = StateConfig()
        }
        config.backgroundColor = color
        colorsForState[state] = config
        stateDidChange()
    }
    
    open func setThumbColor(_ color: UIColor?, for state: SlidState) {
        var config: StateConfig
        if let cfg = colorsForState[state] {
            config = cfg
        } else {
            config = StateConfig()
        }
        config.thumbColor = color
        colorsForState[state] = config
        stateDidChange()
    }
    
    open func setThumbSize(_ size: CGSize, for state: SlidState) {
        var config: StateConfig
        if let cfg = colorsForState[state] {
            config = cfg
        } else {
            config = StateConfig()
        }
        config.thumbSize = size
        colorsForState[state] = config
        stateDidChange()
    }
    
    private func stateDidChange() {
        var config = colorsForState[currentState]
        if config == nil {
            config = colorsForState[.normal]
        }
        progressView.progressTintColor = config?.progressColor
        progressView.trackTintColor = config?.backgroundColor
        thumbImageView.backgroundColor = config?.thumbColor
        if isHiddenThumbInNormal && currentState == .normal {
            thumbImageView.isHidden = true
        } else {
            thumbImageView.isHidden = false
        }
        let size = config?.thumbSize ?? .zero
        thumbImageView.frame = CGRect(
            x: CGFloat(progressView.progress) * self.bounds.width - (size.width * 0.5),
            y: (self.bounds.height - size.width) * 0.5,
            width: size.width,
            height: size.height)
        thumbImageView.layer.cornerRadius = size.width * 0.5
    }
    
    private func valueDidChange() {
        progressView.progress = value / maximumValue
        thumbImageView.center = CGPoint(x: CGFloat(progressView.progress) * progressView.bounds.width, y: thumbImageView.center.y)
    }
    
    private var beginPoint: CGPoint = .zero
    private var beginValue: Float = 0
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        didContinueTracking = false
        beginPoint = touch.location(in: self)
        beginValue = self.value
        sendActions(for: .touchDown)
        self.currentState = .touching
        stateDidChange()
        return super.beginTracking(touch, with: event)
    }
    private var didContinueTracking: Bool = false
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        didContinueTracking = true
        let point = touch.location(in: self)
        var value = Float((point.x - beginPoint.x) / self.bounds.width) * maximumValue + beginValue
        if value < minimumValue {
            value = minimumValue
        }
        if value > maximumValue {
            value = maximumValue
        }
        self.value = value
        sendActions(for: .valueChanged)
        return super.continueTracking(touch, with: event)
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if let touch = touch, !didContinueTracking {
            let point = touch.location(in: self)
            var value = Float((point.x - beginPoint.x) / self.bounds.width) * maximumValue + beginValue
            if value < minimumValue {
                value = minimumValue
            }
            if value > maximumValue {
                value = maximumValue
            }
            self.value = value
        }
        if let touch = touch, self.bounds.contains(touch.location(in: self)) {
            sendActions(for: .touchUpInside)
        } else {
            sendActions(for: .touchUpOutside)
        }
        sendActions(for: .valueChanged)
        self.currentState = .normal
        stateDidChange()
        didContinueTracking = false
    }

    open override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        self.currentState = .normal
        stateDidChange()
        sendActions(for: .touchCancel)
        didContinueTracking = false
    }
    

}
