---
layout: post
title:  "websocket Go Server"
date:   2018-12-23 11:19:46 +0800
categories: [network]
tags: [Go,websocket,pb]
excerpt: "Go websocket server"
---

{% highlight shell %}
package main

import (
	"fmt"
	"log"
	"net/http"
	"test/pb"

	"github.com/golang/protobuf/proto"
	"github.com/gorilla/websocket"
)

var (
	upgrader = websocket.Upgrader{
		// 读取存储空间大小
		ReadBufferSize: 1024,
		// 写入存储空间大小
		WriteBufferSize: 1024,
		// 允许跨域
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
)

func wsHandler(w http.ResponseWriter, r *http.Request) {
	var (
		wbsCon *websocket.Conn
		err    error
	)
	// 完成http应答，在httpheader中放下如下参数
	if wbsCon, err = upgrader.Upgrade(w, r, nil); err != nil {
		return // 获取连接失败直接返回
	}
	for {
		//获取发送内容
		msgType, data, err := wbsCon.ReadMessage()
		if err != nil {
			goto ERR // 跳转到关闭连接
		}
		reqMsg := new(pb.MyProtocolBean)
		err = proto.Unmarshal(data, reqMsg)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(string(reqMsg.Content))

		msg := new(pb.RequestMsg)
		err = proto.Unmarshal(reqMsg.Content, msg)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Printf(" ==== outer : %+v ====  msgType:%d  ==== inner : %+v", reqMsg, msgType, msg)
		// fmt.Printf("messageType : %d  len:%d  data : %s \n", msgType, len(data), string(data))
		innerResp := new(pb.HomeUserInfoMsg)
		innerResp.Command = "testCommand"
		innerResp.UserId = "xiehaowei"

		innerRespOut, _ := proto.Marshal(innerResp)

		outerResp := new(pb.MyProtocolBean)
		outerResp.Content = innerRespOut
		outPut, _ := proto.Marshal(outerResp)

		if err = wbsCon.WriteMessage(websocket.BinaryMessage, outPut); err != nil {
			fmt.Println(err)
			goto ERR // 发送消息失败，关闭连接
		}
	}

ERR:
	wbsCon.Close() // 关闭连接
}
func main() {
	http.HandleFunc("/ws", wsHandler)
	err := http.ListenAndServe("0.0.0.0:8090", nil)
	if err != nil {
		log.Fatal("ListenAndServe", err.Error())
	}
}

{% endhighlight %}
