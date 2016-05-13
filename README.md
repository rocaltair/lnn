## Description

[nanomsg](https://github.com/nanomsg/nanomsg) - scalability protocols library
nanomsg is a socket library that provides several common communication patterns.
It aims to make the networking layer fast, scalable, and easy to use.
Implemented in C, it works on a wide range of operating systems with no further dependencies.

**lnn** - lua-binding for nanomsg

## Examples

I wrote some examples under [example](example) dir like 
[getting-started-with-nanomsg](http://tim.dysinger.net/posts/2013-09-16-getting-started-with-nanomsg.html).

Here is the c source code [nanomsg-examples](https://github.com/dysinger/nanomsg-examples).

run :
```
sh run_example.sh <survey|bus|pubsub|reqrep|pair|pipeline>
```

### How to use poll model?

#### lnn.poll

see [test/poll/poll.lua](test/poll/poll.lua)

#### use poll of system

see [test/uv_poll.lua](test/uv_poll.lua),
which is based on [luv](https://github.com/luvit/luv)
and [libuv](https://github.com/joyent/libuv)

## Functions 

### socket(domain, protocol)

see  [NN_NS_DOMAIN](#nn_ns_domain)

see  [NN_NS_PROTOCOL](#nn_ns_protocol)

#### args:
```
domain :
	AF_SP
	AF_SP_RAW
protocol:
	NN_PAIR
	NN_PUB
	NN_SUB
	NN_REP
	NN_REQ
	NN_PUSH
	NN_PULL
	NN_SURVEYOR
	NN_RESPONDENT
	NN_BUS
```
#### return
```
sock object
```

### 

### errno()
#### return:
```
Returns value of errno for the current thread.
```

### strerror(errnum)

see [NN_NS_ERROR](#nn_ns_error)

#### args:
```
errnum :
	none or nil
	see errno()
```
#### return:
```
errstr : string
```

### symbol_info(i)
#### args:
```
i : index of symbols
```
#### return:
```
table : {
	type = xx,
	name = xx,
	value = xx,
	unit = xx,
}
```

### device(s1, s2)
#### args:
```
s1 : nn_socket
s2 : nn_socket
```

### nn_term()

### poll(sock_array)
#### args:
```
sock_array : 
	{{s1, "r"}, {s2, "rw"}, {s3, "w"}, ...}
```

## Method Of Sock

### sock:close()

### sock:bind(addr)
see [addr](#addr)

#### args:
```
addr : string
```
#### return:
```
eid : to shutdown
```

### sock:connect(addr)
see [addr](#addr)
#### args:
```
addr : string
```
#### return:
```
eid : to shutdown
```


### sock:shutdown(how)
#### args:
```
how :
	0
	eid : see eid
```

### sock:send(buf, flags)

see [NN_NS_FLAG](#nn_ns_flag)
#### args:
```
buf : 
	string to send
flags:
	0, nil or none : block
	NN_DONTWAIT : nonblock
```
#### return:
```
number: size of data which has been sent
errstr:
errnum:
```

### sock:recv(len, flag)

see [NN_NS_FLAG](#nn_ns_flag)
#### args:
```
len :
	nil
	size of data, if more, truncated
flags:
	nil or 0 : block mode
	NN_DONTWAIT
```
#### return:
```
data: recv data
errstr:
errnum:
```

### sock:setsockopt(level, option)

see [NN_NS_OPTION_LEVEL](#nn_ns_option_level)

see [NN_NS_SOCKET_OPTION](#nn_ns_socket_option)

see [NN_NS_TRANSPORT_OPTION](#nn_ns_transport_option)

### sock:getsockopt(level, option, value)

see [NN_NS_OPTION_LEVEL](#nn_ns_option_level)

see [NN_NS_SOCKET_OPTION](#nn_ns_socket_option)

see [NN_NS_TRANSPORT_OPTION](#nn_ns_transport_option)

### addr

example:

```
    inproc://test
    ipc:///tmp/test.ipc
    ipc://127.0.0.1:7788
    tcp://127.0.0.1:5560
```

## Macros

### format
```
name, value, type, unittype
```

### NN_NS_NAMESPACE
```
NN_NS_VERSION   1       0       0
NN_NS_DOMAIN    2       0       0
NN_NS_TRANSPORT 3       0       0
NN_NS_PROTOCOL  4       0       0
NN_NS_OPTION_LEVEL      5       0       0
NN_NS_SOCKET_OPTION     6       0       0
NN_NS_TRANSPORT_OPTION  7       0       0
NN_NS_OPTION_TYPE       8       0       0
NN_NS_OPTION_UNIT       9       0       0
NN_NS_FLAG      10      0       0
NN_NS_ERROR     11      0       0
NN_NS_LIMIT     12      0       0
NN_NS_EVENT     13      0       0
```

### NN_NS_VERSION
```
NN_VERSION_CURRENT      4       0       0
NN_VERSION_REVISION     0       0       0
NN_VERSION_AGE  0       0       0
```

### NN_NS_DOMAIN
```
AF_SP   1       0       0
AF_SP_RAW       2       0       0
```

### NN_NS_TRANSPORT
```
NN_INPROC       -1      0       0
NN_IPC  -2      0       0
NN_TCP  -3      0       0
```

### NN_NS_PROTOCOL
```
NN_PAIR 16      0       0
NN_PUB  32      0       0
NN_SUB  33      0       0
NN_REP  49      0       0
NN_REQ  48      0       0
NN_PUSH 80      0       0
NN_PULL 81      0       0
NN_SURVEYOR     98      0       0
NN_RESPONDENT   99      0       0
NN_BUS  112     0       0
```

### NN_NS_OPTION_LEVEL
```
NN_SOL_SOCKET   0       0       0
```


### NN_NS_SOCKET_OPTION
```
NN_LINGER       1       1       2
NN_SNDBUF       2       1       1
NN_RCVBUF       3       1       1
NN_SNDTIMEO     4       1       2
NN_RCVTIMEO     5       1       2
NN_RECONNECT_IVL        6       1       2
NN_RECONNECT_IVL_MAX    7       1       2
NN_SNDPRIO      8       1       3
NN_RCVPRIO      9       1       3
NN_SNDFD        10      1       0
NN_RCVFD        11      1       0
NN_DOMAIN       12      1       0
NN_PROTOCOL     13      1       0
NN_IPV4ONLY     14      1       4
NN_SOCKET_NAME  15      2       0
NN_RCVMAXSIZE   16      1       1
```

### NN_NS_TRANSPORT_OPTION
```
NN_SUB_SUBSCRIBE        1       2       0
NN_SUB_UNSUBSCRIBE      2       2       0
NN_REQ_RESEND_IVL       1       1       2
NN_SURVEYOR_DEADLINE    1       1       2
NN_TCP_NODELAY  1       1       4
```

### NN_NS_OPTION_TYPE
```
NN_TYPE_NONE    0       0       0
NN_TYPE_INT     1       0       0
NN_TYPE_STR     2       0       0
```

### NN_NS_OPTION_UNIT
```
NN_UNIT_NONE    0       0       0
NN_UNIT_BYTES   1       0       0
NN_UNIT_MILLISECONDS    2       0       0
NN_UNIT_PRIORITY        3       0       0
NN_UNIT_BOOLEAN 4       0       0
```

### NN_NS_FLAG
```
NN_DONTWAIT     1       0       0
```

### NN_NS_ERROR
```
EINTR   4       0       0
EBADF   9       0       0
ENOMEM  12      0       0
EACCES  13      0       0
EFAULT  14      0       0
ENODEV  19      0       0
EINVAL  22      0       0
EMFILE  24      0       0
EAGAIN  35      0       0
EINPROGRESS     36      0       0
ENOTSOCK        38      0       0
EMSGSIZE        40      0       0
ENOPROTOOPT     42      0       0
EPROTONOSUPPORT 43      0       0
ENOTSUP 45      0       0
EAFNOSUPPORT    47      0       0
EADDRINUSE      48      0       0
EADDRNOTAVAIL   49      0       0
ENETDOWN        50      0       0
ENETUNREACH     51      0       0
ENETRESET       52      0       0
ECONNABORTED    53      0       0
ECONNRESET      54      0       0
ENOBUFS 55      0       0
ENOTCONN        57      0       0
ETIMEDOUT       60      0       0
ECONNREFUSED    61      0       0
ENAMETOOLONG    63      0       0
EHOSTUNREACH    65      0       0
EPROTO  100     0       0
ETERM   156384765       0       0
EFSM    156384766       0       0
```

### NN_NS_LIMIT
```
NN_SOCKADDR_MAX 128     0       0
```

### NN_NS_EVENT
```
NN_POLLIN       1       0       0
NN_POLLOUT      2       0       0
```

