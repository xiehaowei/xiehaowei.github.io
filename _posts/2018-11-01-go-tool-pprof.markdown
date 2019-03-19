---
layout: post
title:  "go tool pprof"
date:   2018-11-01 11:13:01 +0800
categories: [go]
tags: [go,profile]
excerpt: "go tool pprof"
---



*  siege -c 10 -t 100s  -b  -H 'header-key: header-value'   -f ~/urls
*  go tool pprof -http=:9999 http://127.0.0.1:3860/debug/pprof/profile



{% highlight go %}
// WrapGroup adds several routes from package `net/http/pprof` to *gin.RouterGroup object
func WrapGroup(router *gin.RouterGroup) {
	routers := []struct {
		Method  string
		Path    string
		Handler gin.HandlerFunc
	}{
		{"GET", "/debug/pprof/", IndexHandler()},
		{"GET", "/debug/pprof/heap", HeapHandler()},
		{"GET", "/debug/pprof/goroutine", GoroutineHandler()},
		{"GET", "/debug/pprof/block", BlockHandler()},
		{"GET", "/debug/pprof/threadcreate", ThreadCreateHandler()},
		{"GET", "/debug/pprof/cmdline", CmdlineHandler()},
		{"GET", "/debug/pprof/profile", ProfileHandler()},
		{"GET", "/debug/pprof/symbol", SymbolHandler()},
		{"POST", "/debug/pprof/symbol", SymbolHandler()},
		{"GET", "/debug/pprof/trace", TraceHandler()},
		{"GET", "/debug/pprof/mutex", MutexHandler()},
	}

	basePath := strings.TrimSuffix(router.BasePath(), "/")
	var prefix string

	switch {
	case basePath == "":
		prefix = ""
	case strings.HasSuffix(basePath, "/debug"):
		prefix = "/debug"
	case strings.HasSuffix(basePath, "/debug/pprof"):
		prefix = "/debug/pprof"
	}

	for _, r := range routers {
		router.Handle(r.Method, strings.TrimPrefix(r.Path, prefix), r.Handler)
	}
}
{% endhighlight %}


{% highlight go %}
// ProfileHandler will pass the call from /debug/pprof/profile to pprof
func ProfileHandler() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		pprof.Profile(ctx.Writer, ctx.Request)
	}
}
{% endhighlight %}
