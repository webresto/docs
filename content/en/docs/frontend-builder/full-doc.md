---
title: "Спецификация"
linkTitle: "Спецификация"
date: 2017-01-06
description: >
 Билдер - серверная программа, генерирующая код для построения одностраничных приложений из готовых компонентов.
---

# Frontend-builder

Билдер - серверная программа, генерирующая код для построения одностраничных приложений из готовых компонентов.

## Термины

**Рецепт** - Указания в виде JSON по которому генерируется фронтенд *(пример дефолтного конфига должен лежать в корне репозитория файл: **config.json**)*

---

**Библиотека компонентов** - Общая папка со всеми вариациями компонентов.
Эта папка располагается в корневой папке репозитория - /components.
Содержимое этой папки всегда должно быть самым актуальным, потому что именно из её содержимого билдер будет строить проект.


---

**Папка проекта** (`/project`) - Это папка непосредственно с самим проектом, который формируется конструктором из библиотеки компонентов. В ней располагается  *корневой манифест*

---

**Манифест** - Файл `index.m.yml` хранится в корне проекта, содержит технические константы, описания экшенов для Юнитов,

Для каждого репозитория генерируется свой проект

---

**Юнит** (unit) - Базовая строительная единица биллера, описанная через файлы манифестов. Юниты бывают разных типов: *иконпаки, лейоуты, компоненты*

---

**Типы юнитов:**

UNIT: **Layout** - Верстка основной страницы + проект в котором она находится. Выбор лейаута определяет то как будет работать фронтенд, т.к. копируется проект в котором он находится.

> **Инвентори** (inventory) - Список слотов шаблона для заполнения компонентами

---

UNIT: **Component**  -  Наполняют шаблон, компоненты могут переходить между шаблонами (т.е. между проектами). У компоненты может быть 5 настраиваемых свойств (цвета, шрифты, состояния, переменные, стили).
> **Ассеты компонента** - папка с ресурсами которая располагается внутри компонента, после обработки билдером переносится по пути взятого из корневого манифеста.

---

UNIT: **Иконпак (iconpack)** - Набор заранее заготовленых иконок. Преставляет из себя файл yml в котором перечислен набор иконок.

---

**Состояния (переменные)** - также `states` или `variables` , набор переменных которые могут быть заданы билдером во время сборки проекта в файл config.ts компонента, или шаблона. В процессе выполнения приложения будут использованы переключения логики, отображения, или поведения.

---

**Основные цвета** - задаются переменными в yml-файле (см. ниже). Они действует для всех компонентов :
Пример: (значения цветов могут быть любыми)

```scss
primary-color: #ffff11;
secondary-color: #000022;
minor-color: red;
primary-text-color: $minor-color;
secondary-text-color: #707584;
icon-color: $secondary-color;
```

---

## Детальное описание манифестов
Ямлы делятся на два вида:
1. Манифест (index.m.yml)
2. Компонент
    1. Layout - описание верстки с возможностью добавлять дочерние компоненты
    2. Component - единица строения билдера
    3. Icon pack - набор иконок. особый тип компонента

<details>
<summary>Схема манифеста</summary>

```yml
project:
  version: 1 # Версия проекта (?)
  type: "angular" # Тип библиотеки для совместимости
  constant: # Константы и некоторые пути, необходимые для корректной работы
    assetsPath: "{$BUILD_PATH}/src/assets" # Путь, куда копировать файлы из ассетов
    iconsPath: "{$BUILD_PATH}/src/app/material/icons.ts" # Путь до файла, который будет содержать готовые иконки
    fontsPath: "{$BUILD_PATH}/src/styles/vars/font-family.scss" # Путь до scss файла, который будет содеждать выбранные шрифты
  target: # Действия по сборке
    serve: # dev сборка
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && npm install"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && ng serve --base-href /preview"
    build: # production сборка
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && npm install"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && ng build #-c production"

```

</details>

