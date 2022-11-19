
# 通信格式

GICQ 采用最简单的字符串通信。每个用于通信的完整字符串由多个固定格式的子串单元组成，这些子串之间不添加其他任何字符。

## 子串单元

每个单元包含报头和报文两部分。字符串格式如下：

``\\{HEAD}\2{CONTENT}\3``

首先每个子串单元由一个反斜杠 ``\`` 开始，紧随其后的是报头字符串 ``{HEAD}``，之后是一个 ASCII 码值为 2 的字符，表示从下一个字符开始为报文内容。报文内容结束后，由一个 ASCII 码值为 3 的字符表明该子串单元结束。

从上面定义可以看到，客户端应该对消息发送进行严格的检查，绝对不能在 ``{CONTENT}`` 中出现 ASCII 为 3 的字符。

在本文档的剩余部分，为方便阅读，ASCII 为 2 和 3 的字符用 ``^`` 代替表示。

# 登录请求

## 客户端
客户端在与服务端建立 Socket 连接后立即发送登录请求。发送的通信内容为：

```
\LOGIN^LOGIN^\ACCOUNT^{id}^\PASSWORD^{pwd}^
```

其中 ``{id}`` 和 ``{pwd}`` 为请求登录的账号密码。

客户端发出请求后等待服务器回复，超时时间为 5 秒。

## 服务器
服务端解析上述通信内容后，与数据库中账号密码核对，有四种情况：

- 账号密码正确，同意登录
- 未找到账号，登录失败
- 密码错误，登录失败
- 其他原因，登录失败

分别对应通信：

```
\LOGIN^SUCCESS^
```
```
\LOGIN^FAILED^\REASON^ACCOUNT_NOT_FOUND^
```
```
\LOGIN^FAILED^\REASON^INCORRECT_PASSWORD^
```
```
\LOGIN^FAILED^\REASON^OTHER_ERROR^
```

# 注册请求
## 客户端
```
\REGISTER^REGISTER^\ACCOUNT^{id}^\PASSWORD^{pwd}^\NAME^{name}\TIME^{time}
```

## 服务器
注册成功
```
\REGISER^SUCCESS^
```
注册失败：ID 已经被注册
```
\REGISTER^FAILED^\REASEON^ID_HAS_BEEN_REGISTERED^
```
注册失败：其他原因
```
\REGISTER^FAILED^\REASEON^OTHER_ERROR^
```
 
# 请求用户信息
请求用户信息发生于登陆成功之后。请求的信息包括用户账号、名称、注册时间。
## 客户端
```
\USERINFO^GET^
```

## 服务器
返回信息
```
\USERINFO^RETURN^\ACCOUNT^{id}^\NAME^{name}\REGISTERDATE^{date}^
```
获取失败：其他原因
```
\USERINFO^FAILED^\REASON^OTHER_ERROR^
```

# 发送聊天消息
用户 A 向用户 B 发送聊天消息，内容为 ``content``。
## 客户端
```
\CHAT^SEND^\ACCOUNT^{id}\CONTENT^content^
```
## 服务器
发送成功（返回对方的名字）
```
\CHAT^SUCCESS^\NAME^{name}^
```
发送失败：未找到该 ID 对应账号
```
\CHAT^FAILED^\REASON^ACCOUNT_NOT_FOUND^
```
发送失败：不能向自己发送消息
```
\CHAT^FAILED^\REASON^SENDER_IS_SELF^
```
发送失败：其他原因
```
\CHAT^FAILED^\REASON^OTHER_ERROR^
```

# 获取聊天信息
## 客户端
作为心跳信息，在登陆成功后每 0.5 秒发送一次。
```
\GETCHAT^GETCHAT^
```

## 服务器
返回聊天信息
```
\GETCHAT^RETURN^\NUMBER^{num}^\CHAT_SENDER^{sender1}^\CHAT_NAME^{name1}^\CHAT_CONTENT^{content1}^....
```
返回失败：其他原因
```
\GETCHAT^FAILED^\REASON^OTHER_ERROR^
```