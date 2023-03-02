---
title: "Actions"
linkTitle: "Actions"
description: >
    WebServer action subscription
---


> ⚠️ X-Device-ID header required for all graphql request


    const action = {
                  type: "PaymentRedirect",
                  data: {
                    redirectLink: paymentResponse.redirectLink,
                  },
                };


let action: Action = {
          type: "GoTo",
          data: {
            "section": "login"
          }
        }