<details>
<summary>Схема layout'а</summary>

```yml
unit:
  # Метаданные. смотри unit
component:
  constant:
    # смотри constant
  inventory:
    # Список дочерних компонентов, которые необходимы этой верстке
    cart:
      type: cart # Название компонента. строка.
      description: blah # Описание слота для фронтенда
      # Дефолтный default компонент. Если это поле не указано и не указано в конфиге, компонент пропускается
      default: cart1
    contacts:
      type: contacts
      description: |
        description will be here
  iconSet: # Список иконок, которые необходимы этой верстке
    - iconName: cart # название иконки
      description: Иконка корзины # Описание иконки
  fonts: # Объект доступных слотов шрифтов
    main: # Например для main сгенерированная переменная будет называться $font-main
      default: Roboto # Шрифт по-умолчанию
      description: This is the main font # Описание для фронтенда
    secondary:
      default: Montserrat
      description: Зачем то запасной шрифт
  availableFonts: # Список доступных шрифтов, которые можно вставить в эту верстку
    - name: Roboto # Название
      link: >- # Ссылка, по которой подключаются этот шрифт
        https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap
    - name: Montserrat
      link: >-
        https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap
  actions:
    # Действия, запускаемые для каждого компонента. Смотри actions

```

</details>

<details>
<summary>Схема компонента</summary>

```yml
unit:
  # смотри unit
component:
  styles: # Возможные стили компонента
    - name: "базовый" # Имя для фронтенда
      slug: "basic" # Имя .scss файла, который будет скопирован в папку компонента как <name>.<component-prefix>.scss
    - name: "волна"
      slug: "wave"
  constant:
    # смотри constant
  iconSet: # Список иконок, которые необходимы этому компоненту
    - iconName: cart # название иконки
      description: Иконка корзины # Описание иконки
  actions:
    # Действия, запускаемые для каждого компонента. Смотри actions

```

</details>

<details>
<summary>Схема пака иконок</summary>

```yml
unit:
  # смотри unit
iconPack: # Список иконок, которые предоставляет этот пак
  - iconName: cart # Название
    svg: > # Svg иконки
      <svg icons1 width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>
```

</details>


<details>
<summary>Общие структуры</summary>


**UNIT**
Метаданные для любого юнита
```yml
unit:
  version: 1 # Версия компонента
  type: header # Тип компонента. layout, iconpack или любая другая строка в других случаях
  author: webresto # Автор компонента
  name: Fancy Header # Название для фронта
  description: blah # Описание для фронта
  slug: header1 # Название компонента, совпадающее с папкой, в которой он находится
  group: "dishcard" # Группа компонента. Уточнить
  shareable: true # Уточнить
  componentPrefix: "dishcard.component" # Постфикс для копируемых файлов (например стилей)
```

**Actions**
Действия, которые умеет выполнять билдер
```yml
actions: # Список
  - run: "copy" # Копировать файлы
    src: "{$COMPONENT_PATH}" # Откуда
    dst: "{$BUILD_PATH}/src/app/components/dishcard" # Куда
    clean: true # Нужно ли удалять всё в папке назначения
  - run: "bash" # Выполнить произвольную shell команду
    cmd: "npm install" # Команда, которая выполнится в $BUILD_PATH
```

**Constant**
```yml
constant:
  cssVariables: # scss переменные
    - key: primary-color # ключ
      value: "#fff" # значение по-умолчание
      name: primary-color # название для пользователя
      description: " " # описание для пользователя
    - key: secondary-color
      value: "#8252F4"
      description: " "
      name: secondary-color
  states:
    - key: copyright # ключ
      default: Webresto team # значение по-умолчанию
      name: Копирайт # название для пользователя
      description: "blah" # описание для пользователя
  variables:
    # То же самое, что и states
```
</details>

