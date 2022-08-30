
import UIKit

open class YYHSegmentedControl: UIControl {
    
    open var slideView: UIImageView!
    
    open var slideViewConfigurationHandler: ((UIImageView) -> Void)?
    
    private(set) open var selectedIndex: Int = 0 { didSet {
        willChangeIndex = selectedIndex
    }}
    open var textFont: UIFont?
    open var titleAlignment: NSTextAlignment = .center
    
    open var controlInset: UIEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    private var titles: [String] = []
    
    private func setUpUI() {
        
        slideView = UIImageView()
        slideView.backgroundColor = UIColor.white
        
        slideView.layer.borderWidth = 1/(UIScreen.main.scale)
        slideView.layer.borderColor = UIColor(rgb: 0xD7D7D7).cgColor
        slideView.layer.shadowColor = UIColor(rgb: 0x000000, alpha: 0.1).cgColor
        slideView.layer.shadowOffset = CGSize(width: 0, height: 1)
        slideView.layer.shadowOpacity = 1
        slideView.layer.shadowRadius = 7
        addSubview(slideView)
        
    }
    
    private class Segment {
        var title: String?
        var isEnabled: Bool
        var attributedTitle: NSAttributedString?
        var titleStateColors: [UInt : UIColor] = [:]
        init(title: String?, isEnabled: Bool) {
            self.title = title
            self.isEnabled = isEnabled
        }
    }
    
    private var segments: [Segment] = []
    private var segmentLabels: [UILabel] = []
    
    public convenience init(titles: [String]) {
        self.init(frame: .zero)
        for i in 0..<titles.count {
            self.insertSegment(withTitle: titles[i], at: i, animated: false)
        }
    }
    
