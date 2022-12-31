---
title: "How to make custom webresto module"
linkTitle: "Make module"
description: >
   How to make custom webresto module
---

Пример конфигурации:
```
module.exports = {
    settings: {
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
    },
    moduleActions: [
        {
            name: "Custom",
            link: "/fullLinkToCustomController"
        }
    ]
}
```

Список всех возможных типов полей в `settings`:
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
корне модуля. Также в этом файле может находиться раздел
`moduleActions`, который содержит настраиваемые клавиши конфигурации
модуля вместе с полностью определенными ссылками на контроллеры для
дальнейшей обработки.

В корне модуля должен также быть файл `package.json`,
который должен содержать обязательные поля `name`, `icon`, `version`, 
`description`

Добавленные в настройках файлы отображаются в в админпанели
в разделе `Settings`

Добавляемые модули должны быть формата `.tar`
Удаление модуля можно запретить в файле package.json с помощью
`"modulemanager": {
   "forbidDelete": true
}`

В файле `config.js` находится конфигурация, которая влияет на работу
самого приложения.
```
state: {
   restartRequired: false, // требуется перезапуск приложения
   unknownError: false, // неизвестная ошибка
   notAvailableMarket: true, // маркетплейс недоступен
   noModulesFound: false, // модулей не найдено
   addNewModule: true // разрешить добавлять модули
},
modules: {
   "test-module2": false
},
modulesPath: process.env.MODULES_PATH ? process.env.MODULES_PATH : `${sailsRoot}/modules`,
tempDirPath: process.env.TEMP_DIR_PATH ? process.env.TEMP_DIR_PATH : `${sailsRoot}/.tmp`,
navbar: [
   {
      id: "1",
      name: "Мои модули",
      link: `/${sails.config.adminpanel?.routePrefix ? sails.config.adminpanel?.routePrefix : "admin"}/modules/my`,
      icon: "home"
   }
]
```

Он может содержать такие поля:
- state - состояние приложения