## Создание проекта
В этом пункте описывается создание минимального проекта, состоящего из layout'a и компонента. Результат можно найти в репозитории билдера в папке `examples/basic`.
Для начала работы необходима установленная структура файлов и папок:
```
basic
├── components <- папка компонентов
├── project
│   ├── src
│   │   └── index.html <- html заготовка
│   └── index.m.yml <- манифест проекта
└── config.json <- рецепт, которым мы будем строить проект
```

Начнем наполнять файлы. Билдер начинает с манифеста проекта.
В нем описываются шаги выполнения и основная информация по проекту:
```yml
project:
  version: 1
  type: "basic" # Тип проекта. Пока ни на что не влияет
  constant: # Различные пути, с которыми может взаимодействовать билдер. Описаны ниже
    assetsPath: "{$BUILD_PATH}/assets"
    iconsPath: "{$BUILD_PATH}/icons.ts"
    fontsPath: "{$BUILD_PATH}/font-family.scss"
  target: # Шаги построения для разных целей
    serve: # Dev режим для live reload
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && npm install"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && ng serve --base-href /preview"
    build: # Prod режим для построения финального бандла
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && npm install"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && ng build -c production"
```

Наполним index.html базовой структурой HTML документа:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <!--begin fonts snippet-->
  <!--end fonts snippet-->

  <!--begin head snippet-->
  <!--end head snippet-->
</head>
<body>
  <!--begin body top snippet-->
  <!--end body top snippet-->

  <!-- Корневой элемент -->
  <app-root></app-root>

  <!--begin body bottom snippet-->
  <!--end body bottom snippet-->
</body>
</html>
```

Чтобы запустить билдер, нам нужен рецепт - json файл, описывающий структуру генерируемого проекта.
В начале он может быть совсем простой:
```json
{ // config.json
  "unit": "wide", // Версия компонента
  "constant": {},
  "inventory": {}
}
```

Если мы запустим билдер сейчас, он выведет ошибку, так как мы до сих пор не создали главный компонент - layout.
Говоря кратко - у компонентов может быть много различных версий. Каждая такая версия находится в своей папке.
В конфиге мы указали вариант layout'а - wide, значит билдер будет искать файл wide.m.yml в папке components/layout/wide/
Создадим его:
```yml
unit:
  version: 1
  type: "layout"
  name: "layout"
  author: "John Doe"
  slug: "wide"
  description: "Описание этого компонента"
  group: "example-test"
component:
  constant:
    cssVariables:
      - key: "primary-color"
        value: "#ff00ff" # значение по-умолчанию
        description: "Основной цвет"
        name: "primary-color"
  actions: # Копируем файлы этого компонента в build
    build:
      - run: "copy"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && npm install"
      - run: "bash"
        cmd: "cd {$BUILD_PATH} && ng build #-c production"

# Допустим executable билдера достпен в окружении как fbuilder
> fbuilder build --recipe="examples/basic/config.json" --components-library=examples --output=build
```

На выходе у нас получилось примерно такая структура:
```
build
├── components
│   └── layout
│       ├── config.ts
│       └── wide.m.yml
├── src
│   └── index.html
├── archive.tar.gz
└── index.m.yml
```

Отлично. У нас есть минимально работающий проект. Конечно, сейчас компоненты пустые и не особо полезны.
Более сложных примеры можно посмотреть в репозитории base_layouts.

### Добавление дочернего компонента

Допустим мы хотим добавить в наш layout компонент хедера. Так как нам важна реюзабельность, мы напишем для этого ещё один компонент.
Добавим папку components/header/header файл header.m.yml:

```yml
unit:
  version: 1
  type: "header"
  author: "webresto"
  name: "header"
  slug: "header"
  description: "Шапка"
  group: "header"
  shareable: false
  postActions: true
  componentPrefix: "header.component"
component:
  constant:
    cssVariables:
      - key: "primary-color"
        value: "$primary-color" # Компонент наследует цвет из родителя
        description: ""
        name: "primary-color"
