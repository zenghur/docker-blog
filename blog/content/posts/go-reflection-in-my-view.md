---
title: "我所理解的反射"
date: 2019-10-13
categories: ["Go"]
toc: true
---

## Interface

谈到反射离不开interface。Russ Cox写了一篇关于interface的[文章](https://research.swtch.com/interfaces)，但是Go已经在[1.5](https://golang.org/doc/go1.5)版本实现了[自举](https://en.wikipedia.org/wiki/Bootstrapping)，不再用C的代码。我们来看一下Go是怎么实现interface的？Go用两种数据结构来实现interface，一个是iface，一个是eface。代码见[Go1.13.1](https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz)

```go
// src/runtime/runtime2.go
type iface struct {
	tab  *itab
	data unsafe.Pointer
}

type eface struct {
	_type *_type
	data  unsafe.Pointer
}
```
当interface没有方法的时候用eface来表示，有方法的时候用iface。itab定义如下

```go
// src/runtime/runtime2.go
type itab struct {
	inter *interfacetype
	_type *_type
	hash  uint32 // copy of _type.hash. Used for type switches.
	_     [4]byte
	fun   [1]uintptr // variable sized. fun[0]==0 means _type does not implement inter.
}
```
itab装了interface的方法地址。当我们谈到interface的时候，可以安全的认为每个interface包含了一对（value, [dynamic type](https://golang.org/ref/spec#Variables)）。总结如下：

- 每个interface有一个静态类型，里面包含了值，以及一个动态类型，这个动态类型是runtime确定的，是相对interface来说的。
- interface{}是一个数据类型
- 做inteface比较的时候考虑的是值和动态类型相不相同，这也是为什么喜欢[犯错](https://yourbasic.org/golang/gotcha-why-nil-error-not-equal-nil/)的原因。
- 这里还有一个很经典的[易范错误](https://github.com/golang/go/wiki/InterfaceSlice)。
- interface不能是(value, interface type)。


## Reflection

有了interface的学习，我们来理解反射会更容易一些。我在面试的时候，如果对方有Go使用经验，通常问会一个问题，谈谈你所理解的反射，绝大多数的回答没有惊艳到我。Rob Pike写了一篇关于反射的[文章](https://blog.golang.org/laws-of-reflection)，里面提到了反射三大定律。

```go
var x interface{} // 静态类型interface{}

type MyInt int
var i int // 静态类型int
var j MyInt // 静态类型MyInt

// 不管r怎么变，r的静态类型永远是io.Reader
var r io.Reader
r = os.Stdin
r = bufio.NewReader(r)
r = new(bytes.Buffer)
```

1. 任何interface都可以拿到反射对象。
2. 通过反射对象，我们可以拿到interface。
3. 要改变反射对象，value必须满足可设置性。

可设置性定义：

> Settability  is a bit like addressability, but stricter. It's the property that a reflection object can modify the actual storage that was used to create the reflection object. Settability is determined by whether the reflection object holds the original item. 

我们来区分下几个概念，什么interface的静态类型、动态类型、以及动态类型的Kind？Go的静态类型是编译期确定的，interface的动态类型是它所装数据的类型，Kind是指Bool、Int、Int8、Int16、Int32
、Int64、Uint、Uint8、Uint16、Uint32、Uint64、Uintptr、Float32、Float64、Complex64、Complex128、Array、Chan、Func、Interface、Map、Ptr、Slice、String、Struct、UnsafePointer。

通过阅读[reflect包](https://golang.org/pkg/reflect/)。我认为反射的应用场景有：

- 改变number或者string的值。
- 填充slice的内容，正如很多driver所写的那样。
- 设置struct的字段。
- 读取struct的tag。
- 做[codec](https://en.wikipedia.org/wiki/Codec)，把字节流或者string编码解码，装进struct或者map，反过来也成立。
- 检查一个reflect.Type是否实现了某个接口。
- 运行期创建函数并且调用。
- 运行期动态调用函数

Happy coding-:)


