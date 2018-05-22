## RxSwift(part1)

### Content

1. [Basic](#Basic)
1. [Subject](#Subject)
1. [Combination Operators](#Combination)
1. [Transforming Operators](#Transforming)
1. [Filtering and Conditional Operators](#Filtering_Conditional)
1. [Mathematical and Aggregate Operators](#Mathematical_Aggregate)
1. [Connectable Operators](#Connectable)
1. [Error Handling Operators](#Error_Handling)
1. [Debugging Operators](#Debugging)
1. [Refer](#Refer) 

### <a id='Basic'> Basic  </a>

* Observable

> Observable 。 Observable<Element> 是观察者模式中被观察的对象，相当于一个事件序列 (GeneratorType) ，会向订阅者发送新产生的事件信息。事件信息分为三种：

> * .Next(value) 表示新的事件数据。
> * .Completed 表示事件序列的完结。
> * .Error 同样表示完结，但是代表异常导致的完结。

<!--more-->

```

_ = Observable<String>.create { observerOfString -> Disposable in
        print("This will never be printed")
        observerOfString.on(.next("😬"))
        observerOfString.on(.completed)
        return Disposables.create()
    }

```

* Subscribe

> subscribe 就是一种简便的订阅信号的方法。这里的subscribe函数就是把消息发给观察者。


```

_ = Observable<String>.create { observerOfString in
            print("Observable created")
            observerOfString.on(.next("😉"))
            observerOfString.on(.completed)
            return Disposables.create()
        }
        .subscribe { event in
            print(event)
    }

---------console:---------
next(😉)
completed

```


* empty

> empty 是一个空的序列，它只发送 .Completed 消息。

```

example("empty") {
    let emptySequence: Observable<Int> = empty()
    let subscription = emptySequence
        .subscribe { event in
            print(event)
        }
}
--- empty example ---
Completed

```

* never 

> never 是没有任何元素、也不会发送任何事件的空序列。

```

example("never") {
    let disposeBag = DisposeBag()
    let neverSequence = Observable<String>.never()
    
    let neverSequenceSubscription = neverSequence
        .subscribe { _ in
            print("This will never be printed")
    }
    
    neverSequenceSubscription.disposed(by: disposeBag)
}

--- never example ---

```

* just

> **just** 是只包含一个元素的序列，它会先发送 .Next(value) ，然后发送 .Completed 。

```

example("just") {
    let singleElementSequence = just(32)
    let subscription = singleElementSequence
        .subscribe { event in
            print(event)
        }
}
--- just example ---
Next(32)
Completed

```

* of

> of 可以把一系列元素转换成事件序列。

```

example("of") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .subscribe(onNext: { element in
            print(element)
        })
        .disposed(by: disposeBag)
}

--- of example ---
🐶
🐱
🐭
🐹

```

* from

> from 是把 Swift 中的序列 (SequenceType) 转换成事件序列。 Creates an Observable sequence from a Sequence, such as an Array, Dictionary, or Set.

```

example("from") {
    let disposeBag = DisposeBag()
    
    Observable.from(["🐶", "🐱", "🐭", "🐹"])
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- from example ---
🐶
🐱
🐭
🐹

```

* create

> create 可以通过闭包创建序列，通过 .on(e: Event) 添加事件
> [More info](http://reactivex.io/documentation/operators/create.html)

```

example("create") {
    let disposeBag = DisposeBag()
    
    let myJust = { (element: String) -> Observable<String> in
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }
        
    myJust("🔴")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

--- create example ---
next(🔴)
completed

```

* Range

> Creates an Observable sequence that emits a range of sequential integers and then terminates 
> [More info](http://reactivex.io/documentation/operators/range.html)

```
example("range") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

--- range example ---
next(1)
next(2)
next(3)
next(4)
next(5)
next(6)
next(7)
next(8)
next(9)
next(10)
completed

```

* repeatElement

> 重复元素 
> [More info](http://reactivex.io/documentation/operators/repeat.html)

```

example("repeatElement") {
    let disposeBag = DisposeBag()
    
    Observable.repeatElement("🔴")
        .take(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- repeatElement example ---
🔴
🔴
🔴

```

* generate

> Creates an Observable sequence that generates values for as long as the provided condition evaluates to true

```

example("generate") {
    let disposeBag = DisposeBag()
    
    Observable.generate(
            initialState: 0,
            condition: { $0 < 3 },
            iterate: { $0 + 1 }
        )
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- generate example ---
0
1
2

```

* deferred

> Creates a new Observable sequence for each subscriber
[More info](http://reactivex.io/documentation/operators/defer.html)

```

example("deferred") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let deferredSequence = Observable<String>.deferred {
        print("Creating \(count)")
        count += 1
        
        return Observable.create { observer in
            print("Emitting...")
            observer.onNext("🐶")
            observer.onNext("🐱")
            observer.onNext("🐵")
            return Disposables.create()
        }
    }
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- deferred example ---
Creating 1
Emitting...
🐶
🐱
🐵
Creating 2
Emitting...
🐶
🐱
🐵

```

* error

> Creates an Observable sequence that emits no items and immediately terminates with an error.

```

example("error") {
    let disposeBag = DisposeBag()
        
    Observable<Int>.error(TestError.test)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

--- error example ---
error(test)

```

* doOn

> Invokes a side-effect action for each emitted event and returns (passes through) the original event
[More info](http://reactivex.io/documentation/operators/do.html)

```

example("doOn") {
    let disposeBag = DisposeBag()
    
    Observable.of("🍎", "🍐", "🍊", "🍋")
        .do(onNext: { print("Intercepted:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- doOn example ---
Intercepted: 🍎
🍎
Intercepted: 🍐
🍐
Intercepted: 🍊
🍊
Intercepted: 🍋
🍋
Completed

```

### <a id='Subject'> Subject </a>

```

extension ObservableType {
    
    /**
     Add observer with `id` and print each emitted event.
     - parameter id: an identifier for the subscription.
     */
    func addObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
    
}

```
 
* PublishSubject

> Broadcasts new events to all observers as of their time of the subscription. 

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png "PublishSubject")

```

example("PublishSubject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}

--- PublishSubject example ---
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)

```

* ReplaySubject

> Broadcasts new events to all subscribers, and the specified bufferSize number of previous events to new subscribers.

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png) 

```

example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
--- ReplaySubject example ---
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)

```

* BehaviorSubject

> Broadcasts new events to all subscribers, and the most recent (or initial) value to new subscribers. 

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)

```

example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorSubject(value: "🔴")
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
    
    subject.addObserver("3").disposed(by: disposeBag)
    subject.onNext("🍐")
    subject.onNext("🍊")
}

--- BehaviorSubject example ---
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 3 Event: next(🅱️)
Subscription: 1 Event: next(🍐)
Subscription: 2 Event: next(🍐)
Subscription: 3 Event: next(🍐)
Subscription: 1 Event: next(🍊)
Subscription: 2 Event: next(🍊)
Subscription: 3 Event: next(🍊)

```

* Variable

> Wraps a BehaviorSubject, so it will emit the most recent (or initial) value to new subscribers. And Variable also maintains current value state. Variable will never emit an Error event. However, it will automatically emit a Completed event and terminate on deinit.

```

example("Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("🔴")
    
    variable.asObservable().addObserver("1").disposed(by: disposeBag)
    variable.value = "🐶"
    variable.value = "🐱"
    
    variable.asObservable().addObserver("2").disposed(by: disposeBag)
    variable.value = "🅰️"
    variable.value = "🅱️"
}

--- Variable example ---
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 1 Event: completed
Subscription: 2 Event: completed

```

### <a id='Combination'> Combination Operators </a>

* startWith

> startWith 会在队列开始之前插入一个事件元素。

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/startwith.png)

```

example("startWith") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .startWith("1️⃣")
        .startWith("2️⃣")
        .startWith("3️⃣", "🅰️", "🅱️")
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- startWith example ---
3️⃣
🅰️
🅱️
2️⃣
1️⃣
🐶
🐱
🐭
🐹

```

* merge

> merge 就是 merge 啦，把两个队列按照顺序组合在一起。
[More info](http://reactivex.io/documentation/operators/merge.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/merge.png)

```

example("merge") {
    let disposeBag = DisposeBag()
    
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
    
    Observable.of(subject1, subject2)
        .merge()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject1.onNext("🅰️")
    
    subject1.onNext("🅱️")
    
    subject2.onNext("①")
    
    subject2.onNext("②")
    
    subject1.onNext("🆎")
    
    subject2.onNext("③")
}

--- merge example ---
🅰️
🅱️
①
②
🆎
③

```

* zip

> zip 人如其名，就是合并两条队列用的，不过它会等到两个队列的元素一一对应地凑齐了之后再合并
[More info](http://reactivex.io/documentation/operators/zip.html)


 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/zip.png)

```

example("zip") {
    let disposeBag = DisposeBag()
    
    let stringSubject = PublishSubject<String>()
    let intSubject = PublishSubject<Int>()
    
    Observable.zip(stringSubject, intSubject) { stringElement, intElement in
        "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    stringSubject.onNext("🅰️")
    stringSubject.onNext("🅱️")
    
    intSubject.onNext(1)
    
    intSubject.onNext(2)
    
    stringSubject.onNext("🆎")
    intSubject.onNext(3)
}

--- zip example ---
🅰️ 1
🅱️ 2
🆎 3

```

* combineLatest

> 如果存在两条事件队列，需要同时监听，那么每当有新的事件发生的时候，combineLatest 会将每个队列的最新的一个元素进行合并
[More info](http://reactivex.io/documentation/operators/combinelatest.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)

```

example("combineLatest") {
    let disposeBag = DisposeBag()
    
    let stringSubject = PublishSubject<String>()
    let intSubject = PublishSubject<Int>()
    
    Observable.combineLatest(stringSubject, intSubject) { stringElement, intElement in
            "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    stringSubject.onNext("🅰️")
    
    stringSubject.onNext("🅱️")
    intSubject.onNext(1)
    
    intSubject.onNext(2)
    
    stringSubject.onNext("🆎")
}

--- combineLatest example ---
🅱️ 1
🅱️ 2
🆎 2

```

* switchLatest

> 当你的事件序列是一个事件序列的序列 (Observable<Observable<T>>) 的时候，（可以理解成二维序列？），可以使用 switch 将序列的序列平铺成一维，并且在出现新的序列的时候，自动切换到最新的那个序列上。和 merge 相似的是，它也是起到了将多个序列『拍平』成一条序列的作用。
> Transforms the elements emitted by an Observable sequence into Observable sequences, and emits elements from the most recent inner Observable sequence


 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/switch.png)

```

example("switchLatest") {
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "⚽️")
    let subject2 = BehaviorSubject(value: "🍎")
    
    let variable = Variable(subject1)
        
    variable.asObservable()
        .switchLatest()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject1.onNext("🏈")
    subject1.onNext("🏀")
    
    variable.value = subject2
    
    subject1.onNext("⚾️")
    
    subject2.onNext("🍐")
}

--- switchLatest example ---
⚽️
🏈
🏀
🍎
🍐

```

### <a id='Transforming'> Transforming Operators </a>

* map

> 就是对每个元素都用函数做一次转换，挨个映射一遍

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/map.png)

```

example("map") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3)
        .map { $0 * $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}


--- map example ---
1
4
9

```

* flatMap

> 

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/flatmap.png)

```

example("flatMap and flatMapLatest") {
    let disposeBag = DisposeBag()
    
    struct Player {
        var score: Variable<Int>
    }
    
    let 👦🏻 = Player(score: Variable(80))
    let 👧🏼 = Player(score: Variable(90))
    
    let player = Variable(👦🏻)
    
    player.asObservable()
        .flatMap { $0.score.asObservable() } // Change flatMap to flatMapLatest and observe change in printed output
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    👦🏻.score.value = 85
    
    player.value = 👧🏼
    
    👦🏻.score.value = 95 // Will be printed when using flatMap, but will not be printed when using flatMapLatest
    
    👧🏼.score.value = 100
}

```

* scan

> scan 它会把每次的运算结果累积起来，作为下一次运算的输入值。
[More info](http://reactivex.io/documentation/operators/scan.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/scan.png)

```

example("scan") {
    let disposeBag = DisposeBag()
    
    Observable.of(10, 100, 1000)
        .scan(1) { aggregateValue, newValue in
            aggregateValue + newValue
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}


--- scan example ---
11
111
1111

```

### <a id='Filter_Conditional'> Filtering and Conditional Operators </a>

* filter

> filter 只会让符合条件的元素通过。
[More info](http://reactivex.io/documentation/operators/filter.html)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/filter.png)

```

example("filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(
        "🐱", "🐰", "🐶",
        "🐸", "🐱", "🐰",
        "🐹", "🐸", "🐱")
        .filter {
            $0 == "🐱"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- filter example ---
🐱
🐱
🐱

```

* distinctUntilChanged

> 会过滤掉重复的事件[More info](http://reactivex.io/documentation/operators/distinct.html)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/distinct.png)


```

example("distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
        .distinctUntilChanged()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- distinctUntilChanged example ---
🐱
🐷
🐱
🐵
🐱

```

* elementAt

> 指定index位置元素的事件
[More info](http://reactivex.io/documentation/operators/elementat.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)

```

example("elementAt") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .elementAt(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- elementAt example ---
🐸

```

* single

> Emits only the first element (or the first element that meets a condition) emitted by an Observable sequence. Will throw an error if the Observable sequence does not emit exactly one element.

```

example("single") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- single example ---
🐱
Received unhandled error: Filtering_and_Conditional_Operators.xcplaygroundpage:69:__lldb_expr_72 -> Sequence contains more than one element.

example("single with conditions") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single { $0 == "🐸" }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    Observable.of("🐱", "🐰", "🐶", "🐱", "🐰", "🐶")
        .single { $0 == "🐰" }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single { $0 == "🔵" }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

--- single with conditions example ---
next(🐸)
completed
next(🐰)
error(Sequence contains more than one element.)
error(Sequence doesn't contain any elements.)

```

* take

> take 只获取序列中的前 n 个事件，在满足数量之后会自动 .Completed
[More info](http://reactivex.io/documentation/operators/take.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/take.png)


```

example("take") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .take(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- take example ---
🐱
🐰
🐶

```

* takeLast

> takeLast 只获取序列中的后 n 个事件
[More info](http://reactivex.io/documentation/operators/takelast.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takelast.png)

```

example("takeLast") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .takeLast(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}


--- takeLast example ---
🐸
🐷
🐵

```

* takeWhile

> Emits elements from the beginning of an Observable sequence as long as the specified condition evaluates to true
[More info](http://reactivex.io/documentation/operators/takewhile.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takewhile.png)

```

example("takeWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .takeWhile { $0 < 4 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- takeWhile example ---
1
2
3

```

* takeUntil

> 直到 [More info](http://reactivex.io/documentation/operators/takeuntil.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takeuntil.png)

```

example("takeUntil") {
    let disposeBag = DisposeBag()
    
    let sourceSequence = PublishSubject<String>()
    let referenceSequence = PublishSubject<String>()
    
    sourceSequence
        .takeUntil(referenceSequence)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    sourceSequence.onNext("🐱")
    sourceSequence.onNext("🐰")
    sourceSequence.onNext("🐶")
    
    referenceSequence.onNext("🔴")
    
    sourceSequence.onNext("🐸")
    sourceSequence.onNext("🐷")
    sourceSequence.onNext("🐵")
}

--- takeUntil example ---
next(🐱)
next(🐰)
next(🐶)
completed

```

* skip

> 跳过 [More info](http://reactivex.io/documentation/operators/skip.html)


![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skip.png)

```

example("skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .skip(2)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- skip example ---
🐶
🐸
🐷
🐵

```

* skipWhile

> 条件跳过
[More info](http://reactivex.io/documentation/operators/skipwhile.html)
 
 ![](http://reactivex.io/documentation/operators/images/skipWhile.c.png)

```

example("skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .skipWhile { $0 < 4 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
--- skipWhile example ---
4
5
6


```

* skipWhileWithIndex

> 带index条件的跳过
> 

```

example("skipWhileWithIndex") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .skipWhileWithIndex { element, index in
            index < 3
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- skipWhileWithIndex example ---
🐸
🐷
🐵

```

* skipUntil

> 跳过, 直到...
[More info](http://reactivex.io/documentation/operators/skipuntil.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skipuntil.png)

```

example("skipUntil") {
    let disposeBag = DisposeBag()
    
    let sourceSequence = PublishSubject<String>()
    let referenceSequence = PublishSubject<String>()
    
    sourceSequence
        .skipUntil(referenceSequence)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    sourceSequence.onNext("🐱")
    sourceSequence.onNext("🐰")
    sourceSequence.onNext("🐶")
    
    referenceSequence.onNext("🔴")
    
    sourceSequence.onNext("🐸")
    sourceSequence.onNext("🐷")
    sourceSequence.onNext("🐵")
}

--- skipUntil example ---
🐸
🐷
🐵

```

### <a id='Mathematial_Aggregate'> Mathematical and Aggregate Operators </a>

* toArray

> Converts an Observable sequence into an array, emits that array as a new single-element Observable sequence, and then terminates
[More info](http://reactivex.io/documentation/operators/to.html)

 ![](http://reactivex.io/documentation/operators/images/to.c.png)

```

example("toArray") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .toArray()
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

--- toArray example ---
next([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
completed

```

* reduce

> Begins with an initial seed value, and then applies an accumulator closure to all elements emitted by an Observable sequence, and returns the aggregate result as a single-element Observable sequence
[More info](http://reactivex.io/documentation/operators/reduce.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/reduce.png)


```

example("reduce") {
    let disposeBag = DisposeBag()
    
    Observable.of(10, 100, 1000)
        .reduce(1, accumulator: +)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- reduce example ---
1111

```

* concat

> concat 可以把多个事件序列合并起来。
[More info](http://reactivex.io/documentation/operators/concat.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/concat.png)


```

example("concat") {
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "🍎")
    let subject2 = BehaviorSubject(value: "🐶")
    
    let variable = Variable(subject1)
    
    variable.asObservable()
        .concat()
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    subject1.onNext("🍐")
    subject1.onNext("🍊")
    
    variable.value = subject2
    
    subject2.onNext("I would be ignored")
    subject2.onNext("🐱")
    
    subject1.onCompleted()
    
    subject2.onNext("🐭")
}

--- concat example ---
next(🍎)
next(🍐)
next(🍊)
next(🐱)
next(🐭)

```

### <a id='Connectable'> Connectable Operators </a>

> without connectable operators

```

func sampleWithoutConnectableOperators() {
    printExampleHeader(#function)
    
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    
    _ = interval
        .subscribe(onNext: { print("Subscription: 1, Event: \($0)") })
    
    delay(5) {
        _ = interval
            .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
    }
}

sampleWithoutConnectableOperators()


--- sampleWithoutConnectableOperators() example ---
Subscription: 1, Event: 0
Subscription: 1, Event: 1
Subscription: 1, Event: 2
Subscription: 1, Event: 3
Subscription: 1, Event: 4
Subscription: 1, Event: 5
Subscription: 2, Event: 0
Subscription: 1, Event: 6
Subscription: 2, Event: 1
Subscription: 1, Event: 7
Subscription: 2, Event: 2

```

* publish

> 将事件源转换成可以连接的序列
> Converts the source Observable sequence into a connectable sequence

```

func sampleWithPublish() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .publish()
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

sampleWithPublish()


--- sampleWithPublish() example ---
Subscription 1:, Event: 0
Subscription 1:, Event: 1
Subscription 2:, Event: 1
Subscription 1:, Event: 2
Subscription 2:, Event: 2
Subscription 1:, Event: 3
Subscription 2:, Event: 3
Subscription 3:, Event: 3
Subscription 1:, Event: 4
Subscription 2:, Event: 4
Subscription 3:, Event: 4
Subscription 1:, Event: 5
Subscription 2:, Event: 5
Subscription 3:, Event: 5
Subscription 1:, Event: 6
Subscription 2:, Event: 6
Subscription 3:, Event: 6
Subscription 1:, Event: 7
Subscription 2:, Event: 7
Subscription 3:, Event: 7
Subscription 1:, Event: 8
Subscription 2:, Event: 8
Subscription 3:, Event: 8

```

* replay

> Converts the source Observable sequence into a connectable sequence, and will replay bufferSize number of previous emissions to each new subscriber

```

func sampleWithReplayBuffer() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .replay(5)
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(8) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}
sampleWithReplayBuffer()

--- sampleWithReplayBuffer() example ---
Subscription 1:, Event: 0
Subscription 2:, Event: 0
Subscription 1:, Event: 1
Subscription 2:, Event: 1
Subscription 1:, Event: 2
Subscription 2:, Event: 2
Subscription 1:, Event: 3
Subscription 2:, Event: 3
Subscription 1:, Event: 4
Subscription 2:, Event: 4
Subscription 3:, Event: 0
Subscription 3:, Event: 1
Subscription 3:, Event: 2
Subscription 3:, Event: 3
Subscription 3:, Event: 4
Subscription 1:, Event: 5
Subscription 2:, Event: 5
Subscription 3:, Event: 5

```

* multicast

> Converts the source Observable sequence into a connectable sequence, and broadcasts its emissions via the specified subject.

```

func sampleWithMulticast() {
    printExampleHeader(#function)
    
    let subject = PublishSubject<Int>()
    
    _ = subject
        .subscribe(onNext: { print("Subject: \($0)") })
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .multicast(subject)
    
    _ = intSequence
        .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 3:, Event: \($0)") })
    }
}
sampleWithMulticast()

--- sampleWithMulticast() example ---
Subject: 0
	Subscription 1:, Event: 0
Subject: 1
	Subscription 1:, Event: 1
	Subscription 2:, Event: 1
Subject: 2
	Subscription 1:, Event: 2
	Subscription 2:, Event: 2
Subject: 3
	Subscription 1:, Event: 3
	Subscription 2:, Event: 3
	Subscription 3:, Event: 3
Subject: 4
	Subscription 1:, Event: 4
	Subscription 2:, Event: 4
	Subscription 3:, Event: 4
Subject: 5
	Subscription 1:, Event: 5
	Subscription 2:, Event: 5
	Subscription 3:, Event: 5

```

```
        效果同 
        let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .publish()
    intSequence.subscribe(onNext: { (int) in
      subject.onNext(int)
    })

```

### <a id='Error_Handling'> Error Handling Operators </a>

* catchErrorJustReturn

> Recovers from an Error event by returning an Observable sequence that emits a single element and then terminates
[More info](http://reactivex.io/documentation/operators/catch.html)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)

```

example("catchErrorJustReturn") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    
    sequenceThatFails
        .catchErrorJustReturn("😊")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
    sequenceThatFails.onNext("🔴")
    sequenceThatFails.onError(TestError.test)
}

--- catchErrorJustReturn example ---
next(😬)
next(😨)
next(😡)
next(🔴)
next(😊)
completed

```

* catchError

> Recovers from an Error event by switching to the provided recovery Observable sequence
[More info](http://reactivex.io/documentation/operators/catch.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)

```

example("catchError") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    let recoverySequence = PublishSubject<String>()
    
    sequenceThatFails
        .catchError {
            print("Error:", $0)
            return recoverySequence
        }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
    sequenceThatFails.onNext("🔴")
    sequenceThatFails.onError(TestError.test)
    
    recoverySequence.onNext("😊")
}

--- catchError example ---
next(😬)
next(😨)
next(😡)
next(🔴)
Error: test
next(😊)

```

* retry

> Recovers repeatedly Error events by resubscribing to the Observable sequence, indefinitely.
> [More info](http://reactivex.io/documentation/operators/retry.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)

```

example("retry") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count == 1 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- retry example ---
🍎
🍐
🍊
Error encountered
🍎
🍐
🍊
🐶
🐱
🐭

```

* retry(_:)

> Recovers repeatedly from Error events by resubscribing to the Observable sequence, up to maxAttemptCount number of retries.
[More info](http://reactivex.io/documentation/operators/retry.html)

 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)

```

example("retry maxAttemptCount") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count < 5 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- retry maxAttemptCount example ---
🍎
🍐
🍊
Error encountered
🍎
🍐
🍊
Error encountered
🍎
🍐
🍊
Error encountered

```

### <a id='Debugging'> Debugging Operators </a>

* debug 

> Prints out all subscriptions, events, and disposals.

```

example("debug") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count < 5 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry(3)
        .debug()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

--- debug example ---
2017-05-10 16:06:09.532: Debugging_Operators.xcplaygroundpage:42 (__lldb_expr_142) -> subscribed
2017-05-10 16:06:09.536: Debugging_Operators.xcplaygroundpage:42 (__lldb_expr_142) -> Event next(🍎)
🍎
2017-05-10 16:06:09.537: Debugging_Operators.xcplaygroundpage:42 (__lldb_expr_142) -> Event next(🍐)
🍐

```

* RxSwift.Resources.total

> Provides a count of all Rx resource allocations, which is useful for detecting leaks during development

```

example("RxSwift.Resources.total") {
    print(RxSwift.Resources.total)
    
    let disposeBag = DisposeBag()
    
    print(RxSwift.Resources.total)
    
    let variable = Variable("🍎")
    
    let subscription1 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    let subscription2 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    subscription1.dispose()
    
    print(RxSwift.Resources.total)
    
    subscription2.dispose()
    
    print(RxSwift.Resources.total)
}
    
print(RxSwift.Resources.total)

--- RxSwift.Resources.total example ---
0
2
🍎
8
🍎
10
9
8
0

```

### <a id='Refer'> Refer </a>

[入坑指南参考](https://blog.callmewhy.com/2015/09/21/rxswift-getting-started-0/)

[RxSwift GitHub](https://github.com/ReactiveX/RxSwift)

[RxMarbles](http://rxmarbles.com)