```

Изменим layout, чтобы он позволял вставлять header. Для этого создадим пункт inventory:
```yml
# wide.m.yml
unit:
  # ...
component:
  header:
    type: header
    description: Header description
  # ...
```

И напоследок необходимо поправить рецепт, чтобы он знал, какой компонент типа header выбрать.
```json
{
  "unit": "wide",
  "constant": {},
  "inventory": {
    "header": {
      "unit": "header"
    }
  }
}
```

##  Понимание работы билдера

1. Билдер получает на вход конфиг для сборки, и список компонентов.
2. Находит выбранный **шаблон** (**layout**), и загружает список inventory
3. Билдер копирует проект в котором находится нужный шабло
4. По инвентори и рецепту билдер начинает собирать фронтенд
5. Заходя в каждый компонент билдер генерирует: **цвета**, **стили**, **состояния**,
6. В конце билдер добавляет Иконки и Шрифты
7. ...

### Процесс генерации colors.scss

- Билдер берет из секции colors yml-файла компонента список переменных-цветов и их значений.
- При необходимости загружает нужное значение переменной из yml-файла **layout**.
    Например, если стоит
  ```yml
    colors:
      primary-color: $minor-color
  ```
  значит для css-переменной $primary-color он возьмет значение переменной minor-color из yml-файла **layout**.
- Генерирует colors.scss и кладет его в папку к остальным файлам компонента.
  Результат:
  ```scss
  $primary-color: indigo; // значение $minor-color в layout
  ```

### Генерация переменных

```yml
# Описание в ямле
variables:
  - name: Логотип
    key: logoLink
    default: assets/img/page-1/product/foto-1.png
    description: Ссылка на картинку с логотипом
  - name: Фейсбук
    key: facebookLink
    default: https://facebook.com
    description: ссылка на страницу в facebook
  - name: Инстаграм
    key: instagramLink
    default: https://instagram.com
    description: ссылка на страницу в Instagram
states:
  # тоже самое
```

Переменные берутся из `variables` и `states` в рецепте:
```json
// ...
"variables": {
  "logoLink": "https://example.org",
  "facebookLink": "https://example.com",
},
"states": {
  "visibleLoginButton": true,
  "visibleCartButton": true
},
```

На основании отработанных переменных (TODO: описать процесс резолвинга) генерируются `config.ts` и `config.json`.
Примерное содержание:
```json
{
  "logoLink": "https://example.org",
  "facebookLink": "https://example.com",
  "instagramLink": "https://instagram.com",

  "visibleLoginButton": true,
  "visibleCartButton": true
}
```

```ts
export default {
	logoLink: 'https://example.org',
  facebookLink: 'https://example.com',
  instagramLink: 'https://instagram.com',
  visibleLoginButton: true,
  visibleCartButton: true
}
```

### Процесс генерации шрифтов

У layout'а есть набор 'слотов', куда можно воткнуть шрифты, а также список шрифтов, из которого можно выбирать:
```yaml
component:
  # ...
  availableFonts: # Список доступных шрифтов
    - name: Roboto
      link: https://fonts.googleapis.com/css2?family=Roboto:wght@700&display=swap
    - name: Helvetica # Имя
      link: https://fonts.googleapis.com/css2?family=Helvetica:ital,wght@0,700;1,700 # Ссылка на сам шрифт
    - name: Courier
      link: https://fonts.googleapis.com/css2?family=Courier:wght@700
  fonts: # Доступные слоты
    main:
      description: Описание main # Описание для пользователя
      default: Roboto # Шрифт, если в рецепте ничего не придет
    secondary:
      description: Secondary font
      default: Courier
```

Процесс генерации:
1. Билдеру приходит рецепт с полем `fonts`:
```json
"fonts": {
  "secondary": "Helvetica",
},
```
2. Билдер сохраняет в выбранные шрифты в файл, указанный как fontsPath в манифесте:
```scss
  $font-main: 'Roboto'; // Шрифт main был взят из default
  $font-secondary: 'Helvetica'; // Шрифт secondary был перезаписан в рецепте
