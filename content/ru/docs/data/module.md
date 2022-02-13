---
title: "Webresto module"
linkTitle: "Модуль"
description: >
   как сделать модуль
---

Пример конфигурации:
```
module.exports = {
    fields: {
        label: {
            title: "Label",
            type: "string",
            required: true,
            tooltip: 'tooltip for label',
            description: "some description"
        },
        datetime: {
            title: "Дата и время",
            type: "datetime",
            required: true,
            tooltip: 'tooltip for datetime',
        }
    }
}
```

Список всех возможных типов полей:
- label
- teaser
- description
- date
- datetime
- time:
- number
- checkbox
- color
- ace
- email
- month
- range
- week
- fileUploader
- filesUploader
- galleryUploader
- imageUploader
- schedule

Файл `config.js`, содержащий данные свойства должен находиться в
корне модуля. Также в корне модуля должен быть файл `package.json`,
который должен содержать обязательные поля `appId`, `icon`, `version`, 
`description`

Добавленные в настройках файлы загружаются в папку `названиеПапки`
и отображаются в в админпанели на вкладке `Settings`

Добавляемые модули должны быть формата `.tar`
