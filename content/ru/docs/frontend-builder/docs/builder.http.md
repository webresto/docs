---
title: "REST Builder"
linkTitle: "REST Builder"
description: >
  Описание запросов к билдеру.
---

### https://marketplace.visualstudio.com/items?itemName=humao.rest-client

```txt
@host=https://next.fbuilder.webresto.dev/api

### Healthcheck. Просто возвращает 200
GET {{host}}/


### Авторизация. Получить токен
# @name auth
POST {{host}}/auth
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE2NDE4MTUwNDMxNzUsInVwZGF0ZWRBdCI6MTY0MTgxNTA0MzE3NSwiaWQiOiI5MGRhMTg5Ny1jNWRmLTVlZDQtOTk0NC1mMzNhNWFkMWM5NzYiLCJjb25maWciOnsiaWQiOiIxMjMiLCJjcmVkZW50aWFscyI6ImdpdGxhYitkZXBsb3ktdG9rZW4tMTI6ZUVuQVQ1R3pBNG1YY1h5d1Z4V3MiLCJhbGlhc2VzIjp7ImJhc2VfbGF5b3V0cyI6eyJnaXQiOiJodHRwczovL3skQ1JFREVOVElBTFN9QGdpdC5obS93ZWJyZXN0by9mYWN0b3J5L2Jhc2VfbGF5b3V0cy5naXQiLCJyZXYiOiJzdGFnaW5nIn19fSwiaWF0IjoxNjQxODE1MDQzfQ.V80jzzZkweTdD_6f9NXZyv2U5rPe_owjdi7xG7qdQ9M
###
@token = {{auth.response.body.$.token}}

### Запросить Layouts
GET {{host}}/layouts
X-Session-Token: {{token}}

### Запросить доступные компоненты
GET {{host}}/components?layout=base_layouts/layout1
X-Session-Token: {{token}}


### Перебилдить
POST {{host}}/rebuild
X-Session-Token: {{token}}
Content-Type: application/json

{
	"aliases": {
		"base_layouts": {
			"git": "https://{$CREDENTIALS}@git.hm/webresto/factory/base_layouts.git",
			"rev": "staging"
		}
	},

	"unit": "base_layouts/layout1",
	"environment": {
		"backendLink": "123",
		"imageLink": "123"
	},
	"constant": {},
	"inventory": {
		"header": {
			"unit": "base_layouts/header1",
			"constant": {}
		}
	}
}


### Проверить статус сессии
GET {{host}}/session
X-Session-Token: {{token}}

### Завершить сессию. Удалить папку
POST {{host}}/session/stop?clean=true
X-Session-Token: {{token}}


```