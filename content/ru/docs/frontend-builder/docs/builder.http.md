---
title: "REST Builder"
linkTitle: "REST Builder"
description: >
  Описание запросов к билдеру.
---

### https://marketplace.visualstudio.com/items?itemName=humao.rest-client

```txt

@host = http://localhost:8000
# @host = https://next.fbuilder.webresto.dev/api/


### Healthcheck. Просто возвращает 200
GET {{host}}/


### Авторизация. Получить токен
# @name auth
POST {{host}}/auth
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsImNyZWRlbnRpYWxzIjoiZ2l0bGFiK2RlcGxveS10b2tlbi0xMjplRW5BVDVHekE0bVhjWHl3VnhXcyIsImFsaWFzZXMiOnsiYmFzZV9sYXlvdXRzIjp7ImdpdCI6Imh0dHBzOi8veyRDUkVERU5USUFMU31AZ2l0LmhtL3dlYnJlc3RvL2ZhY3RvcnkvYmFzZV9sYXlvdXRzLmdpdCIsInJldiI6InN0YWdpbmcifX19.xxqNnMIwThVRit0ErRw0-7XefUnGeSShXHcDyL3FBG0
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
POST {{host}}/shutdown?clean=true
X-Session-Token: {{token}}


```