```

3. Билдер редактирует строку со ссылкой для загрузки шрифта с в файле `index.html`, подставляя в ней необходимое значение family.

```html index.html
  <!--font loaded here-->
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Helvetica:ital,wght@0,700;1,700" rel="stylesheet">
  <!--end font-->
```

> Важно!
> Билдер ориентируется в файле по комментариям вида `<!--font loaded here--> <!--end font-->`
> Не нужно их оттуда удалять!

### Процесс генерации стилей

Когда билдер выбирает стиль, он берет `componentPrefix` из component.m.yml.

```yml
  componentPrefix: dish-card
```
и содержимое файла по пути `styles/${slug}.scss`, где ${slug} - это выбранный стиль в рецепте для сборки.
После чего содержимое файла в `${componentPrefix}.component.scss` заменяется содержимым `styles/${slug}.scss`.
В результате ангуляр проект получает нужный стиль.

Пример стилей в компоненте:

```yml
component:
  styles:
    - name: styleOne
      slug: style1
      description: Just first style
    - name: secondStyle
      slug: style2
      description: secind style
```

### Перенос assets
В папке assets можно разместить любые файлы, чтобы их потом можно было использовать внутри компонента и не зависеть от проекта.
В момент сборки проекта билдер перенесет содержимое папки `assets` компонента в папку которая указанна как папка ассетов проекта в файле `index.m.yml` в константе `assetsPath`

```yml
project:
  constant:
    assetsPath: {$BUILD_PATH}/src/assets
```

**Важно: структура папок при переносе сохраняется**

> Если в проекте не указан путь до assetsPath то берется путь до {$BUILD}

#### Assets в рецепте
Ассеты можно также передавать в рецепте двумя разными способами: base64 строкой или ссылкой на внешний ресурс.
```json
// ...
"assets": [
  {
    "path": "{$ASSETS_PATH}/public/robots.txt",  // Путь, куда сохранить файл
    "blob": "VXNlci1hZ2VudDogbnNhCkRpc2FsbG93OiAvCg==" // https://www.base64encode.org
  },
  {
    "path": "{$ASSETS_PATH}/example.html",
    "link": "https://example.com", // Ссылка на удалённый ассет
    "hash": "ea8fac7c65fb589b0d53560f5251f74f9e9b243478dcb6b3ea79b5e36449c8d9" // SHA256 хеш файла (Рекомендуется указывать, но пока это не обязательно)
  }
  ],
// ...
```

### Сниппеты
Билдер может вставлять произвольные HTML теги в разные части страинцы.
Для того чтобы это сделать, необходимо в рецепте передать поле snippets:
```json
// ...
"snippets": {
  "head": ["<title>Site title</title>", "<link rel=stylesheet href='style.css'/>"],
  "bodyTop": ["<script src='anything.js'/>"],
  "bodyBottom": ["<script src='anything2.js'/>"]
},
// ...
```

Билдер ориентируется по комментариям в index.html. Весь текст между началом и концом заменяется сниппетом из рецепта. Примерно так это должно выглядеть:
```html
<head>
  <!--begin head snippet-->
  ...
	<!--end head snippet-->
</head>

<body>
  <!--begin body top snippet-->
  ...
	<!--end body top snippet-->

  <app-root></app-root>

  <!--begin body bottom snippet-->
  ...
	<!--end body bottom snippet-->
</body>
```


### Генерация иконок
Билдер умеет выбирать генерировать нужные иконки для проекта, основываясь на полях в yaml'ах и рецепте.

Каждый компонент объявляет нужные иконки:
```yml
component:
  iconSet:
    - iconName: "cart"
      description: "Иконка корзины"
    - iconName: "social"
      description: "Иконка соцсети"
    - iconName: "test"
      description: "Иконка test"
    - iconName: "test3"
      description: "Иконка test3"
