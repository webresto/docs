---
title: "Спецификация"
linkTitle: "Спецификация"
date: 2017-01-06
description: >
 Билдер - программа, генерирующая код одностраничных приложений из готовых компонентов.
---

# Factory chef

Шеф (factory chef, билдер) - программа на Rust, которая собирает проект из библиотеки компонентов
по рецепту: копирует исходники проекта, раскладывает выбранные компоненты, генерирует для них
конфиги и стили, подставляет иконки, шрифты, сниппеты и ассеты, а затем, если нужно, собирает
результат (сайт, приложение) командами из манифеста. Компоненты описываются манифестами в YAML,
рецепт - JSON. В продакшене билдер собирает сайты на Angular.

Библиотека компонентов может содержать несколько фабрик (проектов): у каждого свои лейауты и
компоненты, а компоненты можно открывать другим проектам (см. «Выбор компонентов»).

Документ описывает только то, что реально работает в текущем коде (ветка `next`, билдер `0.4.0`).
Идеи, которые обсуждались или были начаты, но не работают, собраны в [ideas.md](ideas.md). Старая
версия документации лежит в [old/](old/README.md).

Программы:

- **`builder`** - сборка одного рецепта из командной строки; используется в Docker-образе фабрики
  (`/app/project_builder`). Описан в этом документе.
- **`chefkit`** - инструмент разработчика кастомного проекта: создает проект из фабрики и
  синхронизирует его с ней. Ставится из npm (`@chef-kit/*`). См. [chefkit.md](chefkit.md).

Документы:

- [actions.md](actions.md) - экшены (`copy`, `bash`, `write-recipe`);
- [assets.md](assets.md) - ассеты компонентов и рецепта;
- [chefkit.md](chefkit.md) - chefkit;
- [development.md](development.md) - сборка билдера из исходников, тесты, CI, выпуск;
- [ideas.md](ideas.md) - нереализованные идеи и известные расхождения.

## Термины

- **Фабрика** - набор файлов (проект на любом языке), подготовленный для билдера: исходники проекта
  плюс компоненты с манифестами.
- **Библиотека компонентов** - папка, в которой лежат фабрики-проекты. Ее путь передается билдеру
  (`--components-library`).
- **Проект** - папка верхнего уровня библиотеки с манифестом `project/index.m.yml` и папкой
  `components`. Имя проекта - поле `project.name`, а не имя папки.
- **Манифест** - YAML-файл с описанием проекта (`project/index.m.yml`) или юнита
  (`<папка>.m.yml`). По сути это типизация свойств компонента: что в нем можно настроить и чем.
- **Юнит** - базовая единица билдера, описанная манифестом: компонент, лейаут или иконпак.
- **Компонент** - папка с манифестом `<папка>.m.yml` внутри `components`. Адресуется как
  `<проект>/<slug>`.
- **Группа** - назначение компонента (`header`, `cart`, ...). Из группы выбирается компонент в
  пункт инвентаря.
- **Лейаут** - компонент группы `layout`. С него начинается сборка: рецепт называет лейаут, а лейаут
  своим инвентарем перечисляет места для остальных компонентов.
- **Инвентарь** (`inventory`) - список мест (пунктов) компонента, в каждое из которых билдер ставит
  один компонент нужной группы.
- **Иконпак** - манифест с набором SVG-иконок.
- **Рецепт** (конфиг сборки) - JSON, который говорит, какой лейаут собрать, какие компоненты
  поставить в инвентарь и с какими значениями.
- **Таргет** - во что собирается сгенерированный проект (`www`, `android`, ...): шаги сборки из
  манифеста проекта.
- **Папка сборки** (`{$BUILD_PATH}`) - выходная папка (`--output`), в ней появляется проект.

## Требования

