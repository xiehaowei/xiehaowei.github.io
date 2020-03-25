---
layout: post
title:  "vim column edit"
date:   2019-09-16 10:48:27 +0800
categories: [vim]
tags: [vim]
excerpt: "vim 列编辑"
---

#### 删除列
1. 光标定位到要操作的地方。
2. CTRL+v 进入“可视 块”模式，选取这一列操作多少行。
3. d 删除。
 
#### 插入列
1. 光标定位到要操作的地方。
2. CTRL+v 进入“可视 块”模式，选取这一列操作多少行。
3. SHIFT+i(I) 输入要插入的内容。
4. ESC 按两次，会在每行的选定的区域出现插入的内容。