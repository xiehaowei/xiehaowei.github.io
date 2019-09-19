---
layout: post
title:  "gin-swagger"
date:   2019-03-20 16:45:27 +0800
categories: [Go]
tags: [Go,swagger,gin]
excerpt: "gin middleware to automatically generate RESTful API documentation with Swagger 2.0."
---

#### 1. Add comments to your API source code, [See Declarative Comments Format](https://swaggo.github.io/swaggo.io/declarative_comments_format/).

#### 2. Download Swag for Go by using:

{% highlight shell %}
$ go get -u github.com/swaggo/swag/cmd/swag
{% endhighlight %}

#### 3. Run the Swag in your Go project root folder which contains main.go file, Swag will parse comments and generate required files(docs folder and docs/doc.go).

{% highlight shell %}
$ swag init
{% endhighlight %}

#### 4. Download gin-swagger by using:

{% highlight shell %}
$ go get -u github.com/swaggo/gin-swagger
$ go get -u github.com/swaggo/gin-swagger/swaggerFiles
{% endhighlight %}

#### 5. And import following in your code:   

{% highlight go %}
package main

import (
	"github.com/swaggo/gin-swagger"
	"github.com/swaggo/gin-swagger/swaggerFiles"
	_ "gitlab.luojilab.com/igetserver/evaluation/docs"
)

func main() {
	conf := artemis.LoadConfig(*confPath)
	artemis.App = artemis.New(conf)
	time.LoadLocation("Asia/Shanghai")
	api.RouteAPI(artemis.App.Router, Version)
	// @title DeDao evaluation API
	// @version 1.0
	// @description This is a sample server DeDao evaluation server.
	// @host http://127.0.0.1:6641
	// @BasePath /evaluation/v1
	artemis.App.Router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	artemis.App.Run()

}
{% endhighlight %}

#### 6. Run it, and browser to http://127.0.0.1:6641/swagger/index.html, you can see Swagger 2.0 Api documents.

#### 7.  Declarative Comments Format

{% highlight go %}
// Get Commodity Detail godoc
// @Summary 获取 commodity detail
// @Description 通过id 获取 commodity detail
// @Tags commodity
// @Accept  x-www-form-urlencoded,json
// @Param id path int true "id" default(1)
// @Produce  json
// @Success 200 {object} models.CommodityItem
// @Router /commodity/{id}/detail [get]
func (endpoint *CommodityEndpoint) getCommodity(c *gin.Context) {
	idStr := c.Param("id")
	...
}
{% endhighlight %}

[see more](https://swaggo.github.io/swaggo.io/declarative_comments_format/api_operation.html)

|annotation | description|
|-----|-----|
|description| A verbose explanation of the operation behavior.|
|id | A unique string used to identify the operation. Must be unique among all API operations.|
|tags  |  A list of tags to each API operation that separated by commas.|
|summary| A short summary of what the operation does.|
|accept | A list of MIME types the APIs can consume. Value MUST be as described under Mime Types.|
|produce| A list of MIME types the APIs can produce. Value MUST be as described under Mime Types.|
|param  | Parameters that separated by spaces. param name,param type,data type,is mandatory?,comment attribute(optional)|
|security  |  Security to each API operation.|
|success |Success response that separated by spaces. return code,{param type},data type,comment|
|failure |Failure response that separated by spaces. return code,{param type},data type,comment|
|router | Failure response that separated by spaces. path,[httpMethod]|

param-type : ["query", "path", "header","body","formData"]
1. file // @Param file formData file true "account image"
2. id   // @Param  id path int true "Account ID"  for // @Router /accounts/{id}/images [post]
3. struct // @Param  account body model.UpdateAccount true "Update account"
4. query // @Param q query string false "name search by q" Format(email)