```

Пак иконок - особый тип ямла:
```yml
  unit:
    version: 1
    type: iconpack # Важно
    author: webresto
    name: icons1
    slug: icons1
    description: 1 пак иконок
  iconPack:
    - iconName: cart
      svg: >
        <svg icons1 width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>
    - iconName: social
      svg: >
        <svg icons1 test="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>
    - iconName: star
      svg: >
        <svg icons3 test="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">...</svg>

```

В рецепте:
```json
...
"iconPack": "icons1", // Какие иконки использовать по умолчанию
"iconOverrides": [ // Какие иконки сдедует перезаписать
  {
    "iconName": "cart",
    "unit": "icons2" // Взять иконку cart из другого пака
  },
  {
    "iconName": "social",
    "svg": "<svg>...</svg>" // Записать иконку social из переданного svg
  }
],

```

После выбора нужных иконок, создается файл по пути `iconsPath`, который можно импортировать в проект при сборке, например:

```yaml
project:
  constant:
    iconsPath: "{$BUILD_PATH}/src/app/material/icons.ts"
```


На выходе получается файл, каждый элемент которого реализует интерфейс IconRegistrationInfo

```ts
export const icons: IconRegistrationInfo[] = [
...массив данных для иконок
];
```

```ts
interface IconRegistrationInfo {
  //название иконки
  iconName: string;

  //строка с её html-кодом
  htmlSvgText: string;
}
```

Например для двух иконок app-vk и app-fb будет такой yml-файл:
```yml layout*.m.yml
  iconSet:
    - iconName: "app-vk"
      description: "Иконка для ссылки на страницу в Vkontakte"
    - iconName: "app-fb"
      description: "Иконка для ссылки на страницу в Facebook"
```
А файл с данными иконок будет такой:
```ts icons.ts
export const icons: IconRegistrationInfo[] = [
  {
    iconName: 'app-vk', htmlSvgText:
      `<svg width="40" height="40" viewBox="0 0 40 40" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19 38C29.4934 38 38 2 .. example .. fill="#C4C4C4"/>
</svg>`},
  {
    iconName: 'app-fb', htmlSvgText:
      `<svg width="40" height="40" viewBox="0 0 40 40" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.8853 39C30.3787 39 38.8853 30.4934 38.8853 .. example .. fill="#C4C4C4"/>
</svg>`}
];
```

### Генерация environment
Ещё одна связка значений из манифеста и полей в рецепте. Генерируется на уровне проекта

В primary манифесте:
```yaml
project:
  # ...
  constant:
    # Путь, куда записать файл
    environmentPath: "{$BUILD_PATH}/environment.json"
  environment:
    - key: "backend"
      required: true
      # meta information
      name: "Backend link"
      description: "Сылка для бека"
      type: "string"
```

В рецепте:
```json
{
  // ...
  "environment": {
    "backend": "https://blah.com",
    // пробрасывание переменных, не указанных в манифесте, не гарантируется
    // "other": "123",
  }
}
```

На выходе, в `{$BUILD_PATH}/environment.json`, получаем:
```json
{
  "backend": "https://blah.com",
}
```


## Переменные сборки
см /builder/src/build/consts.rs

---
## Работа с yml-файлами

Внутри папки с каждым настраиваемым компонентом должен быть yml-файл, описывающий работу с ним.
Название файла определяется названием папки, в которой он лежит - cart1.m.yml, cart2.m.yml, cart3.m.yml и т.д.

## Переменные среды

**serve:**

`JWT_SECRET` - секрет jwt токена

**build:**

TODO

## Полезные сылки:

Разметка колонками и прочие вкусности и хелперы CSS - https://bulma.io/documentation/columns/
Documentation material - https://material.angular.io/components/categories
Генератор икон-сетов для мобильных устройств - https://www.favicon-generator.org/

## TODO:
1. Резолвинг переменных