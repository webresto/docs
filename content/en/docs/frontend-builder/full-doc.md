---
title: "Спецификация"
linkTitle: "Спецификация"
date: 2017-01-06
description: >
 Билдер - Программа, генерирующая код для построения одностраничных приложений из готовых компонентов.
---

# Factory chef

Chef, Билдер (factory-chef или кратко chef) - Программа генерирующая код для построения одностраничных приложений из готовых компонентов фабрики. Шеф написан на rust, покрыт тестами, и используется в продакшене для производства сайтов на Angular.

Шеф посавляется как пакет npm _(планируется сделать webassembly  и пакет cargo)_, эта программа использует yml файлы для описания манифестов компонентов, и json для рецепта. Программа работает асинхронно используя tokio и выводит log для каждой сборки. После запуска вы получите в определенной папке результат сборки для проекта по рецепту. 

> Первоначально была идея использовать различные репозитории фабрик, и между ними переиспользовать компоненты. Но Эта идея оказалась  слишком сложной для построения, но эта философия поддерживается досихпор. 
> **Поэтому библиотека компонентов может содержать несколько папок c фабриками.**


**[α]** - *(alpha)* этим значком помечен функцонал который находится в стадии альфа-версии
**[s]** - *(soon)* Планируется ввести в будущих версиях, функционал еще не реализован, использование не разрешено
**[d]** - *(deprecated)* Будет удалено

## Термины

**Рецепт** или (*конфиг сборки*) - Указания в виде JSON по которому генерируется финальный проект *(пример дефолтного конфига должен лежать в корне репозитория файл: **recipe.json**)*

**Фабрика** - Проект на любом языке программирования или просто наборы файлов,  которые адаптированы для использования данной программой (factory-chef)

 Из этого репозитория билдер строит фронтенд. Билдер имеет поддержку нескольких репозиториев. Тоесть в рецепте мы можем указать из какого репозитория будет собран фронтенд. 