- `bash` - для экшенов `bash` (Windows: Git Bash или Cygwin, см. [actions.md](actions.md#bash));
- `tar` - архив `archive.tar.gz` делается системным `tar`;
- `git` - для chefkit;
- Node.js - для валидатора манифестов и npm-пакета chefkit;
- для сборки из исходников - стабильный Rust, см. [development.md](development.md).

## Быстрый старт

В репозитории есть пример библиотеки `examples` с проектом `basic`:

```
examples/basic/
├── project/
│   ├── index.m.yml          # манифест проекта
│   └── src/index.html
└── components/
    ├── layout/wide/wide.m.yml
    ├── layout/narrow/narrow.m.yml
    └── header/header2/header2.m.yml ...
```

Рецепт (сохраните в `recipe.json` в корне репозитория):

```json
{
  "unit": "basic/wide",
  "inventory": {
    "header": { "unit": "header2" }
  }
}
```

Сборка:

```bash
cargo build --bin builder
target/debug/builder build --recipe=recipe.json --components-library=examples --output=/tmp/out
```

Результат:

```
/tmp/out
├── archive.tar.gz             # архив исходников сгенерированного проекта
├── font-family.scss           # шрифты (fontFamilyPath)
├── src/index.html             # index.html проекта со сниппетами и шрифтами
└── components/
    ├── layout/                # лейаут: colors.*, config.*, component.config.ts
    └── header/                # пункт инвентаря header: то же
```

> `examples/basic/config.json` сейчас выбирает `header3`, у которого группа `header3`, и не
> собирается (`can't find unit [header3] with group [header]`). Используйте рецепт выше.

## Создание проекта шаг за шагом

Соберем с нуля проект из лейаута и шапки. Все выводы ниже получены запуском билдера.

### 1. Структура и манифест проекта

```
tutorial/
├── recipe.json
└── mylib/                         # библиотека компонентов
    └── shop/                      # проект
        ├── project/
        │   ├── index.m.yml
        │   └── src/index.html
        └── components/
```

`mylib/shop/project/index.m.yml` - с него билдер начинает. Здесь имя проекта, пути, которые нужны
билдеру, и подготовка папки сборки:

```yml
project:
  name: shop
  version: 1
  type: html
  constant:
    assetsPath: "{$BUILD_PATH}/src/assets"          # куда копировать assets компонентов
    fontFamilyPath: "{$BUILD_PATH}/src/font-family.scss"  # файл со шрифтами
  init:
    - run: copy                                     # исходники проекта -> папка сборки
      src: "{$ROOT_PATH}/project"
      dst: "{$BUILD_PATH}"
      clean: true
```

`mylib/shop/project/src/index.html` - заготовка страницы с маркерами, по которым билдер вставляет
шрифты и сниппеты:

```html
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>Shop</title>
  <!--font loaded here-->
  <!--end font-->
  <!--begin head snippet-->
  <!--end head snippet-->
</head>
<body>
  <!--begin body top snippet-->
  <!--end body top snippet-->
  <app-root></app-root>
  <!--begin body bottom snippet-->
  <!--end body bottom snippet-->
</body>
</html>
```

Рецепт `recipe.json`:

```json
{ "unit": "shop/wide" }
```

Запуск:

```bash
builder build --recipe=recipe.json --components-library=mylib --output=out
```

```
couldn't find layout variant [shop/wide]. loaded projects: ["shop"]
```

Проект найден, а лейаута еще нет. Выходная папка не создана: рецепт проверяется до сборки.

### 2. Лейаут

`mylib/shop/components/layout/wide/wide.m.yml` (папка `layout` - для людей, лейаутом компонент
делает `group: layout`):

```yml
unit:
  version: 1
  name: "Широкий"
  slug: wide
  group: layout
  author: "John Doe"
  description: "Лейаут на всю ширину"
component:
  constant:
    cssVariables:
      - key: primary-color
        value: "#ff00ff"
        name: "Основной цвет"
        description: "Цвет кнопок и ссылок"
    states:
      - key: showFooter
        default: true
        name: "Показывать подвал"
        description: ""
        type: boolean
  fonts:
    main:
      description: "Основной шрифт"
      default: Roboto
  availableFonts:
    - name: Roboto
      link: "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap"
    - name: Montserrat
      link: "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap"
```

Рядом положим файл верстки `wide.component.html`. Запуск дает:

```
out
├── archive.tar.gz
├── src
│   ├── index.html
│   └── font-family.scss          # $font-main: "Roboto";
└── components/layout
    ├── wide.component.html        # файлы компонента, кроме *.m.yml
    ├── colors.scss                # $primary-color: #ff00ff;
    ├── colors.json                # {"primary-color":"#ff00ff"}
    ├── config.json                # { "showFooter": true }
    ├── config.ts                  # export default { showFooter: true, }
    └── component.config.ts        # config + styles
```

В `src/index.html` между `<!--font loaded here-->` и `<!--end font-->` появилась ссылка на Roboto.

### 3. Компонент в инвентаре

Шапка `mylib/shop/components/header/header1/header1.m.yml`:

```yml
unit:
  version: 1
  name: "Шапка с логотипом"
  slug: header1
  group: header
  author: webresto
  description: "Шапка: логотип и соцсети"
  componentPrefix: "header.component"        # имя файла выбранного стиля
component:
  constant:
    cssVariables:
      - key: primary-color
        value: "$primary-color"              # берется от лейаута/рецепта
        name: "Основной цвет"
        description: "Наследуется от лейаута"
      - key: hover-color
        value: "!Accent($primary-color, 0.2)"   # вычисляется
        name: "Цвет при наведении"
        description: ""
    variables:
      - key: logoLink
        default: "assets/img/logo.svg"
        name: "Логотип"
        description: "Ссылка на картинку"
        type: string
      - key: socials
        default: ["vk", "telegram"]
        name: "Соцсети"
        description: ""
        type: array
        arrayType: string
        options:
          - { name: VK, slug: vk }
          - { name: Telegram, slug: telegram }
          - { name: WhatsApp, slug: whatsapp }
  styles:
    - { name: "Светлая", slug: light, description: "" }
    - { name: "Темная", slug: dark, description: "" }
```

Файлы шапки: `header.component.html`, `styles/light.scss`, `styles/dark.scss`,
`assets/img/logo.svg`. Вторая шапка `header2` - с `group: header` и `component: {}`.

Лейаут получает место для шапки:

```yml
# wide.m.yml
component:
  inventory:
    header:
      group: header
      default: header2
      description: "Шапка сайта"
```

Рецепт выбирает `header1`, стиль, значения и шрифт:

```json
{
  "unit": "shop/wide",
  "constant": {
    "cssVariables": { "primary-color": "#1e3a8a" }
  },
  "inventory": {
    "header": {
      "unit": "header1",
      "style": "dark",
      "constant": {
        "variables": { "socials": ["telegram", "whatsapp"] }
      }
    }
  },
  "fonts": { "main": "Montserrat" },
  "snippets": { "head": ["<meta name=\"robots\" content=\"noindex\">"] }
}
```

Результат:

```
out
├── src
│   ├── assets/img/logo.svg              # assets шапки -> assetsPath
│   ├── font-family.scss                 # $font-main: "Montserrat";
│   └── index.html                       # ссылка на Montserrat, <meta name="robots"...>
└── components
    ├── layout/...                       # $primary-color: #1e3a8a;
    └── header
        ├── header.component.html
        ├── header.component.scss        # копия styles/dark.scss
        ├── styles/  assets/             # файлы компонента как есть
        ├── colors.scss
        ├── config.json  config.ts
        └── component.config.ts
```

```scss
// components/header/colors.scss
$hover-color: #4B61A1;
$primary-color: #1e3a8a;
```

```ts
// components/header/config.ts
export default {
    logoLink: "assets/img/logo.svg",
    socials: ["telegram", "whatsapp"],
}
```

Без `"unit": "header1"` в рецепте встала бы `header2` (`default` пункта), а без `default` -
первая по алфавиту шапка проекта.

### 4. Дальше

- иконки, environment, ассеты из рецепта - разделы ниже и [assets.md](assets.md);
- команды после генерации (`npm ci`, `ng build`) - `postActions` или таргет, см.
  [actions.md](actions.md) и «Таргеты»;
- проверка манифестов - «Проверка манифестов».

## Юниты и что в них настраивается

| Юнит | Чем является | Где описан |
|---|---|---|
| Лейаут | компонент с `group: layout`; корень сборки | «Манифест компонента», «Лейаут» |
| Компонент | наполняет пункт инвентаря; может иметь свой инвентарь | «Манифест компонента» |
| Иконпак | набор SVG-иконок | «Иконпак» |
| Kit | `type: kit`; сейчас ведет себя как обычный компонент | [ideas.md](ideas.md#kit-и-зависимости) |

Что настраивается в компоненте и что получается:

| Свойство | В манифесте | В рецепте | Результат |
|---|---|---|---|
| Цвета | `constant.cssVariables` | `constant.cssVariables` | `colors.scss`, `colors.json`, `styles` в `component.config.ts` |
| Состояния | `constant.states` | `constant.states` | `config.json`, `config.ts`, `config` в `component.config.ts` |
| Переменные | `constant.variables` | `constant.variables` | то же |
| Стиль | `styles` + `componentPrefix` | `style` пункта | `<componentPrefix>.scss` |
| Шрифты (лейаут) | `fonts`, `availableFonts` | `fonts` | `fontFamilyPath`, ссылки в `index.html` |
| Иконки (лейаут) | `iconSet` | `iconPack`, `iconOverrides` | `iconsPath` |
| Ассеты | папка `assets` | `assets` | файлы в `assetsPath` и др. |
| Шаблоны | `unit.hasTemplate` + `*.tmpl` | - | файлы без `.tmpl` |
| Команды | `actions` | - | что делают экшены |

## Библиотека компонентов

```
<библиотека>/
  <папка проекта>/              # имя папки не важно
    project/
      index.m.yml               # манифест проекта, обязателен project.name
      src/index.html            # обязателен, см. «Сниппеты»
      ...                       # исходники проекта (копирует init-экшен)
    components/
      <категория>/              # любое имя, только для людей
        <компонент>/
          <компонент>.m.yml     # имя файла = имя папки компонента
          assets/               # необязательно, см. assets.md
          styles/<slug>.scss    # необязательно, см. «Стили»
          *.tmpl                # необязательно, см. «Шаблоны»
          ...                   # любые файлы компонента
```

Пример библиотеки с двумя проектами (так устроен образ фабрики):

```
/app/layouts/                # библиотека компонентов
  base_layouts/              # project.name: base_layouts
    project/index.m.yml
    components/...
  layout2/                   # project.name: layout2
    project/index.m.yml
    components/...
```

Лейаут `base_layouts` в рецепте - `"unit": "layout1"` или `"unit": "base_layouts/layout1"`,
лейаут `layout2` - `"unit": "layout2/wide"`.

Как билдер обходит библиотеку:

| Папка верхнего уровня | Что делает билдер |
|---|---|
| нет `project/index.m.yml` (`.git`, `.ci`, `docs`, вывод сборки, файлы) | не проект, пропускается |
| манифест есть, `project.name` нет или пустой | папка не используется, предупреждение с путем |
| манифест не разбирается | ошибка с путем манифеста |
| в `project.name` есть `/` | ошибка |
| два проекта с одним `name` | ошибка с обоими путями |
| вложенные папки | не просматриваются, проекты вглубь не ищутся |
| ни одного проекта | ошибка |

Папка проекта может быть симлинком, в том числе на папку вне библиотеки. Тот же репозиторий под
другим именем папки остается тем же проектом. Если лейаут не найден, ошибка перечисляет загруженные
проекты и папки, пропущенные из-за отсутствия `project.name`.

Компоненты ищутся ровно на двух уровнях: `components/<категория>/<компонент>/<компонент>.m.yml`.
Глубже билдер не смотрит. Компонент попадает в группу из `unit.group` (имя папки-категории ни на
что не влияет) под ключом `<проект>/<unit.slug>`.

> ⚠️ Если манифест компонента отсутствует, пуст или **не разбирается** (опечатка в YAML, неизвестное
> поле в секции `component`, недопустимое значение `type`, дробное число), компонент молча
> пропускается - без ошибки и без предупреждения. Если компонент «не находится», первым делом
> проверьте его манифест валидатором (см. «Проверка манифестов»).

## Манифест проекта

`<папка проекта>/project/index.m.yml`:

```yml
project:
  name: base_layouts              # обязательно; компоненты адресуются как <name>/<slug>
  version: 1                      # обязательно, число; билдером не используется
  type: "angular"                 # обязательно, строка; билдером не используется
  constant:                       # обязательно (можно {}); пути и любые свои значения
    assetsPath: "{$BUILD_PATH}/src/assets"
    iconsPath: "{$BUILD_PATH}/src/app/material/icons.ts"
    fontFamilyPath: "{$BUILD_PATH}/src/styles/vars/font-family.scss"
    fontsPath: "{$BUILD_PATH}/src/assets/fonts"
    publicFontsPath: "/assets/fonts"
    environmentPath: "{$BUILD_PATH}/environment.json"
  environment:                    # см. «Environment»
    - key: base
      required: true
  init:                           # экшены до сборки компонентов
    - run: copy
      src: "{$ROOT_PATH}/project"
      dst: "{$BUILD_PATH}"
      clean: true
  postActions:                    # экшены после сборки компонентов
    - run: write-recipe
      dst: "{$BUILD_PATH}/recipe.json"
  defaultTarget: www              # см. «Таргеты»
  targets:
    www:
      build:
        - run: bash
          cmd: "npm run build"
      artifact: "dist/project"
```

| Поле | Обязательно | Что значит |
|---|---|---|
| `name` | да | имя проекта; без него проект не загружается. Без `/` |
| `version` | да | целое число; не используется |
| `type` | да | строка; не используется |
| `constant` | да | константы, см. ниже |
| `environment` | нет | ключи environment, см. «Environment» |
| `init` | нет | экшены до сборки компонентов |
| `postActions` | нет | экшены после компонентов, ассетов и environment |
| `targets`, `defaultTarget` | нет | см. «Таргеты» |

Остальные поля внутри `project` игнорируются. Поле `project.target` устарело: билдер печатает
предупреждение и ничего с ним не делает.

### Константы

Каждый ключ `project.constant` становится переменной сборки в `SCREAMING_SNAKE_CASE`:
`assetsPath` → `{$ASSETS_PATH}`, `fontFamilyPath` → `{$FONT_FAMILY_PATH}`, `myDir` → `{$MY_DIR}`.
Значения вычисляются один раз в начале сборки.

| Константа | Нужна | Что делает |
|---|---|---|
| `assetsPath` | всегда | куда копируются папки `assets` компонентов. **Без нее сборка падает** (паника, код 101) |
| `fontFamilyPath` | всегда | файл со шрифтами лейаута. Без нее - ошибка |
| `iconsPath` | если есть иконки | файл с иконками |
| `fontsPath`, `publicFontsPath` | если в рецепте свой шрифт | куда скачать шрифт и какой путь написать в `@font-face` |
| `environmentPath` | если в манифесте есть `environment` | куда записать environment |
| `componentsDestinationPath` | нет | куда складывать компоненты; по умолчанию `{$BUILD_PATH}/components` |

> ⚠️ Папка для файлов `fontFamilyPath`, `iconsPath`, `environmentPath` должна существовать: билдер
> сам ее не создает (`No such file or directory`). Обычно ее приносит `init`-копирование проекта.

> ⚠️ В значениях констант используйте только `{$ROOT_PATH}` и `{$BUILD_PATH}`. Порядок вычисления
> констант не определен: ссылка одной константы на другую (`"{$ASSETS_PATH}/x"`) то работает, то
> падает с `variable ASSETS_PATH not found`.

## Манифест компонента

`components/<категория>/<папка>/<папка>.m.yml`:

```yml
unit:
  version: 1                      # обязательно, целое
  name: "Fancy Header"            # обязательно; название для интерфейса
  slug: header1                   # обязательно; ключ компонента <проект>/<slug>
  group: header                   # группа, из которой компонент выбирают в инвентарь
  groups: [main-header]           # для allowedGroups пункта инвентаря
  type: component                 # component (по умолчанию), kit или iconpack
  projects: [layout2]             # каким еще проектам доступен; "*" - всем
  deprecated: "use header2"       # компонент устарел: предупреждение, в автовыборе последний
  hasTemplate: true               # рендерить *.tmpl, см. «Шаблоны»
  componentPrefix: "header.component"   # имя файла выбранного стиля, см. «Стили»
  author: webresto                # любые другие поля сохраняются и доступны шаблонам
  description: "Шапка"
component:
  constant:
    cssVariables:                 # цвета, см. «Цвета»
      - key: primary-color
        value: "$primary-color"
        name: "Основной цвет"
        description: ""
    states:                       # см. «Состояния и переменные»
      - key: visibleCartButton
        default: true
        name: "Кнопка корзины"
        description: ""
        type: boolean
    variables:
      - key: logoLink
        default: "assets/logo.png"
        name: "Логотип"
        description: ""
        type: string
  inventory:                      # места для дочерних компонентов
    cart:
      group: cart
      default: cart1
      description: "Корзина"
  actions:                        # экшены компонента, см. actions.md
    - run: bash
      cmd: "echo {$COMPONENT_BUILD_PATH} >> {$BUILD_PATH}/components.log"
  styles:                         # см. «Стили»
    - name: "Базовый"
      slug: basic
      description: ""
```

### Поля `unit`

| Поле | Обязательно | Что значит |
|---|---|---|
| `version` | да | целое; не используется |
| `name` | да | название для интерфейса |
| `slug` | да | имя компонента; ключ `<проект>/<slug>`. Принято совпадать с папкой, но не обязательно |
| `group` | нет | группа выбора. Без нее компонент никуда не выбирается. `layout` - лейаут |
| `groups` | нет | список групп для `allowedGroups` пункта инвентаря |
| `type` | нет | `component` (по умолчанию), `kit`, `iconpack`; на сборку не влияет. Другое значение (`layout`, `header`) - манифест не разбирается |
| `projects` | нет | проекты, которым компонент доступен кроме своего; `"*"` - всем |
| `deprecated` | нет | строка-пояснение: при загрузке предупреждение, в автовыборе компонент последний |
| `hasTemplate` | нет | `true` - рендерить `*.tmpl` |
| `componentPrefix` | если есть `styles` | имя файла стиля в сборке: `<componentPrefix>.scss` |
| `onlyIn` | - | устарело и игнорируется, предупреждение. Вместо него `projects` и `allowedGroups`/`groups` |
| `postActions` | - | `true`/`false`; есть в схеме и в манифестах фабрики, билдер его не читает |
| любое другое (`author`, `description`, ...) | нет | сохраняется, видно в шаблонах |

### Поля `component`

Строгая секция: любое поле, кроме перечисленных, делает манифест неразбираемым (компонент пропадает).

| Поле | Что значит | Для кого |
|---|---|---|
| `constant` | `cssVariables`, `states`, `variables` | все |
| `inventory` | места для дочерних компонентов | все |
| `actions` | экшены компонента ([actions.md](actions.md)) | все |
| `styles` | варианты стиля | пункты инвентаря (у лейаута не применяются) |
| `iconSet` | нужные иконки | только лейаут |
| `fonts`, `availableFonts` | слоты шрифтов и доступные шрифты | только лейаут |

### Константы компонента

`cssVariables`, `states`, `variables` - списки объектов. Билдер читает из них только ключ и
значение; остальные поля - описание для интерфейса и для генератора JSON-схемы рецепта фабрики
(`builder-schema` в репозитории фабрики), их проверяет схема манифеста:

| Поле | `cssVariables` | `states` / `variables` | Что значит |
|---|---|---|---|
| `key` | да | да | ключ |
| `value` | да | - | цвет, ссылка `$key` или макрос `!Accent(...)` |
| `default` | - | да | значение по умолчанию |
| `name`, `description` | да | да | название и описание для пользователя |
| `type` | - | да | `string`, `boolean`, `number`, `array` - тип поля в схеме рецепта |
| `options` | - | да | список `{ name, slug, description }`; в схеме рецепта - допустимые `slug` |
| `arrayType` | - | да | для `array`: `string`, `number` или список полей объекта `{ key, type, description, options }` |
| `pro`, `beta` | да | да | флаги для интерфейса |

Значение `default`: строка, целое число, `true`/`false`, массив строк, массив объектов, объект.
Дробные числа билдер не поддерживает - манифест с ними не разбирается (схема их пропускает).

### Инвентарь

Пункт инвентаря:

| Поле | Что значит |
|---|---|
| `group` | группа, из которой выбирается компонент. Строка или список (берется первый элемент). Без `group` - имя пункта |
| `default` | компонент по умолчанию: `slug` или `<проект>/<slug>` |
| `allowedGroups` | если задано, выбранный компонент обязан иметь хотя бы одну из этих групп в `unit.groups` |
| `type` | `component` или `kit`; на сборку не влияет. Другое значение - манифест не разбирается |
| остальное (`description`, ...) | не используется билдером |

Глубина: лейаут → его пункты → инвентарь компонентов, выбранных в эти пункты. Инвентарь на третьем
уровне билдер не собирает и не проверяет.

### Лейаут

Полный пример лейаута:

```yml
unit:
  version: 1
  name: "Основной"
  slug: layout1
  group: layout                   # это и делает компонент лейаутом
  author: webresto
  description: "Главная страница"
component:
  constant:
    cssVariables:
      - key: primary-color
        value: "#8252F4"
        name: "Основной цвет"
        description: ""
    states:
      - key: copyright
        default: "Webresto team"
        name: "Копирайт"
        description: ""
        type: string
  inventory:                      # места для компонентов
    header:
      group: header
      default: header1
      description: "Шапка"
    cart:
      group: [cart, mini-cart]    # из списка берется первая группа
      allowedGroups: [shop]       # подойдут только компоненты с groups: [shop]
      description: "Корзина"
    footer:                       # без group: группа - footer
      description: "Подвал"
  iconSet:                        # иконки, которые нужны проекту
    - iconName: cart
      description: "Иконка корзины"
  fonts:                          # слоты шрифтов; переменная $font-<слот>
    main:
      default: Roboto
      description: "Основной шрифт"
    secondary:
      default: Montserrat
      description: "Запасной шрифт"
  availableFonts:                 # из чего можно выбирать
    - name: Roboto
      link: "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap"
    - name: Montserrat
      link: "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap"
  actions:
    - run: bash
      cmd: "echo layout >> {$BUILD_PATH}/build.log"
```

## Иконпак

```yml
unit:
  version: 1
  name: icons1
  slug: icons1
  type: iconpack
  author: webresto
  description: "Первый пак иконок"
iconPack:
  - iconName: cart
    svg: '<svg width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>'
  - iconName: social
    svg: '<svg width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>'
```

Лежит там же, где компоненты (`components/<категория>/icons1/icons1.m.yml`). Иконпаком файл делает
поле `iconPack` (и отсутствие `component`). В рецепте иконпак называется полным именем
`<проект>/<slug>`, например `base_layouts/icons1`.

## Рецепт

```json
{
  "unit": "base_layouts/layout1",
  "target": "www",
  "constant": {
    "cssVariables": { "primary-color": "#8252F4" },
    "states": { "visibleCartButton": true },
    "variables": { "logoLink": "https://example.org/logo.png" }
  },
  "inventory": {
    "header": {
      "unit": "header2",
      "style": "wave",
      "constant": { "variables": { "facebookLink": "https://facebook.com/x" } }
    },
    "cart": {}
  },
  "environment": { "base": "https://api.example.org" },
  "fonts": { "main": "Roboto" },
  "iconPack": "base_layouts/icons1",
  "iconOverrides": [
    { "iconName": "cart", "unit": "base_layouts/icons2" },
    { "iconName": "social", "svg": "<svg>...</svg>" }
  ],
  "snippets": {
    "head": ["<meta name=\"robots\" content=\"noindex\">"],
    "bodyTop": [],
    "bodyBottom": ["<script src=\"/x.js\"></script>"]
  },
  "assets": [
    { "path": "{$ASSETS_PATH}/robots.txt", "blob": "VXNlci1hZ2VudDogKgo=" }
  ],
  "wrapper": { "cordova": { "env": { "APP_ID": "com.x.y" } } },
  "patch": { "diff": "--- a/x.txt\n+++ b/x.txt\n@@ -1 +1 @@\n-old\n+new\n", "strip": 1 }
}
```

Корень рецепта:

| Поле | Что значит |
|---|---|
| `unit` | лейаут: `<проект>/<slug>`; без префикса - проект `base_layouts` |
| `inventory` | выбор и настройки компонентов по ключам пунктов инвентаря |
| `constant` | `cssVariables`, `states`, `variables` лейаута; `states` и `variables` также служат общими значениями для всех компонентов |
| `environment` | значения environment, см. «Environment» |
| `fonts` | шрифт для слотов лейаута, см. «Шрифты» |
| `iconPack`, `iconOverrides` | иконки, см. «Иконки» |
| `snippets` | HTML-вставки в `index.html`, см. «Сниппеты» |
| `assets` | файлы из рецепта, см. [assets.md](assets.md) |
| `patch` | дифф поверх готовой сборки, см. «Патч» |
| `target` | таргет, см. «Таргеты». Только в корне |
| `wrapper` | произвольный JSON; билдер его не читает, кроме проверки `requires` таргета |

Пункт `inventory`:

| Поле | Что значит |
|---|---|
| `unit` | компонент: `slug` или `<проект>/<slug>` |
| `constant` | `cssVariables`, `states`, `variables` этого компонента |
| `style` | `slug` стиля компонента |

Неизвестные поля рецепта игнорируются. Ключ `inventory`, которого нет ни у лейаута, ни у его
компонентов, - предупреждение, сборка идет дальше.

> **Рецепт плоский.** Пункты вложенного инвентаря (инвентаря компонента, стоящего в лейауте)
> задаются в `inventory` корня рецепта по своему ключу, а не внутри пункта родителя. Вложенный
> `inventory` внутри пункта рецепта не читается.

`builder` читает рецепт как строгий JSON (комментарии - ошибка разбора). chefkit комментарии в
рецепте допускает.

## Выбор компонентов

Для каждого пункта инвентаря компонент выбирается так:

1. `unit` пункта в рецепте, если он указан и не пустой;
2. иначе `default` пункта инвентаря;
3. иначе автоматический выбор.

Группа пункта - его `group` (из списка - первая), без `group` - имя пункта.

Короткое имя (`header2`) ищется сначала в проекте компонента-родителя (для вложенного инвентаря),
затем в проекте лейаута. Полное имя (`layout2/header2`) - как есть.

### Доступ между проектами: `unit.projects`

По умолчанию компонент доступен только лейаутам своего проекта.

```yml
unit:
  slug: header-shared
  group: header
  projects: [base_layouts, layout2]   # имена проектов (project.name); "*" - любой проект
```

- поле не указано - компонент только для своего проекта;
- указано - свой проект (всегда) и перечисленные;
- `projects: ["*"]` - любой проект.

Пункты вложенного инвентаря видят приватные компоненты проекта своего родителя: общий компонент
из `repoB`, поставленный в лейаут `repoA`, может использовать приватные компоненты `repoB`.

Внутри проекта ограничить выбор можно через `allowedGroups` пункта и `groups` компонента.

### Автоматический выбор

Кандидаты - компоненты группы, доступные этому месту (`projects` и `allowedGroups`). Порядок:
проект родителя, проект лейаута, затем общие компоненты других проектов; внутри - сначала не
устаревшие, затем по алфавиту `slug`. Берется первый. Результат не зависит от запуска.

Если кандидатов нет - ошибка с подсказкой задать `default` или открыть компонент через
`unit.projects`.

### Переходный период

Если `unit` рецепта или `default` пункта называет приватный компонент чужого проекта, сборка пока
проходит, но билдер печатает рамку `DEPRECATED ... WILL BECOME AN ERROR in builder 1.0`.
Автоматический выбор такие компоненты не берет никогда. Ограничение `allowedGroups` проверяется
всегда, в том числе для `unit` и `default`.

## Проверка рецепта

До создания выходной папки билдер проверяет:

- лейаут существует;
- каждый пункт инвентаря лейаута и один вложенный уровень разрешаются в компонент (ровно то, что
  потом собирается, а не только пункты, названные в рецепте);
- таргет (см. «Таргеты»): объявлен, `requires` выполнен, `target` только в корне;
- `patch` разбирается и безопасен.

Ошибка останавливает сборку: выходная папка не создается, код выхода 255.

## Как идет сборка

`builder build`:

1. Обход библиотеки и проверка рецепта.
2. Создание выходной папки; путь становится абсолютным (`{$BUILD_PATH}` не зависит от текущего
   каталога).
3. Переменные сборки и константы проекта.
4. `project.init`.
5. Лейаут: файлы компонента → цвета → иконки → сниппеты → шрифты → `config.*` →
   `component.config.ts` → шаблоны → `component.actions`.
6. Пункты инвентаря лейаута в алфавитном порядке ключей, для каждого: файлы компонента → цвета →
   стиль → `config.*` → `component.config.ts` → шаблоны → `component.actions`; затем его вложенный
   инвентарь тем же порядком.
7. `assets` рецепта.
8. Environment.
9. `project.postActions`.
10. `patch` рецепта.
11. `archive.tar.gz`.
12. Таргет: `before` → `build` → `after`, проверка `artifact`, `.factory-target.json`.

chefkit выполняет шаги 1-10: архив не делает, таргет не собирает.

Любая ошибка останавливает сборку; уже записанные файлы остаются в выходной папке.

### Файлы компонента в сборке

Папка компонента в сборке (`{$COMPONENT_BUILD_PATH}`):

| Компонент | Папка |
|---|---|
| лейаут | `{$COMPONENTS_DESTINATION_PATH}/layout` |
| пункт `header` лейаута | `{$COMPONENTS_DESTINATION_PATH}/header` |
| пункт `widget` компонента из пункта `header` | `{$COMPONENTS_DESTINATION_PATH}/header/components/widget` |

`{$COMPONENTS_DESTINATION_PATH}` - константа `componentsDestinationPath` или `{$BUILD_PATH}/components`.

Билдер очищает эту папку и копирует в нее всю папку компонента, кроме файлов `*.m.yml`. Если у
компонента есть папка `assets`, ее содержимое дополнительно копируется в `{$ASSETS_PATH}` с
сохранением структуры (см. [assets.md](assets.md)).

### Цвета: `colors.scss`, `colors.json`

Источник - `component.constant.cssVariables`: список `{ key, value }`. Значение в рецепте -
`constant.cssVariables` того же уровня (корень рецепта для лейаута, пункт `inventory` для
компонента).

Значение может быть:

- обычным: `"#fff"`, `"red"`;
- ссылкой: `"$primary-color"`;
- макросом: `"!Accent(#336699, 0.12)"` или `"!Accent($primary-color, 0.12)"`.

Для каждой переменной компонента:

1. значение из рецепта, иначе из манифеста;
2. ссылка `$key` (кроме лейаута) берется из `constant.cssVariables` корня рецепта, иначе из манифеста
   родителя (для пунктов лейаута - из лейаута), иначе из своих переменных;
3. макрос `!Accent(цвет, доля)` (кроме лейаута): цвет `#rgb`/`#rrggbb` или `$key`; если цвет темный
   (среднее RGB < 0.5), он смешивается с белым на `доля`, иначе - с черным. Результат - hex.
   Неизвестный макрос остается как есть.

Ключи из рецепта, которых нет в манифесте, тоже попадают в файлы. У лейаута ссылки разрешаются
только на его же переменные, макросы не вычисляются.

Пример: лейаут объявляет `primary-color: "#ff00ff"`, рецепт задает в корне
`"cssVariables": { "primary-color": "#1e3a8a" }`, шапка объявляет
`primary-color: "$primary-color"` и `hover-color: "!Accent($primary-color, 0.2)"`:

```scss
// components/layout/colors.scss
$primary-color: #1e3a8a;

// components/header/colors.scss
$hover-color: #4B61A1;
$primary-color: #1e3a8a;
```

```json
// components/header/colors.json
{"hover-color":"#4B61A1","primary-color":"#1e3a8a"}
```

### Состояния и переменные: `config.json`, `config.ts`, `component.config.ts`

`states` и `variables` - значения, которые компонент читает в рантайме: переключатели логики и
отображения, ссылки, тексты. Источник - `component.constant.states` и `component.constant.variables`
(списки `{ key, default }`). Значения в рецепте - `constant.states` и `constant.variables` (объекты
`ключ: значение`).

Для каждого объявленного ключа:

1. значение из своего пункта рецепта (у лейаута - корень рецепта);
2. иначе из `constant` корня рецепта;
3. иначе `default` из манифеста (пустая строка считается «не задано»);
4. иначе `default` того же ключа у родителя.

В файлы попадают только ключи, объявленные в манифесте компонента. `states` и `variables` пишутся
одним объектом; при совпадении ключа побеждает `variables`.

Манифест:

```yml
component:
  constant:
    variables:
      - key: logoLink
        default: assets/img/page-1/product/foto-1.png
      - key: facebookLink
        default: https://facebook.com
      - key: instagramLink
        default: https://instagram.com
      - key: menu
        default:
          - { title: "Главная", url: "/" }
          - { title: "Меню", url: "/menu" }
    states:
      - key: visibleLoginButton
        default: false
      - key: visibleCartButton
        default: true
```

Рецепт:

```json
"inventory": {
  "header": {
    "constant": {
      "variables": { "logoLink": "https://example.org/logo.png", "facebookLink": "https://example.com" },
      "states": { "visibleLoginButton": true }
    }
  }
}
```

Результат:

```json
// config.json
{
  "facebookLink": "https://example.com",
  "instagramLink": "https://instagram.com",
  "logoLink": "https://example.org/logo.png",
  "menu": [
    {
      "title": "Главная",
      "url": "/"
    },
    {
      "title": "Меню",
      "url": "/menu"
    }
  ],
  "visibleCartButton": true,
  "visibleLoginButton": true
}
```

```ts
// config.ts
export default {
    facebookLink: "https://example.com",
    instagramLink: "https://instagram.com",
    logoLink: "https://example.org/logo.png",
    menu: [{ "title": "Главная", "url": "/"}, { "title": "Меню", "url": "/menu"}],
    visibleCartButton: true,
    visibleLoginButton: true,
}
```

```ts
// component.config.ts: те же значения + цвета из colors.json
export default {
    config: {
        facebookLink: "https://example.com",
        ...
    },
    styles: {
        "primary-color": "#1e3a8a",
    }
}
```

Ключи во всех файлах отсортированы, вывод не меняется от запуска к запуску. Строки в `config.ts` и
`component.config.ts` пишутся в двойных кавычках без экранирования: `"` внутри значения сломает
TypeScript - используйте `config.json`.

### Стили

Только для пунктов инвентаря (у лейаута не применяется).

```yml
unit:
  componentPrefix: "dish-card.component"
component:
  styles:
    - name: styleOne
      slug: style1
      description: Just first style
    - name: secondStyle
      slug: style2
      description: Second style
```

Билдер берет стиль `style` из пункта рецепта (по умолчанию - первый в списке) и копирует
`<компонент>/styles/<slug>.scss` в `{$COMPONENT_BUILD_PATH}/<componentPrefix>.scss`
(здесь `dish-card.component.scss`). Если файл с таким именем был среди файлов компонента, он
заменяется. Так Angular-компонент получает нужный стиль.

- `componentPrefix` обязателен, если есть `styles`; нет файла стиля или префикса - ошибка.
- `style`, которого нет в списке, - стиль не копируется, сборка идет дальше.
- При каждом копировании печатается предупреждение `styles (themes) [deprecation warning]`
  (см. [ideas.md](ideas.md)).

### Шаблоны

Если у компонента `unit.hasTemplate: true`, после копирования билдер рекурсивно обходит
`{$COMPONENT_BUILD_PATH}`, рендерит каждый `*.tmpl` движком
[TinyTemplate](https://docs.rs/tinytemplate) и пишет результат рядом без `.tmpl`; файл `.tmpl`
удаляется.

Данные шаблона - **только секция `unit` манифеста** этого компонента: `slug`, `name`, `version`,
`group`, `componentPrefix`, ... и любые свои поля `unit` (`author`, `description`).

```
comp1/1/2/3/some.txt.tmpl:              This is {slug}
→ {$COMPONENT_BUILD_PATH}/1/2/3/some.txt:  This is comp1
```

Возможности TinyTemplate:

- значение - `{ slug }`;
- условие - `{{ if hasTemplate }}да{{ else }}нет{{ endif }}`;
- цикл - `{{ for g in groups }}{ g }{{ endfor }}`.

Ошибка рендера останавливает сборку.

### Иконки

Только у лейаута. Лейаут перечисляет нужные иконки:

```yml
component:
  iconSet:
    - iconName: "app-vk"
      description: "Иконка для ссылки на страницу во ВКонтакте"
    - iconName: "app-fb"
      description: "Иконка для ссылки на страницу в Facebook"
```

Рецепт выбирает иконпак и замены:

```json
"iconPack": "base_layouts/icons1",
"iconOverrides": [
  { "iconName": "app-vk", "unit": "base_layouts/icons2" },
  { "iconName": "app-fb", "svg": "<svg>...</svg>" }
]
```

Набор иконок = все иконки `iconPack` + замены (`svg` или иконка из другого пака `unit`). Если набор
не пуст, билдер пишет в `{$ICONS_PATH}` иконки из `iconSet` лейаута, отсортированные по имени:

```ts
export const icons: IconRegistrationInfo[] = [
  {
    "iconName": "app-fb",
    "htmlSvgText": "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\">...</svg>"
  },
  {
    "iconName": "app-vk",
    "htmlSvgText": "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\">...</svg>"
  }
]
```

Тип объявляет проект, билдер импорт не пишет:

```ts
interface IconRegistrationInfo {
  iconName: string;     // название иконки
  htmlSvgText: string;  // SVG
}
```

- Нет `iconPack` и `iconOverrides` - файл не создается. Есть пак, но `iconSet` пуст - пустой массив.
- Иконки из `iconSet` нет в наборе, неизвестный пак, нет `iconsPath` - ошибка.
- `iconSet` компонентов инвентаря не используется.

### Шрифты

Только у лейаута. Лейаут объявляет слоты и доступные шрифты:

```yml
component:
  fonts:                          # слоты
    main:
      description: "Основной"
      default: Roboto             # шрифт, если рецепт ничего не выбрал
    secondary:
      description: "Запасной"
      default: Courier
  availableFonts:
    - name: Roboto
      link: "https://fonts.googleapis.com/css2?family=Roboto:wght@700&display=swap"
    - name: Helvetica
      link: "https://fonts.googleapis.com/css2?family=Helvetica:ital,wght@0,700;1,700"
    - name: Courier
      link: "https://fonts.googleapis.com/css2?family=Courier:wght@700"
```

Рецепт выбирает шрифт для слота:

```json
"fonts": { "secondary": "Helvetica" }
```

1. В `{$FONT_FAMILY_PATH}` для каждого слота пишется переменная:

   ```scss
   $font-main: "Roboto";        // из default
   $font-secondary: "Helvetica"; // из рецепта
   ```

2. В `{$BUILD_PATH}/src/index.html` блок между `<!--font loaded here-->` и `<!--end font-->`
   заменяется ссылками на выбранные шрифты из `availableFonts`:

   ```html
   <!--font loaded here-->
     <link href="https://fonts.googleapis.com/css2?family=Helvetica:ital,wght@0,700;1,700" rel="stylesheet"/>
     <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@700&display=swap" rel="stylesheet"/>
   <!--end font-->
   ```

   Не удаляйте маркеры из `index.html`: без них блок не заменяется (сборка идет дальше).
3. Шрифт, которого нет в `availableFonts`, - предупреждение; переменная получает его имя как есть,
   ссылка не добавляется.

**Свой шрифт.** Значение слота вида:

```json
"fonts": { "main": "url(https://cdn.example.com/reef.woff2) name(Reef) weights(400,700)" }
```

Билдер скачивает файл в `{$FONTS_PATH}/Reef.woff2` и пишет в `{$FONT_FAMILY_PATH}` `@font-face` на
каждый вес:

```scss
@font-face {
    font-family: "Reef";
    font-display: swap;
    src: local("Reef"),
    url('/assets/fonts/Reef.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
}
/* ... то же для 700 ... */
$font-main: "Reef";
```

Можно дать по файлу на вес - `url(a.woff2) url(b.woff2) name(Reef) weights(400,700)`: тогда файлы
`Reef-400.woff2`, `Reef-700.woff2`. Нужны константы `fontsPath` и `publicFontsPath` (путь в
`url(...)`). Без `url(...)`/`name(...)`/`weights(...)` сборка останавливается. Скачивание идет тем же
механизмом, что и ассеты по ссылке (кеш, без `hash`), см. [assets.md](assets.md).

Файл `{$FONT_FAMILY_PATH}` пишется всегда, даже если слотов нет.

### Сниппеты

Билдер вставляет произвольные HTML-теги в разные части страницы. Он берет
`{$ROOT_PATH}/project/src/index.html` **из библиотеки**, заменяет в нем все между маркерами и
пишет результат в `{$BUILD_PATH}/src/index.html`.

```json
"snippets": {
  "head": ["<title>Site title</title>", "<link rel=\"stylesheet\" href=\"style.css\"/>"],
  "bodyTop": ["<script src=\"anything.js\"></script>"],
  "bodyBottom": ["<script src=\"anything2.js\"></script>"]
}
```

| Поле `snippets` | Маркеры |
|---|---|
| `head` | `<!--begin head snippet-->` ... `<!--end head snippet-->` |
| `bodyTop` | `<!--begin body top snippet-->` ... `<!--end body top snippet-->` |
| `bodyBottom` | `<!--begin body bottom snippet-->` ... `<!--end body bottom snippet-->` |

```html
<head>
  <!--begin head snippet-->
	<title>Site title</title>
	<link rel="stylesheet" href="style.css"/>
	<!--end head snippet-->
</head>
<body>
  <!--begin body top snippet-->
	<script src="anything.js"></script>
	<!--end body top snippet-->
  <app-root></app-root>
  <!--begin body bottom snippet-->
	<script src="anything2.js"></script>
	<!--end body bottom snippet-->
</body>
```

Нет маркера - предупреждение, блок пропускается. Без `snippets` блоки очищаются.

- `project/src/index.html` обязателен для любой сборки: без него - ошибка.
- Файл берется из библиотеки, поэтому правки `{$BUILD_PATH}/src/index.html`, сделанные в
  `project.init`, затираются. Меняйте `index.html` в `postActions` или патчем.

### Environment

Связка значений из манифеста проекта и рецепта на уровне проекта. Генерируется, если в манифесте
есть `environment`:

```yml
project:
  constant:
    environmentPath: "{$BUILD_PATH}/environment.json"   # куда записать
  environment:
    - key: base
      required: true
    - key: gqlPath
      required: true
      default: "/graphql"
      name: "GraphQL"            # прочие поля - для интерфейса
      description: "Путь к GraphQL"
      type: "string"
```

| Поле | Что значит |
|---|---|
| `key` | ключ |
| `required` | `true`/`false`; само поле обязательно, без него манифест не разбирается |
| `default` | значение, если ключа нет в рецепте; только для `required: true` |
| прочее | для интерфейса |

Рецепт:

```json
"environment": {
  "hosts": { "prod": "https://api.example.org", "dev": "https://dev.example.org" },
  "mode": "dev",
  "analytics": "G-XXXX"
}
```

В `{$ENVIRONMENT_PATH}` пишется JSON с отсортированными ключами:

- **все** ключи `environment` из рецепта, в том числе не объявленные в манифесте;
- `default` объявленного ключа подставляется, только если у ключа `required: true` и его нет в
  рецепте; у необязательных ключей `default` не используется;
- нет обязательного ключа и нет `default` - ошибка;
- если в рецепте есть `hosts` (объект) и `mode` (строка), а `base` или `imageLink` не заданы, они
  берутся из `hosts[mode]`;
- если манифест объявляет ключ `base`, в итоге он обязан быть (явно или из `hosts`+`mode`).

Результат для примера:

```json
{
  "analytics": "G-XXXX",
  "base": "https://dev.example.org",
  "gqlPath": "/graphql",
  "hosts": {
    "dev": "https://dev.example.org",
    "prod": "https://api.example.org"
  },
  "imageLink": "https://dev.example.org",
  "mode": "dev"
}
```

### Ассеты рецепта

Поле `assets` - файлы, которые нужно положить в сборку: base64 (`blob`), по ссылке (`link`, архивы
`.zip`/`.tar`/`.tar.gz`/`.tgz` распаковываются) или с диска (`localPath`, файл или папка).

```json
"assets": [
  { "path": "{$ASSETS_PATH}/public/robots.txt", "blob": "VXNlci1hZ2VudDogbnNhCkRpc2FsbG93OiAvCg==" },
  { "path": "{$ASSETS_PATH}/example.html", "link": "https://example.com", "hash": "ea8fac7c65fb589b0d53560f5251f74f9e9b243478dcb6b3ea79b5e36449c8d9" },
  { "path": "{$ASSETS_PATH}/shared", "localPath": "{$ROOT_PATH}/assets/shared" }
]
```

Подробно - [assets.md](assets.md).

### Патч

Иногда нужно зафиксировать собранную версию проекта и точечно ее доработать - изменить сразу
несколько файлов уже после сборки, не трогая компоненты и манифесты. Для этого рецепт может нести
унифицированный дифф (`git diff` или `diff -u`). Это встроенный шаг сборки: он применяется всегда
последним, после `postActions`, до архива.

```json
"patch": {
  "diff": "--- a/components/layout/something.txt\n+++ b/components/layout/something.txt\n@@ -1 +1 @@\n-old line\n+new line\n",
  "strip": 1
}
```

- `diff` - текст диффа, может менять сразу несколько файлов: изменение, создание (`--- /dev/null`),
  удаление (`+++ /dev/null`), переименование, копирование. Заголовки git (`diff --git`,
  `new file mode`, `index ...`) допускаются.
- `strip` (по умолчанию `1`) - сколько компонентов пути отбросить, как `patch -pN`; `1` - git-стиль
  `a/`, `b/`.
- Пути - относительные, внутри папки сборки: `..` и абсолютные пути запрещены.
- Бинарные патчи не поддерживаются.
- Дифф проверяется до сборки; не разбирается или небезопасен - сборка не начинается.
- Контекст не совпадает с файлом - ошибка, как у `patch`/`git apply`.

Получить дифф: соберите проект, сделайте копию, поправьте файлы, `diff -ruN out out-edited` или
`git diff` в папке сборки.

### Таргеты

Таргет - во что собирается сгенерированный проект: сайт, приложение Android, iOS. Таргеты объявляет
манифест проекта, рецепт выбирает один.

```yml
project:
  name: base_layouts
  defaultTarget: www
  targets:
    www:
      description: Сайт
      before:
        - run: bash
          name: deps
          cmd: "bash {$ROOT_PATH}/ci/cache.sh link {$BUILD_PATH}"
      build:
        - run: bash
          cmd: "npm run build"
      artifact: "dist/project"
    android:
      description: Приложение Android (Cordova)
      requires: [wrapper.cordova]
      before: [...]
      build:
        - run: bash
          cmd: "npx ng build -c cordova"
        - run: bash
          cmd: "cd mobile-base-app && npm ci --legacy-peer-deps && npm run generate-config"
      artifact: "mobile-base-app"
```

```json
{ "unit": "layout1", "target": "android", "wrapper": { "cordova": { "env": { "APP_ID": "com.x.y" } } } }
```

Поля таргета:

- `description` - для интерфейса и схемы рецепта; билдером не используется;
- `requires` - пути в рецепте через точку (`wrapper.cordova`), которые должны быть заданы и не
  `null`; проверяется до сборки;
- `before`, `build`, `after` - списки экшенов ([actions.md](actions.md)). Выполняются подряд в
  `{$BUILD_PATH}`; первый упавший шаг останавливает сборку, следующие (и `after`) не выполняются;
- `artifact` - путь результата относительно `{$BUILD_PATH}`; после `after` билдер проверяет, что он
  существует.

Имя таргета - `^[a-z0-9][a-z0-9-]*$`; `defaultTarget` должен быть объявлен в `targets`. Иначе
манифест не загружается (ошибка с путем).

Выбор:

| `target` рецепта | Манифест | Результат |
|---|---|---|
| нет | нет `targets` | только генерация |
| нет | есть `defaultTarget` | собирается `defaultTarget` |
| нет | `targets` без `defaultTarget` | только генерация + предупреждение |
| есть | имя объявлено | собирается он |
| есть | имени нет / `targets` не объявлены | ошибка со списком доступных, выходная папка не создается |
| любой | `requires` не выполнен | ошибка до генерации |

`target` задается только в корне рецепта; во вложенном `inventory` - ошибка.

После успешной сборки таргета билдер пишет `<output>/.factory-target.json` - по нему скрипты
узнают, что собрано и где результат:

```json
{ "target": "www", "artifact": "dist/project" }
```

В шагах таргета доступны все переменные сборки и `{$TARGET}`; окружение процесса наследуется
(скрипты видят `CACHE_ROOT`, `ANDROID_HOME` и т.д.). `--skip-target` (или `SKIP_TARGET=1`) отключает
таргет: только генерация и архив. chefkit таргет не выполняет никогда.

> В `cmd` фигурные скобки означают выражение билдера (`{$VAR}`); `${VAR:-x}` и `{ a; b; }` пишутся в
> файле-скрипте.

### Архив

После генерации (до таргета) билдер упаковывает выходную папку в `<output>/archive.tar.gz` (системным
`tar`), без `node_modules` и самого архива. Это архив исходников сгенерированного проекта; результат
таргета в него не попадает.

## Переменные сборки

Доступны в экшенах (`src`, `dst`, `cmd`), константах проекта, путях ассетов рецепта
(`path`, `localPath`):

| Переменная | Значение |
|---|---|
| `{$ROOT_PATH}` | абсолютный путь к папке проекта лейаута (где `project/` и `components/`); не зависит от имени папки и текущего каталога |
| `{$BUILD_PATH}` | абсолютный путь к папке сборки (относительный `--output` приводится к абсолютному) |
| `{$COMPONENTS_DESTINATION_PATH}` | куда складываются компоненты, см. «Файлы компонента в сборке» |
| `{$COMPONENT_PATH}` | папка, из которой загружен текущий компонент |
| `{$COMPONENT_BUILD_PATH}` | папка текущего компонента в сборке |
| `{$RECIPE_JSON}` | рецепт одной строкой JSON, ключи отсортированы |
| `{$RECIPE_PATH}` | временный файл с рецептом, только в экшенах, см. [actions.md](actions.md) |
| `{$TARGET}` | имя таргета, только в шагах таргета |
| константы проекта | `assetsPath` → `{$ASSETS_PATH}` и т.д., см. «Константы» |

`{$COMPONENT_PATH}` и `{$COMPONENT_BUILD_PATH}` в `project.init` и в шагах таргета указывают на
лейаут, в `postActions` - на последний собранный компонент; там на них лучше не полагаться.

На Windows пути в переменных пишутся через `/` (`C:/work/proj`), чтобы их понимал bash.

### Синтаксис выражений

Все в фигурных скобках - выражение. Работают переменные, строковые литералы, `+`, сравнения `=` и
`!=`, тернарный `? :` и скобки:

```
{$BUILD_PATH}/src                              переменная
{'prefix-' + $TARGET}                          конкатенация
{$TARGET = 'www'}                              сравнение: true / false
{$TARGET != 'www'}
{$TARGET = 'www' ? 'site' : 'app'}             тернарный оператор
{$a = '1' ? 'o' + ($b = '3' ? 't' : $b) : 'x'} вложенность и скобки
```

Неизвестная переменная - ошибка (`variable X not found`). Поэтому `${VAR:-x}` или `{ a; b; }` в
`cmd` написать нельзя - выносите такое в скрипт.

## Командная строка

```
builder build --recipe <файл> --components-library <папка> --output <папка> [--skip-target]
builder help build
```

| Аргумент | Переменная окружения | Что значит |
|---|---|---|
| `--recipe` | `RECIPE` | файл рецепта |
| `--components-library` | `COMPONENTS_LIBRARY` | библиотека компонентов |
| `--output` | `OUTPUT` | папка сборки; относительный путь приводится к абсолютному |
| `--skip-target` | `SKIP_TARGET` (не пусто и не `0`) | не собирать таргет |

Другие переменные окружения:

- `LOG_LEVEL` - `debug`, `info` (по умолчанию), `warning`, `error`.

Подкоманда `serve` и аргумент `ENV`/`mode` остались в справке, но ничего не делают (см.
[ideas.md](ideas.md)).

### Лог

Каждая строка - `[уровень] сообщение` (`[debug]`, `[info]`, `[warning]`, `[error]`), в stdout.
Вывод команд `bash` идет в тот же лог построчно (`[info]`). Первая строка - версия и коммит, из
которого собран билдер: `[info] Builder 0.4.0 (1d511b6)`.

### Коды выхода

| Код | Когда |
|---|---|
| 0 | успех |
| 255 | ошибка сборки или проверки рецепта; сообщение с цепочкой причин (`Caused by: 0: ... 1: ...`) |
| 101 | паника: рецепт не разбирается как JSON, нет файла рецепта, нет `assetsPath` |

## Предупреждения и частые ошибки

Предупреждения (сборка идет дальше):

| Сообщение | Что значит |
|---|---|
| `'<папка>' is not used: its project/index.m.yml has no project.name` | проект без имени пропущен |
| `project manifest field project.target is deprecated` | уберите `project.target` из манифеста |
| `Component '<p>/<slug>' is deprecated: ...` | компонент помечен `deprecated` |
| `Component ...: onlyIn is obsolete and ignored` | уберите `onlyIn` |
| `recipe inventory key [x] is not declared by layout [...]` | ключ рецепта не используется |
| `project [x] declares targets but no defaultTarget ...` | таргет не собирается |
| рамка `DEPRECATED ... WILL BECOME AN ERROR in builder 1.0` | приватный компонент чужого проекта, см. «Переходный период» |
| `styles (themes) [deprecation warning]` | печатается при каждом копировании стиля |
| `Selected font X is not found in this layout` | шрифта нет в `availableFonts` |
| `Unable to replace head block ... Skipping` | нет маркеров сниппетов в `index.html` |
| `Remote asset ... does not have a hash field` | у ассета по ссылке нет `hash` |
| `skipping '<путь>' in components library` | папку библиотеки не удалось прочитать (битый симлинк) |

Частые ошибки:

| Сообщение | Причина |
|---|---|
| `couldn't find layout variant [x]` | нет лейаута: опечатка в `unit`, нет `group: layout`, манифест не разобрался (пропущен молча) |
| `can't find unit [x] with group [g]` | у компонента другая группа или манифест не разобрался |
| `no component of group [g] is available to layout ...` | в группе нет доступных компонентов: задайте `default` или откройте компонент через `unit.projects` |
| `collection does not contain group [g]` | ни одного компонента группы |
| `component belongs to project ... not shared with ...` | компонент чужого проекта без `projects` |
| `groups ... do not match allowed in this layout` | не подходит под `allowedGroups` |
| `error reading project index.html` | нет `project/src/index.html` |
| `fontFamilyPath is not supplied` | нет константы `fontFamilyPath` |
| `cannot find iconsPath variable in manifest` | нужны иконки, но нет `iconsPath` |
| `can't find environmentPath in manifest` | есть `environment`, нет `environmentPath` |
| `No such file or directory` при записи шрифтов/иконок/environment | нет папки для файла |
| паника в `copy_files.rs` | нет константы `assetsPath` |
| `variable X not found` | переменной нет: опечатка, `{...}` в `cmd`, константа ссылается на константу |
| `environment in config does not contain 'x' (required = true)` | обязательный ключ environment не задан |
| `environment must define either 'base' or 'hosts' + 'mode'` | см. «Environment» |
| `unknown target [x] of project [p]. available: [...]` | таргета нет в манифесте |
| `target [x] requires [path] in the recipe` | не выполнен `requires` |
| `target [x] did not produce its artifact [...]` | после шагов таргета нет `artifact` |
| `action <name> failed: exit code N` | упала команда `bash` |

## Проверка манифестов

JSON-схемы манифестов лежат в `schema/`:

- `schema/component.m.json` - манифест компонента и иконпака;
- `schema/index.m.json` - манифест проекта.

Схемы ведутся вручную; тест `component_schema_copies_match` следит, чтобы копия
`.ci/npm/validator/schema/component.m.json` совпадала со `schema/component.m.json`. CI публикует
схемы на сайт документации.

Проверка манифестов компонентов:

```bash
make validate                     # из корня репозитория билдера, COMPONENTS_PATH=$PWD
chef validate                     # из npm-пакета chefkit, см. chefkit.md
manifest_validate                 # в Docker-образе билдера
```

Валидатор рекурсивно находит `*.m.yml` (кроме `index*`) и проверяет их схемой. На каждую ошибку -
карточка с файлом, путем в манифесте и сообщением; есть ошибки - код 1. Схема строже билдера:
требует `type`, `author`, `description`, `group` в `unit` и `description` у пунктов инвентаря, но
не знает `allowedGroups` и `groups`. Зато она ловит то, что билдер молча пропускает:
неизвестные поля и недопустимые значения `type` (дробные числа схема не ловит).

## Docker-образ

`Dockerfile` собирает образ `git.hm:5050/webresto/factory/builder:<ветка>` на `node:22-slim`:

- `builder` - `/app/project_builder`;
- валидатор манифестов - `/schema_validator`, команда `manifest_validate`;
- Angular CLI, `git`, `jq`, `nginx`, `ssh`.

Образ - базовый для образа фабрики (`FROM git.hm:5050/webresto/factory/builder:${BUILDER_TAG}` в
репозитории фабрики): фабрика копирует свои проекты в `/app/layouts` и вызывает
`/app/project_builder build`. Собственная точка входа образа (`.ci/bootstrap`) - остаток режима
сервера, см. [ideas.md](ideas.md).

## Полезные ссылки

- Разметка колонками и хелперы CSS - https://bulma.io/documentation/columns/
- Документация Angular Material - https://material.angular.io/components/categories
- Генератор иконок для мобильных устройств - https://www.favicon-generator.org/
- TinyTemplate - https://docs.rs/tinytemplate
