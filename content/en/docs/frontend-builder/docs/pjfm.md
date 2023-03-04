---
title: "PJFM - Project factory manager"
linkTitle: "PJFM cli"
description: >
  Работа с кастомными проектами фабрики
---
 
# pjfm - Project factory manager

`npm i pjfm -g`

Основная задача `Project factory manager` вывести работу с фабрикой при производстве кастома к уровню обычной работы с проектом.

При инициализации билдер копирует файлы фабрики и создает проект, и все файлы нужные для начала. 
При синхронизации билдер удаляет предыдущие файлы, и копирует новые компоненты и файлы фабрики в проект

Разработчик зная нюансы фабрики, и настройки компонентов, использует `рецепт сборки` чтобы билдер выступая в роли менеджера проекта выполнял синхронизацию компонентов фабрики. Например: Нужно поменять цвет у карточки блюда, разработчик поменяет его в `recipe.json` и выполнит комманду `fm sync` менеджер проекта выполнит перенос компонентов в нужные папки и проведет их модификацию. 


Весь проект попадает в репозиторий `git` и создается файл `factory-lock.json`

> ⚠️ Если файл `factory-lock.json` отсутсвует то можно попробовать провести синхронизацию с флагом `--force` при этом файлы новой сборки будут записаны поверх. *т.е. проект не будет очищен от старой сборки*
 
При каждой синхронизации проекта `fm sync` файлы файлы из lock удаляются и на их место заменяются файлами из фабрики учитывая файл `.factoryignore`

> ⚠️ Файлы которые не относятся к фабрике не нужно ставить в `.factoryignore` так как они не должны заменятся.  

Билдер при снихронизации не будет проверять файлы на изменения, но проверит что коммит выполнен, чтобы отключить проверку коммита используйте флаг `--force`


## Multi project
  If `projects-dir` defined in .factoryrc file is multiproject repo

## commands:
    
    `--help` - Все возможные параметры запуска

    `init` - создание проекта для кастома
    `init --projectname=[project_name]` - создание проекта для кастома
    `sync` - синхронизация проекта с фабрикой по рецепту [sync all equal for multiproject ]
    `sync  --projectname=[project_name]` - синхронизация проекта с фабрикой по рецепту

Файл .factoryrc

```
{
  "library": "./../components",    //   components library. by default ./components
  "recipeFileName": "recipe.json",    // name of project config file (recipe) stored in root project. // by default recipe.json
  "changesDetection": false           // Prepend overwrite edited files // by default true
  "projectsDir": "projects"           // Path for multiproject [if defined is multiproject repo]
}

```