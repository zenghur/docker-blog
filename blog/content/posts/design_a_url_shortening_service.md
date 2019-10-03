---
title: "如何设计一个短链接服务？"
date: 2019-10-02T01:29:35+08:00
categories: ["系统设计"]
toc: true
---

首先我们来看下什么叫[短链接](https://en.wikipedia.org/wiki/URL_shortening)。

我们知道每一个短链接都会对应一个hash code。例如
> https://snip.ml/AgnH4

其中AgnH4是由[hash函数](https://en.wikipedia.org/wiki/Hash_function)生成的。现在问题演化为怎么样找到这样一个hash函数，使得一个长链接映射成一个短链接。string到string的计算比较复杂，当我们实现的时候考虑如下数据库表：

| id 	| actual_url 	| hash_code 	|
|----	|------------	|---------------	|

其中id为自增主键。由此，我们希望找到这样一个[双射函数](https://en.wikipedia.org/wiki/Bijection)使得任何一个自增id，都有一个hash code与之一一对应，避免碰撞。一般来说，可以考虑[Base36](https://en.wikipedia.org/wiki/Base36)或者[Base62](https://www.wikidata.org/wiki/Q809817)编码。假定hash code的长度为k位，那么采用Base36编码，能表示的数字范围为k个36相乘，用Base62编码，k个62相乘。假设hash code的长度有5位，采用Base36编码，能表示的最大值为60,466,176，采用Base62编码，能表示的最大值为
916,132,832。

### Go实现

- Base36编码、解码

```go 

strconv.FormatInt
strconv.FormatUint
strconv.ParseInt
strconv.ParseUint

```


- [Base62编码、解码](https://github.com/xiaojiaoyu100/lizard/blob/master/base62/base62.go)

通过转换后的字符串如果不足k位，可用0补齐。

### 终极方案
以上我们就做出了一个还能用的短链接方案，性能取决于单机数据库的读写性能。如果我们的短链接服务越来越繁忙怎么办呢，这时候考虑使用分布式NoSQL，例如[阿里云Table Store](https://help.aliyun.com/product/27278.html)。

首先设置两个主键，第一个主键为分区列，第二个主键为递增列。注意递增列只是对于分区级别的递增。分区键可以根据业务来选取，递增列的数据不用填写，Table Store自动会写进去。



		










