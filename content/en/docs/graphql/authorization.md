---
title: "Registration and authorization process for the webresto server"
linkTitle: "Registration & authorization"
description: >
    WebServer GrapqlAPI Registration and authorization process
---


## User restrictions

To get user settings use the user section in restrictions

> ⚠️ Understand that everything that transforms into a screaming snake (SCREAMING_SNAKE) is the flags that are in the restriction  `loginField` Setting is `LOGIN_FIELD`   

```gql
{restriction{
    user {
        loginField # by default: `phone` , LOGIN_FIELD
        passwordRequired # by default: `false` it means what need only OTP, for next logins 
        loginOTPRequired # by default: `false` for Login plese use last OTP as password
        registrationOTPRequired # by default: `true`, REGISTRATION_OTP_REQUIRED
        firstNameRequired # by default: `true`, FIRSTNAME_REQUIRED
    }
}}

```

---

## 🛡 Authentication

Get JWTtoken from `action` field on `login` mutation responce, and next pass JWT token without any marks in header `Authorization` 
```
header: {
    Authorization: "ciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7InVzZX",
}
```


## OTPRequest
Send OTP for specific login

>  ⚠️ See stdout nodejs log in development mode you will see OTPcode

### Definition

```gql
mutation OTPRequest(
login: String!
captcha: Captcha! (solved captcha for label "OTPRequest:%login%")
): OTPResponse
```

1. The OTPRequest mutation requests an OTP code for the provided phone or email login.
2. The captcha provided must match the solved captcha for the label "OTPRequest:%login%".
3. The OTP is generated and sent to the provided phone or email login.

 ### Error Handling

If the provided captcha does not match, a generic error message with the message "bad captcha" will be thrown.
Example

```gql

mutation {
    OTPRequest(
        login: "13450000123",
        captcha: {
            id: "uuid",
            solution: "123n"
        }
    ) {
        id
        nextOTPSeconds
        message {
            id
            title
            type
            message
        }
        action {
            id
            type
            data
        }
    }
}
```

---


## Registration

Standart segistration schema `mutation registration` but you can use `mutation getAccountAccessByOTP`

>Step by step:
>1. get OTP
>2. Solve captcha
>3. Prepare graphql mutation
>4. get Action from response

### Definition

```gql
mutation registration(
  login: String!
  phone: Phone (required when login field is phone)
  password: String
  otp: String! (from otpRequest)
  firstName: String
  lastName: String
  customFields: Json (required if custom fields are defined in UserRestrictions->customFields)
  captcha: Captcha! (solved captcha for label "registration:%login%")
): UserResponse
```

### Function

The `registration` mutation creates a new user with the provided fields.

1. The captcha provided must match the solved captcha for the label "registration:%login%"
2. The login field must be of phone type and the provided phone must match the concatenation of the phone code, number, and additional number (only digits).
3. The password or OTP is required based on the settings `PASSWORD_REQUIRED` and `REGISTRATION_OTP_REQUIRED`.
4. The custom fields are required if custom fields are defined in UserRestrictions->customFields
5. The OTP provided must match the one sent from the `otpRequest`.
6. The function returns a UserResponse object with the created user, a success message, and an action to go to the login section with a delay of 5 seconds.
7. When `FIRSTNAME_REQUIRED` you should pass FirstName 

### Error Handling

If any errors occur during the process, it is logged and a generic error message is thrown.

> For registration you must make codeRequest for send SMS\EMAIL

### Example

```gql
mutation {
    registration(
    login: "13450000123", 
    password: "super#password",
    otp: "123456",
    phone: { otp: "+1", number: "3450000123" }, 
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
            id # unique id is equal subscription message id
            title
            type
            message
        }
        action {
            id # unique id is equal subscription action id
            type # returns `redirect`
            data # retruns `login`
        }
}}

```

---

## Quick access by OTP

If you getting account access by OTP for unknown account, server create new account. For cases when account is registred 
server restore account ignore all flags (ex. firstNameRequired), and send login token automaticaly in action. 

### Definition

```gql
mutation quickAccessByOTP(
  login: String!
  phone: Phone (required when login field is phone)
  otp: String! (from otpRequest)
  captcha: Captcha! (solved captcha for label "quickAccessByOTP:%login%")
): UserResponse
```

### Function

1. 


### Error Handling

## Login

> ⚠️ For login you must make codeRequest for send SMS

> ⚠️ After login you receive JWT in action (login)

> ⚠️ By default setting `SET_LAST_OTP_AS_PASSWORD = true` it means what last OTP was setting as password, but you can get OTP in any time



### Definition 

```gql
login(
    login: String! (loginField from UserRestrictions, When (UserRestrictions.loginField=phone) you must send concatenate [otp+number] (only digits))
    password: String (required if not provided otp)
    otp: String (required if not provided password)
    deviceName: String! (Unique device name)
    captcha: Captcha! (Solved captcha for label 'login:%login%')
): UserResponse
```

### Function

### Error Handling

### Example

```gql
mutation {
login(
    login: "13450000123", 
    secret: "Password",
    otp: "123456"
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
            id # unique id is equal subscription message id
            title
            type
            message
        }
        # Here  recive JWT token, also this will be sent by Actions subscription
        action {
            id # unique id is equal subscription action id
            type # returns `authorization`
            data # retruns `JWT_TOKEN`
        }
}}
```

---

## Logout

> 🛡 Authentication required 
>
```gql
logout(
    deviceName: String (Optional field if not pass logout from current device) 
): Response
```      
      


## logout from all devices

> 🛡 Authentication required

```gql
logoutFromAllDevices: Response
```

## Device name

If user restore account from same browser/device it can helps to identify. When user wants to close session on forgoten, need just select session by DeviceId
As example you can use [**biri**](https://github.com/dashersw/biri) for browser, and cordova [**device name**](https://www.npmjs.com/package/cordova-plugin-device-name). Or just make other repetable browserID.

