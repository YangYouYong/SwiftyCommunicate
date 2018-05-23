# Basic

#### 一,[初见_参考 The Swift Programming Language](https://numbbbbb.gitbooks.io/-the-swift-programming-language-/content/chapter1/02_a_swift_tour.html)
##### 1.1, [Swift 强类型](http://www.swiftmi.com/swiftbook_cn/chapter2/01_The_Basics.html)


#### 二, MARK Tips
<!--more-->
#### 1.函数
* tips1 函数类型

```
func sayHello(personName: String) -> String {
    let greeting = "Hello, " + personName + "!"
    return greeting
}

```
* tips2 可变参数

```
func arithmeticMean(numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
```
* tips3 输入输出参数

```
func swapTwoInts(inout a: Int, inout b: Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}
```
#### 2. 闭包
* tips1 尾随闭包

```
func someFunctionThatTakesAClosure(closure: () -> ()) {
    // 函数体部分
}

// 以下是不使用尾随闭包进行函数调用
someFunctionThatTakesAClosure({
    // 闭包主体部分
})

// 以下是使用尾随闭包进行函数调用
someFunctionThatTakesAClosure() {
  // 闭包主体部分
}

```
* tips2 闭包为引用类型

#### 3.属性
* tips1 setter&getter 在属性内实现get 和set  
* tips2 属性观察器 自带willSet 和didSet 属性观察器

#### 4.继承
* tips1 重写, **override** 重载基类方法
* tips2 防止重写  ,添加 **final** 修饰

#### 5.构造
* tips1 便利构造器 **init**关键字之前放置**convenience**关键字
* tips2 必要构造器 **required** 表明所有该类的子类都必须实现该构造器
* tips3 通过闭包来设置属性

```
let someProperty: SomeType = {
        // 在这个闭包中给 someProperty 创建一个默认值
        // someValue 必须和 SomeType 类型相同
        return someValue
        }()     
```
#### 6.析构
* tips1 析构函数 **deinit** 

#### 7.引用计数
* tips1 闭包引用self 申明为无主引用

```
lazy var someClosure: () -> String = {
    [unowned self] in
    // closure body goes here
}
```

* tips2 闭包引用变量 申明为weak类型

#### 8.可选链
* tips1 可为空值的对象

```
var optionalString:String? = nil

```

#### 9.类型转换 (swift 多态)
* tips1 向下转型 用as? 和as! 
	as? 为可选转型,可能转换失败 
	as!为强制转型,转换不成功则崩溃
* tips2 向上转型用is
* tips3 AnyObject 任意对象类型 类似id
* tips4 Any 任意类型(可能为值类型,enum 和struct)

#### 10.扩展 & 协议
* tips1 关键字**extension** 结构体和枚举也可以扩展
* tips2 协议关键字**protocol** 结构体和枚举也可以遵循协议 实现协议

```
protocol SomeProtocol {
    // 协议内容
}
struct SomeStructure: FirstProtocol, AnotherProtocol {
    // 结构体内容
}
class SomeClass: SomeSuperClass, FirstProtocol, AnotherProtocol {
    // 类的内容
}

```

* tips3 关于协议 Swift是一门面向协议的语言(POP)不同于Objective-C的面向对象语言(OOP) 参考WWDC2015 视频[Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015-408/)

#### 11. 泛型
* tips1 泛型函数 泛型可以理解为一种对共有代码的抽象(个人理解)

```
泛型函数
func swapTwoValues<T>(inout a: T, inout b: T) {
    let temporaryA = a
    a = b
    b = temporaryA
}

```
```
类型约束
func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U) {
    // function body goes here
}

```

#### 12.访问控制 (关键字合集)
* tips1 internal public private
* tips2 mutating 关键字  增加该关键字实例方法可以修改值类型的属性.[参考文章](http://www.tuicool.com/articles/NRFzYf)
* tips3 Guard语句 (Swift2.0 新特性)
* tips4 fileprivate、open (Swift3.0 新增)
* tips5 @discardableResult(Swift3.0 新增)
* tips6 associatedtype 泛型protocol (Swift3.0 新增)

	官方解释: 与if语句相同的是，guard也是基于一个表达式的布尔值去判断一段代码是否该被执行。与if语句不同的是，guard只有在条件不满足的时候才会执行这段代码。你可以把guard近似的看做是Assert，但是你可以优雅的退出而非崩溃。

```
常规处理
func fooBinding(x: Int?) {
    if let x = x where x > 0 {
        // 使用x
        x.description
    }

    // 如果值不符合条件判断，就执行下面的代码
}

```
```
guard 实现
func fooBinding(x: Int?) {
    guard let x = x where x > 0 else {
        // 变量不符合条件判断时，执行下面代码
        return
    }

    // 符合条件使用x
    x.description
}

```

* tips4 lazy 懒加载

```
属性
lazy var first = NSArray(objects: "1","2")
```
```
闭包
lazy var second:String = {
        return "second"
        }()
```

