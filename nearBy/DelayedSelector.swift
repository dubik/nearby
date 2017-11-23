//
// Created by Sergiy Dubovik on 27/11/2017.
// Copyright (c) 2017 Sergiy Dubovik. All rights reserved.
//

import Foundation

/// Executes specified selector with a delay. To execute call "start()", each following call will delay
/// selector execution by timeIntervel specified in constructor. Useful when you want user to type something
/// and not to execute logic immediately and wait until user is done typing.
class DelayedSelector: NSObject {
    private var timer: Timer!
    private var timeInterval: TimeInterval!
    private var target: Any!
    private var selector: Selector!

    init(timeInterval: TimeInterval, target: Any, selector: Selector) {
        self.timeInterval = timeInterval
        self.target = target
        self.selector = selector
    }

    deinit {
        timer?.invalidate()
    }
    
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: false)
    }
}
