---
title: "PJFM - Project factory manager"
linkTitle: "PJFM cli"
description: >
  Работа с кастомными проектами фабрики
---
 
# PJFM - Project factory manager

`npm i pjfm -g`

Основная задача `Project factory manager` вывести работу с фабрикой при производстве кастома к уровню обычной работы с проектом.

Разработчик зная нюансы фабрики, и настройки компонентов, использует `рецепт сборки` чтобы билдер выступая в роли менеджера проекта выполнял синхронизацию компонентов фабрики. Например: Нужно поменять цвет у карточки блюда, разработчик поменяет его в `recipe.json` и выполнит комманду `fm sync` менеджер проекта выполнит перенос компонентов в нужные папки и проведет их модификацию. 

Для реализации кастомных компонентов, страниц, сервисов и тд. разработчик должен быть внимателен что лежит в файле `.gitignore`, билдер при запуске sync проверит не менялись ли файлы, и спросит нужно ли добавить файл в гитигнор чтобы перезаписать, после чего выполнит `git commit -m "fm add file(s)"`

Все что находится в папке проекта но не отслеживается git (untracked) при кадом sync будет удалено.

Для того чтобы отслеживать изменения в файлах `fm` снимает хеши со всех (untracked) файлов они хранятся по умолчанию в папке `.tmp_factory` если ее удалить, то все неотслеживаемые файлы при следуешем sync будут удалены.


* Фабричные компоненты не будут попадать в репозиторий проекта. (будут добавлены в `.gitignore`)

todo:
* Если файл попадает в репозиторий то билдер пропустит блок инвентори рецепта, 

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
