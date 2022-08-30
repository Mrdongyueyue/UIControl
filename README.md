# UIControl
当UI设计了一个特殊样式的交互控件，而使用UIKit提供的`UIButton、UISegmentedControl、UISlider`等无法满足需求时，需要自定义控件来实现。此类控件需要提供如下功能：
#### 1.最基本的功能
- 接收点击事件
- 点击事件的回调

#### 2.进一步的功能
- 区分事件的类型（touchUpInside、valueChanged）等
- 根据不同类型的事件进行回调

#### 3.以及更进一步的
- 良好的交互体验
- 良好的代码调用体验

此时，可以选择继承自`UIView`或`UIControl`
继承自`UIView`当然也能实现上述的3点，但较为复杂，相比之下`UIControl`提供的
```swift
open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
open func endTracking(_ touch: UITouch?, with event: UIEvent?)
open func cancelTracking(with event: UIEvent?)
```
可以有效的区手势类型和操作区域，`UIControl`无疑是更佳的选择。
```swift
open func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event)
open func sendActions(for controlEvents: UIControl.Event)
```
可以便捷的根据不同类型的事件进行回调并有良好的代码调用体验

实现思路就是在tracking方法中监听手指位置更新视图，并发送适当的事件
```swift
open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    sendActions(for: .touchDown)
    return super.beginTracking(touch, with: event)
}
open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    // 监听手指移动范围，在手指按压后的持续拖拽做出响应，更新视图
    // 对外可发送touchDragInside, touchDragOutside事件，通常用不到
    return super.continueTracking(touch, with: event)
}
open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    if let touch = touch, self.bounds.contains(touch.location(in: self)) {
        sendActions(for: .touchUpInside)
    } else {
        sendActions(for: .touchUpOutside)
    }
    if change {
        sendActions(for: .valueChanged)
    }
}
open override func cancelTracking(with event: UIEvent?) {
    sendActions(for: .touchCancel)
}
```

参考：[TOSegmentedControl](https://github.com/TimOliver/TOSegmentedControl)
