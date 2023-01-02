---
title: "Registration and authorization process for the webresto server"
linkTitle: "Registration & authorization"
description: >
    WebServer GrapqlAPI Registration and authorization process
---


> ⚠️ You must made special [action]Request first for many authenticationType in mutation please atention


# User restriction
To get user settings use the user section in restrictions

> `loginField` Setting is `LOGIN_FIELD` 

```gql
{restriction{
    user {
        loginField # by default: `phone`
    }
}}

```

# Registration

Params:
* `login: String [required]` is loginField from UserRestrictions. When (UserRestrictions.loginField=phone) you must send concatenate [code+number] (only digits)"
* `password: String [optional]` required if not provided code, passwordHash
* `passwordHash: String [optional]` required if not provided code or password
* `code: String` Code from codeRequest [required]
* `phone: Phone [required when loginField=phone]`
* `firstName: String [required]`
* `lastName: String [optional]` 
* `customFields: Json` Is object {} with all required fields from UserRestrictions.customFields. Is required if custom required fields was defined
* `captcha: Captcha [required]`

> For registration you must make codeRequest for send SMS\EMAIL

```gql
mutation {
    registration(
    authenticationType: "login+password", 
    login: "13450000123", 
    password: "super#password",
    code: "123456",
    phone: { code: "+1", number: "3450000123" }, 
    firstName: "Benhamin", 
    customFields: {
        zodiac: "Lion",
        vegan: true
    },
    captcha: {
        id: "uuid",
        solution: "123n"
    }
    ) {
        user {
            id
            name
        }
        # Toast "You registered successfully", also this will be sent by Messages subscription
        message {
            title
            type
            message
        }
        action {
            type # returns `redirect`
            data # retruns `login`
        }
}}

```

# Login

> ⚠️ For login you must make codeRequest for send SMS

Params:
* `login: String [required]` is loginField from UserRestrictions. When (UserRestrictions.loginField=phone) you must send concatenate [code+number] (only digits)"
* `password: String [optional]` required if not provided code, passwordHash
* `code: String [optional]` required if not provided password or passwordHash
* `passwordHash: String [optional]` required if not provided code or password
* `twoFactor: String [optional]` required if active 
* `deviceName: String [required]` uniq [device name](#device-name)
* `captcha: Captcha [required]` Solved captcha  for [label: `login:${login}`]

```gql
mutation {
    login(
    authenticationType: "login+password", 
    login: "13450000123", 
    secret: "******",
    deviceName: "IPhone 14 Benhamin",
    captcha: {
        id: "uuid",
        solution: "123n"
    }
    ) {
        user {
            id
            name
        }
        # Toast "You logined successfully", also this will be sent by Messages subscription
        message {
            title
            type
            message
        }
        # Here  recive JWT token, also this will be sent by Actions subscription
        action {
            type # returns `authorization`
            data # retruns `JWT`
        }
}}
```


### Device name

If user restore account from same browser/device it can helps to identify. When user wants to close session on forgoten, need just select session by DeviceId
As example you can use [**biri**](https://github.com/dashersw/biri) for browser, and cordova [**device name**](https://www.npmjs.com/package/cordova-plugin-device-name). Or just make other repetable browserID.