Внутри библиотеки компонентов может содержатся папка проекта, она будет использована из того проекта лейоут(root) (unit layout)[#] которого мы взяли. Соответсвенно если мы берем лейоут из фабрики, значит нам надо чтобы в этом репозитории был обязательно `project` - это папка непосредственно с самим проектом, который формируется конструктором из библиотеки компонентов. В ней располагается  *корневой манифест* 

> ⚠️ Папка  обязательно должна называтся `project` и быть в корне библиотеки компонентов

Для поиска компонентов работает сканер компонентов начиная от папки (рекурсивно), так что можно иметь вложенную структуру или дерево, внури билдера они просто рассортируются по группам. 

**Библиотека компонентов** - Может содержать одну или несоколько фабрик
---


**[α]** В режиме http-сервера, билдер создает для каждого проекта такую уникальную папку, и в рецепе можно указать из какой библиотеки компонентов мы возмем лейоут а из какой будем брать компоненты, также в рецепте можно указать какой имеено коммит или тег взять для сборки фронтендов.
---


**Манифест** - Файл `index.m.yml`\`manifest.yml` **[s]** хранится в корне проекта, содержит технические константы, описания экшенов для Юнитов, для каждого компонента должен быть написан также свой файл манифеста. `$component_name$.m.yml` и находится в корне папки компонента. Посути манифест является типизацией состояний, и свойств компонента. Билдер будет читать этот файл для того чтобы построить структуру компонентов и их свойств которые ему доступны.

manifest.yml - **[s]** называть файлы не по имени компонета а статично для всех одинаково

> **[s]** Также билдер готовит `json-schema` по файлам манифестов

**Группа компонентов/Group** - Группа обьеденяет разные компоненты по их назначению, для каждого компонента в inventory указывается группа. Группа нужна чтобы обьеденять компоненты внутри фабрики по назначению. И потом их легко находить в библиотеке компонентов.

> Можно указать массив групп для инфентори, но не для компонента.  

> **[s]** - имя файла манифеста будет приведено к общему виду `manifest.yml`

Существует два типа манифестов
1. Манифест проекта (index.m.yml)
2. Манифест юнита
    1. Root -Layout- (type: root) - описание верстки с возможностью добавлять дочерние компоненты
    2. Component (type: component) - единица строения билдера, может содержать kit для того чтобы получать дополнительный функционал
    3. Icon pack (type: iconpack) - Набор иконок
    4. Kit (type: kit) - Набор компонентов

**Warning:** The `project.target` section is deprecated and no longer used; remove it from manifests.


### Юниты (units)

**Юнит** (unit) - Базовая строительная единица биллдера, описанная через файлы манифестов. Юниты бывают разных типов: *иконпаки, лейоуты, компоненты, наборы*

**Инвентори/inventory** - Любой компонент может содержать inventory, ключ который находится в свойстве инвентори это название папки в которую будет перенесен компонент

> Если вам нужно указать в какую папку доставлять компонент откройте задачу. Для этих целей планируется использовать настойку unit 

UNIT: **Root** (*Layout*) - Верстка основной страницы + проект в котором она находится. Выбор лейаута определяет то как будет работать фронтенд, т.к. копируется проект в котором он находится.
> <span style="background:red;color:white;border-radius:5px;padding:3px">🚧 deprecated</span> Будет вытеснен компонентом с inverntory, c возможностью рекурсивно вкладывть компоненты друг в друга (ограничено до 2 уровня). Для root компонента будет введен спецальный флаг который будет иметь аналогичную с layout логику

пример манифеста (todo:link)

---

UNIT: **Component**  -  Наполняют шаблон, компоненты могут переходить между шаблонами (т.е. между проектами). У компоненты может быть 5 настраиваемых свойств (цвета, шрифты, состояния, переменные, темы **[d]**).

*Состояния и переменные* - также `states` или `variables` , набор переменных которые могут быть заданы билдером во время сборки проекта в файл config.ts и/или config.json компонента, или шаблона. В процессе выполнения приложения будут использованы переключения логики, отображения, или поведения.

*цвета и cssVariables* - цвета могут быть назначены для каждого компонента отдельно или они будут наследовать значение от layout если будут в манифесте указаны через знак $ например `$primary-color`
 
**[α]** *Ассеты компонента* - папка `assets` с ресурсами которая располагается внутри компонента, после обработки билдером переносится по пути взятого из корневого манифеста.

_пример манифеста для компонента_

**[α]** Сам компонент может содержать инвентори, инвентори может должно содержать поле `default: %component_slug%`. В случае не обязательной установки должно подразумеватся что может прийти пустое значение, тогда будет выбран default Рекомендуется это покрывать тестом!

Компонент может содержать kit через inventory

флаг `root: true` включает режим root (layout) для компонета

> !!! В текущей реализации введен запрет на рекурсивную вложенность компонентов. Только 2 уровня поддерживатеся, root (layout) и component. **В инвентори компонента не может быть комопнента содержащего еще инвентори**

_пример манифеста для компонента поддерживающего kit_

---

UNIT: **Иконпак (iconpack)** - Набор заранее заготовленых векторных иконок. Преставляет из себя файл yml в котором перечислен набор иконок.

UNIT: **Набор (kit)** - **[α]** Набор компонентов может содержать любое колличество других компонентов, которые могут быть использованы для построение фронтенда. Набор может быть назначен в инвентори лейоута подобно любому компоненту. Cам по себе это обычный компонент который просто имеет произвольный набор инвентори. Также kit может быть применен для компонента через inventory. 

Чтобы загрузить компонент в `kit` в рецепте указывается чтото из нижеперечисленного: 
 - адрес компоннента `repo1/overlay1`  
 - имя пакета `npm:@webresto/enchanting-boom`
 - прямая ссылка на архив `http://example.com/component.tgz` 

> Также нужно указать что именно импортировать, это должно быт переданно значение `import: ["MyOverlayComponent1", "MyOverlayComponent2"]` в противном случае берется default из пакета что получится import kit_item1 from "@kit/components" .

Дефолтный пример шаблона для import kit file, тоесть если это kit для него будет создан такой файл по дефолту, значит его не нужно прописывать, если такой шаблон подходит

```
{{ for item in kit }}
  import { {{ item.component }} } from '{{ item.path }}';
{{ endfor }}

const kit = []
{{ for item in kit }}
  kit.push(new {{item.component}}({{ constant | json }}));
{{ endfor }}

export const kit;

```

## Шаблоны
 **[α]** для генерации кода предусмотрены шаблоны на движке TinyTemplate (cargo). Это простой и легкий движок шаблонов. С минимальным набором функций. В шаблон передается полный конфиг проекта, имя компонента, весь рецепт. И на основании этого можно построить то что нужно для  файла компонента.

Если вы создадите файл с расширением tmpl то шеф его обработает. пройдет рекурсивно по всем папкам относительно корня компонента и произведет "рендер" tmpl файлов, например вы имеете файл  `./index.js.tmpl` c контентом `console.log("{var.text}")`, в рецепте указать text = "Hello chef", то после обработки вы получите файл `./index.js` c контентом `console.log("Hello chef")`

> Для того чтобы шаблоны работали в компоненте вы должны включить их в настройках компонента `unit:hasTemplate: true`

Возможности шаблонов: 
> Распечатать значение - { myvalue }
> Условные операторы - {{ if foo }}Foo is true{{ else }}Foo is false{{ endif }}
> Циклы - {{ for value in row }}{value}{{ endfor }}

payload в шаблон:

```json

{
  component_manifest: {...} // Манифест текущего компонента
  component_config: {...} // Конфиг компонента (та часть рецепта которая относится непосредственно к компоненту)
  project_manifest: {...} // Манифест проекта
  recipe: {...} // Полностью весь рецепт который мы прощитываем
  resolved_variables: {...} // расчитаные занчение переменных относительно root компонента и рецепта,
  var: {...} // все что содержится в config.json
  style: {...} // все содержится в color.scss
  import: [...] // для kit будет передан массив imports
  dependency: [...] // Список зависимостей если они присутвуют
}

```


## Примеры
### Манифесты 
---

<details>
<summary>Схема манифеста проекта</summary>

```yml
project:
  version: 1 # Версия проекта (?)
  type: "angular" # Тип библиотеки для совместимости
  constant: # Константы и некоторые пути, необходимые для корректной работы
    assetsPath: "{$BUILD_PATH}/src/assets" # Путь, куда копировать файлы из ассетов
    iconsPath: "{$BUILD_PATH}/src/app/material/icons.ts" # Путь до файла, который будет содержать готовые иконки
    fontFamilyPath: "{$BUILD_PATH}/src/styles/vars/font-family.scss" # Путь до scss файла, который будет содеждать выбранные шрифты
    fontsPath: "{$BUILD_PATH}/src/assets/fonts" # Путь куда будет загружатся шрифт
    publicFontsPath: "/assets/fonts" # Путь который будет добавлен в font-family.css для того чтобы его загрузить по http при рендере страницы

```

</details>

<details>
<summary>Схема манифеста layout</summary>

```yml
unit:
  # Метаданные. смотри unit
component:
  constant:
    # смотри constant
  inventory:
    # Список дочерних компонентов, которые необходимы этой верстке
    cart:
      type: component # в зависимости это `kit` или `component`
      description: blah # Описание слота для фронтенда
      group: cart # У каждого компонента есть group
      default: cart1 # [α] Дефолтный default компонент. Если это поле не указано и не указано в конфиге будет установлен первый попавшийся  компонент
    overlay:
      type: kit 
      description: Набор свистелок
      group: # для `kit` тут может быть массив
        - promo
        - event-handler
        - popup
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
<summary>Схема манифеста компонента</summary>

```yml
unit:
  # смотри unit
component:
  hasKitSupport: true
  kit: 
    template: "template" # По умолчанию будет смотреть темплейт в корне с названием  kitTemplate.ejs
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
<summary>Схема манифеста  iconPack</summary>

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
  hasTemplate: true # компонент содержит шаблоны
  description: blah # Описание для фронта
  slug: header1 # Название компонента, совпадающее с папкой, в которой он находится
  group: "dishcard" # Группа компонента. @deprecated
  shareable: true
  componentPrefix: "dishcard.component" # Постфикс для копируемых файлов (например стилей)
```

**Actions**
**[α]** Действия, которые умеет выполнять билдер, действия могут быть запущены только локально в режиме build или chefkit, для http режима билдера действия будут вынесены в хуки. и настраиваются для всего сервера.

```yml

actions: # Список
  - run: "copy" # Копировать файлы
    src: "{$COMPONENT_PATH}" # Откуда
    dst: "{$BUILD_PATH}/src/app/components/dishcard" # Куда
    clean: true # Нужно ли удалять всё в папке назначения
  - run: "bash" # Выполнить произвольную shell команду
    cmd: "npm install" # Команда, которая выполнится в $BUILD_PATH

```

Подробные примеры и сценарии работы экшенов: `docs/actions.md`.



**Constant**

> **[α]**  `cssVariables` будет удален используйте `styles``
> **[α]** Существует возможность запустить макрос 
`!Accent($primary-color, 0.12)` для расчета цвета налету. Корректировка цвета выбирается в зависимости от яркости исходного цвета. Если цвет темный (яркость ниже 0.5), то его яркость увеличивается на указанный параметр. Если цвет светлый (яркость 0.5 и выше), то его яркость уменьшается на указанный параметр.


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
    - key: macros-color
      value: "!Accent($primary-color, 0.12)"
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

---


### Создание проекта
#### Структура 
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
В нем описывается основная информация по проекту и базовые действия подготовки:
```yml
project:
  version: 1
  type: "basic" # Тип проекта. Пока ни на что не влияет
  
  exhaustiveСonfigFile: true # создаст единый конфиг в формате `json` после сборки и положит его по пути exhaustiveСonfigFile, или создаст файл config.json в корне проекта.

  constant: # Различные пути, с которыми может взаимодействовать билдер. Описаны ниже
    assetsPath: "{$BUILD_PATH}/assets"
    iconsPath: "{$BUILD_PATH}/icons.ts"
    fontFamilyPath: "{$BUILD_PATH}/font-family.scss"
    exhaustiveСonfigFile: "{$BUILD_PATH}/cfg.json"
  init:
    - run: "copy"
      src: "{$ROOT_PATH}/project"
      dst: "{$BUILD_PATH}"
      clean: true
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


#### Запуск проекта

Чтобы запустить билдер, нам нужен рецепт - json файл, описывающий структуру генерируемого проекта.
В начале он может быть совсем простой:
```json
{ // config.json
  "unit": "wide", // Версия компонента
  "constant": {},
  "inventory": {}
}
```

#### Создание layout

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
Больше сложных примеры можно посмотреть в репозитории base_layouts.

#### Добавление component/kit

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
    type: component # также сдесь может быть указан `kit`
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

1. Билдер получает на вход конфиг для сборки, и дирректорию с компонентам.
2. Находит выбранный **шаблон** (**layout**), и загружает список inventory
3. Билдер копирует проект в котором находится нужный шаблон
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

_Также существует поддержка загрузки кастомного шрифта билдером для этого надо передать такой конфиг_
```json
"fonts": {
    "main": "url(https://cdn.webresto.dev/ttapf/reefwoff2) name(Reef) weights(400,700)",
},
```

2. Билдер сохраняет в выбранные шрифты в файл, указанный как fontFamilyPath в манифесте:
```scss
  $font-main: 'Roboto'; // Шрифт main был взят из default
  $font-secondary: 'Helvetica'; // Шрифт secondary был перезаписан в рецепте
```

_Если были переданы кастомные шрифты то будет создан соответсвующий `@font-face`_

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

**[α]** Будет переименовано в themes 
   
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
Ассеты можно также передавать в рецепте тремя разными способами: base64 строкой, ссылкой на внешний ресурс или указав локальный путь до файла/папки.
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
  },
  {
    "path": "{$ASSETS_PATH}/shared",
    "localPath": "{$ROOT_PATH}/assets/shared" // Локальный файл или папка, копируется рекурсивно
  }
  ],
// ...
```

`localPath` поддерживает переменные и может указывать на директорию — содержимое копируется рекурсивно в указанную папку `path`.

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

### Сборка и генерация Kit
Когда билдер находит inventory или component с поддержкой kit он будет обращатся с соответсвующему разделу в рецепте так как kit подразумевает некоторое колличество компонентов которые будут импортированы, то билдер их видит как массив

> !!! В случае возникновения ошибки билдер не будет остановлен и сборка продолжится просто пропутив этот элемент

#### Рецепт:
Если билдер имеет доступ к kit компоненту в библиотеке он загрузит его из библиотеки компонентов, произведет импорт согласно шаблону и разрешит зависимости из depenedency.json

```json

...
inventory; {
  overlay: [
    {
      unit: "repo1/overlay1", // также  может быть package:MyBestKitUnit, package:git:MyBestKitUnit#staging, package:file:./dir
      import: ["MyOverlayComponent1", "MyOverlayComponent2"]
      constant: { 
        states: {
          state1: true
        },
        styles: {
        },
        variables: {}
      }
    }
  ]
}
```

> !!! Любая прямая установки не из библиотеки (package:) будет добавлена как зависимость package.json

в результате мы получим такой файл импорта kit который попадет в корневую дирректорию инвентори для компонента, и будет иметь имя файла  import.kit.ts

```typescript
import { MyBestKitUnit } from 'MyBestKitUnit';
const kit = []
  kit.push(new MyBestKitUnit ({ 
    states: {
      state1: true
    },
    styles: {},
    variables: {}
    } 
  ));
export const kit;

```

Это позволяет в проекте по пути inventory запросить import.kit.ts и дальше включить в нужно место в компоненте.

### Разрешение зависимостей
Если билдер встречает файл dependency.json, билдер будет учитывать эти пакеты в финальный package.json, с учетом версии (всегда в приоритете более новая версия).

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
    - key: "gqlPath"
      default: "/graphql"
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
    "back": "https://blah.com",
    // пробрасывание переменных, не указанных в манифесте, не поддерживается
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
Документация material - https://material.angular.io/components/categories
Генератор икон-сетов для мобильных устройств - https://www.favicon-generator.org/
