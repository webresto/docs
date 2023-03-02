---
title: "User methods"
linkTitle: "User methods"
description: >
    User methods after login
---

> ⚠️ X-Device-ID header required for all graphql request

## Get user info

> 🛡 Authentication required 

To get user model data

```gql
    me {
        firstName
        lastName
        hasFilledAllCustomFields
        customFields
    }
```

---


## Update user info

> 🛡 Authentication required 

Update user model

### Definition

```gql
mutation updateMe(
    user: InputUser
): UserResponse
```