    open func setSelectedIndex(_ index: Int, animated: Bool) {
        guard selectedIndex != index else { return }
        selectedIndex = index
        sendActions(for: .valueChanged)
        self.refreshSegmentState()
        slideView.layer.removeAllAnimations()
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.slideView.center = self.segmentLabels[self.selectedIndex].center
            } completion: { _ in
            }
        } else {
            self.slideView.center = self.segmentLabels[self.selectedIndex].center
        }
    }
    
    private var generalStateStateColors: [UInt : UIColor] = [:]
    
    open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        segments.forEach { $0.titleStateColors[state.rawValue] = color }
        generalStateStateColors[state.rawValue] = color
    }
    
    open func setTitleColor(_ color: UIColor?, for state: UIControl.State, at segment: Int) {
        let seg = segments[segment]
        seg.titleStateColors[state.rawValue] = color
    }
    
    open func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        let seg = Segment(title: title, isEnabled: true)
        seg.titleStateColors = generalStateStateColors
        segments.insert(seg, at: segment)
        insertSegment(segment: segment)
        self.layoutSegments(animated: animated)
    }

    open func removeSegment(at segment: Int, animated: Bool) {
        segments.remove(at: segment)
        removeSegment(segment: segment)
        if segments.count <= selectedIndex {
            setSelectedIndex(segments.count - 1, animated: animated)
        }
        self.layoutSegments(animated: animated)
    }

    open func removeAllSegments() {
        segments.removeAll()
        segmentLabels.forEach { $0.removeFromSuperview() }
        configSegments()
    }
    
    open func setTitle(_ title: String?, forSegmentAt segment: Int) {
        segments[segment].title = title
        refreshSegmentState()
    }
    open func titleForSegment(at segment: Int) -> String? {
        return segments[segment].title
    }
    open func setEnabled(_ enabled: Bool, forSegmentAt segment: Int) {
        segments[segment].isEnabled = enabled
        refreshSegmentState()
    }

    open func isEnabledForSegment(at segment: Int) -> Bool {
        return segments[segment].isEnabled
    }
    
    private func configSegments() {
        segmentLabels.forEach { $0.removeFromSuperview() }
        segments.forEach { seg in
            let label = self.labelWithSegment(seg)
            self.addSubview(label)
            segmentLabels.append(label)
        }
    }
    
    private func insertSegment(segment: Int) {
        let label = labelWithSegment(segments[segment])
        if segment > 0 {
            label.frame = segmentLabels[segment - 1].frame
        }
        addSubview(label)
        segmentLabels.insert(label, at: segment)
    }
    
    private func labelWithSegment(_ segment: Segment) -> UILabel {
        let label = UILabel()
        label.textAlignment = titleAlignment
        if let attributedText = segment.attributedTitle {
            label.attributedText = attributedText
        } else {
            label.text = segment.title
            label.font = self.textFont
            label.textColor = segment.titleStateColors[state.rawValue]
        }
        return label
    }
    
    private func removeSegment(segment: Int) {
        segmentLabels[segment].removeFromSuperview()
        segmentLabels.remove(at: segment)
    }
    
    private func layoutSegments(animated: Bool) {
        let layoutConfiger: () -> Void = {
            let count = self.segments.count
            let w = self.bounds.width
            let h = self.bounds.height - (self.controlInset.top + self.controlInset.bottom)
            
            let itemW = w / CGFloat(count)
            for i in 0..<count {
                self.segmentLabels[i].frame = CGRect(x: itemW * CGFloat(i), y: self.controlInset.top, width: itemW, height: h)
            }
            self.slideView.frame = CGRect(x: itemW * CGFloat(self.selectedIndex) + self.controlInset.left, y: self.controlInset.top, width: itemW - self.controlInset.left - self.controlInset.right, height: h)
            self.slideView.layer.cornerRadius = self.slideView.bounds.height / 2
            self.slideViewConfigurationHandler?(self.slideView)
        }
        if animated {
            UIView.animate(withDuration: 0.2) {
                layoutConfiger()
            }
        } else {
            layoutConfiger()
        }
    }
    
    private func refreshSegmentState() {
        refreshSegmentState(selectedIndex: selectedIndex)
    }
    private func refreshSegmentState(selectedIndex: Int) {
        for i in 0..<segments.count {
            let seg = segments[i]
            let label = segmentLabels[i]
            label.font = textFont
            if !seg.isEnabled {
                label.textColor = seg.titleStateColors[UIControl.State.disabled.rawValue]
            } else if i == selectedIndex {
                label.textColor = seg.titleStateColors[UIControl.State.selected.rawValue]
            } else {
                label.textColor = seg.titleStateColors[UIControl.State.normal.rawValue]
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutSegments(animated: false)
        refreshSegmentState()
    }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        didContinueTracking = false
        sendActions(for: .touchDown)
        return super.beginTracking(touch, with: event)
    }
    private var didContinueTracking: Bool = false
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        didContinueTracking = true
        let point = touch.location(in: self)
        changeSlideView(point: point)
    
        return super.continueTracking(touch, with: event)
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch = touch, !didContinueTracking {
            let point = touch.location(in: self)
            changeSlideView(point: point)
        }
        if let touch = touch, self.bounds.contains(touch.location(in: self)) {
            sendActions(for: .touchUpInside)
        } else {
            sendActions(for: .touchUpOutside)
        }
        if selectedIndex != willChangeIndex {
            selectedIndex = willChangeIndex
            sendActions(for: .valueChanged)
        }
        didContinueTracking = false
    }

    open override func cancelTracking(with event: UIEvent?) {
        sendActions(for: .touchCancel)
        didContinueTracking = false
    }
    /// 用于滑动过程中的记录
    private var willChangeIndex: Int = 0
    private func changeSlideView(point: CGPoint) {
        let itemW = self.bounds.width / CGFloat(segments.count)
        
        var continueIndex = Int(floor(point.x / itemW))
        if continueIndex < 0 {
            continueIndex = 0
        } else if continueIndex >= segments.count {
            continueIndex = segments.count - 1
        }
        if continueIndex != willChangeIndex, segments[continueIndex].isEnabled {
            willChangeIndex = continueIndex
            refreshSegmentState(selectedIndex: willChangeIndex)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.slideView.center = self.segmentLabels[self.willChangeIndex].center
            } completion: { _ in
            }
        }
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
