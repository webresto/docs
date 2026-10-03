---
title: "Chefkit - Project factory manager"
linkTitle: "Chefkit cli"
description: >
  Работа с кастомными проектами фабрики
---

# chefkit

chefkit (project factory manager) - инструмент разработчика кастомного проекта. Его задача -
свести работу с фабрикой при производстве кастома к обычной работе с проектом.

- **`init`** берет фабрику, собирает стартовый рецепт и создает проект со всеми нужными файлами.
- **`sync`** собирает рецепт заново и переносит новые файлы фабрики в проект.

Разработчик, зная настройки компонентов, правит рецепт, а chefkit как менеджер проекта раскладывает
компоненты фабрики по нужным папкам и модифицирует их. Например, нужно поменять цвет карточки
блюда: разработчик меняет его в `recipe.json`, запускает `chefkit sync` - сгенерированные файлы
обновились. Весь проект, включая сгенерированные файлы и рецепт, хранится в git.

Внутри chefkit тот же билдер, что и `builder build` (см. [README](README.md)), с отличиями:

- рецепт может содержать комментарии;
- `archive.tar.gz` не создается;
- таргет рецепта (`target`) не собирается никогда.

Нереализованные возможности и известные проблемы - в [ideas.md](ideas.md#chefkit).

## Команды

```
chefkit init [аргументы]                  создать проект в пустой папке
chefkit sync [projectname] [--force] [--package] [--upgrage-factory]
                                          пересобрать рецепт и обновить файлы проекта
chefkit help [init|sync]                  справка
chef -V                                   версия npm-пакета
chef validate                             проверить манифесты компонентов
```

## Требования

- `git` в `PATH` (init добавляет фабрику подмодулем, sync проверяет коммит и обновляет фабрику);
- доступ к репозиторию фабрики (ssh-ключ для `git@...`);
- `bash` - если в манифестах фабрики есть экшены `bash`;
- Node.js и npm - для установки из npm и для `chef validate`.

## Типичная работа

```bash
mkdir my-project && cd my-project
chefkit init                          # проект из фабрики base_layouts
git add -A && git commit -m "init"

# правим recipe.json: цвета, компоненты, тексты
git commit -am "recipe: new colors"
chefkit sync                          # файлы фабрики обновились по рецепту
git status                            # смотрим, что поменялось
git commit -am "sync"

chefkit sync --upgrage-factory        # подтянуть свежую фабрику (попадет в следующий sync)
chefkit sync
```

Свои правки сгенерированных файлов `sync` перезапишет. Чтобы файл не трогался, добавьте его в
`.factoryignore`.

## Установка

```bash
npm i -g @chef-kit/all            # Linux, macOS, Windows
npm i -g @chef-kit/linux-x86-64   # только Linux x86-64
npm i -g @chef-kit/all@next       # сборка из ветки kit-next
```

Пакет ставит команды `chef` и `pjfm` (это одно и то же). Обертка на Node.js:

- `chef -V`, `chef --version` - версия npm-пакета;
- `chef validate` - проверка манифестов компонентов (см. ниже);
- все остальное передается бинарю `chefkit` для текущей платформы.

## Как устроен проект

```
my-project/                 # git-репозиторий кастома
├── .factoryrc              # настройки chefkit
├── .factorylock            # список файлов проекта, см. sync
├── .factoryignore          # что sync не перезаписывает
├── .gitignore              # chefkit дописывает в него .tmp_factory
├── recipe.json             # рецепт
├── components/             # libraries-dir
│   └── base_layouts/       # репозиторий фабрики, git submodule
├── .tmp_factory/cache/     # сюда собирается рецепт перед копированием в проект
└── ...                     # файлы проекта: сгенерированные и свои
```

### `.factoryrc`

JSON, комментарии допускаются.

```json
{
  "libraries-dir": "components/base_layouts/content",
  "recipe-filename": "recipe.json",
  "projects-dir": "projects"
}
```

| Ключ | По умолчанию | Что значит |
|---|---|---|
| `libraries-dir` | `components` | библиотека компонентов, по которой собирается рецепт. Первая папка пути (`components`) - место, где лежат репозитории фабрики |
| `recipe-filename` | `recipe.json` | имя файла рецепта |
| `projects-dir` | пусто | папка с проектами; если задана - мультипроектный режим |
| `is-multiproject` | `false` | включить мультипроектный режим явно |

Без `.factoryrc` `chefkit sync` выходит с кодом 2.

### `.factoryignore`

Каждая непустая строка, кроме начинающихся с `#`, - **регулярное выражение**. Файл сборки, имя
которого подходит под одно из них, `sync` не копирует в проект. Проверяется только имя файла, без
папок: `^one\.txt$` пропустит и `one.txt`, и `extra/sub/one.txt`. Папку целиком исключить нельзя.

```
^package\.json$
^environment\.json$
```

`init` создает `.factoryignore` со строкой `.gitignore`.

Свои файлы, которых нет в сборке, в `.factoryignore` добавлять не нужно: `sync` их не трогает.

## `chefkit init`

Создает проект в **пустой** папке:

```bash
mkdir my-project && cd my-project
chefkit init --init-library-repo=git@git.hm:webresto/factory/base_layouts.git
```

| Аргумент | Переменная | По умолчанию | Что значит |
|---|---|---|---|
| `--init-library-repo` | `LIBRARY_INIT_REPO` | `git@git.hm:webresto/factory/base_layouts.git` | репозиторий фабрики |
| `--init-library-dirrectory` | `LIBRARY_INIT_DIR` | `components` | куда добавить репозиторий фабрики |
| `--init-library-project` | `LIBRARY_INIT_PROJECT` | см. ниже | проект библиотеки, с которого начать |
| `--recipe-filename` | `recipe_filename` | `recipe.json` | имя файла рецепта |
| `--is-multiproject` | `IS_MULTIPROJECT` | `0` | `1` - мультипроектный режим |
| `--projects-dir` | `PROJECTS_DIR` | `projects` | папка проектов (мультипроектный режим) |
| `--projectname` | `PROJECTNAME` | - | имя проекта; обязательно при `--is-multiproject=1` |

Что происходит:

1. Папка должна быть пустой, иначе выход с кодом 39.
2. `git init`, затем `git submodule add <repo> <libraries-dir>/<имя репозитория>`.
3. Выбор библиотеки, проекта и стартового рецепта:
   - **Раскладка `content/`** (в репозитории фабрики есть папка `content/`): библиотека -
     `<libraries-dir>/<repo>/content`. Проект - `--init-library-project`; без него - `base_layouts`,
     а если его нет и проект один - он; иначе ошибка со списком имен. Стартовый рецепт -
     `content/<папка проекта>/init.json`; для `base_layouts` без своего `init.json` берется
     `<repo>/init.json`.
   - **Старая раскладка** (нет `content/`): библиотека - `<libraries-dir>`, рецепт - `<repo>/init.json`.
4. Рецепт копируется в `<recipe-filename>` (в мультипроектном режиме -
   `<projects-dir>/<projectname>/<recipe-filename>`).
5. `unit` рецепта должен принадлежать выбранному проекту, иначе ошибка (код 2).
6. Сборка в `.tmp_factory/cache/` (мультипроектный режим - `.tmp_factory/cache/<projectname>/`).
7. Запись `.factoryrc` (`libraries-dir`, `recipe-filename`, в мультипроектном режиме `projects-dir`).
8. `.factorylock` - список файлов сборки.
9. Копирование сборки в проект (в корень или `<projects-dir>/<projectname>`).
10. `.factoryignore` со строкой `.gitignore`; в `.gitignore` дописывается `.tmp_factory`.

Ошибка выбора проекта или рецепта - код 2, ошибка сборки - код 255.

## `chefkit sync`

```bash
chefkit sync                      # проект в корне
chefkit sync <projectname>        # мультипроектный режим (или env PROJECTNAME)
```

| Флаг | Что делает |
|---|---|
| `--force` | не проверять, что изменения закоммичены |
| `--package` | спросить про каждое расхождение зависимостей в `package.json` |
| `--upgrage-factory` | подтянуть свежие коммиты репозиториев фабрики |

Что происходит:

1. Чтение `.factoryrc`; в мультипроектном режиме нужен `projectname` (иначе код 2).
2. Без `--force`: `git status -uno --porcelain` должен быть пуст (изменения в отслеживаемых файлах
   закоммичены), иначе код 17.
3. Очистка `.tmp_factory/cache/` и сборка рецепта туда. Ошибка сборки - код 255, проект не
   меняется.
4. `.factorylock` перезаписывается списком всех файлов папки проекта, кроме `node_modules`, `.git`,
   первой папки `libraries-dir`, `.gitmodules`, `.factorylock`, `.factoryrc` и файла рецепта.
5. `package.json`: зависимости (`dependencies` и `devDependencies`) сборки сравниваются с проектом.
   Без `--package` печатаются только зависимости, которых нет в проекте. С `--package` по каждому
   расхождению версии и отсутствующей зависимости задается вопрос `[y/n]`, и `package.json`
   проекта правится.
6. Репозитории фабрики (все git-репозитории в первой папке `libraries-dir`): печатаются коммиты из
   `origin`, которых нет локально. С `--upgrage-factory` - `git reset --hard` и `git pull`. Новые
   коммиты попадут в проект при **следующем** `sync`: сборка на шаге 3 уже сделана.
7. Копирование из `.tmp_factory/cache/` в проект: только новые файлы и файлы с другим содержимым
   (по SHA-256); файлы, подходящие под `.factoryignore`, пропускаются.

Важно:

- `package.json` и в сборке, и в проекте обязателен, и в обоих должны быть `dependencies` и
  `devDependencies`. Иначе `sync` падает (код 101).
- `package.json` сборки на шаге 7 копируется поверх проектного, если отличается и не указан в
  `.factoryignore`; ответы на шаге 5 имеют смысл, только если он в `.factoryignore`.
- Файлы, которые пропали из фабрики, из проекта **не удаляются**.
- В мультипроектном режиме `sync` сейчас падает (код 101) - см. [ideas.md](ideas.md#chefkit).

## Мультипроектный режим

Один репозиторий кастома может держать несколько проектов, собранных из одной фабрики. Режим
включается `--is-multiproject=1` при `init` или ключом `projects-dir` (`is-multiproject`) в
`.factoryrc`.

```
my-repo/
├── .factoryrc                  # "projects-dir": "projects"
├── components/base_layouts/    # фабрика, общая для всех проектов
├── .tmp_factory/cache/<имя>/   # кеш сборки каждого проекта
└── projects/
    ├── shop/
    │   ├── recipe.json         # рецепт проекта
    │   ├── .factorylock
    │   └── ...                 # файлы проекта
    └── landing/
        └── ...
```

```bash
chefkit init --is-multiproject=1 --projectname=shop
chefkit sync shop
```

> ⚠️ `chefkit sync <projectname>` в мультипроектном режиме сейчас падает (код 101) - см.
> [ideas.md](ideas.md#chefkit).

## `chef validate`

Проверяет все `*.m.yml` (кроме `index*`) схемой компонента:

```bash
chef validate                               # папка components в текущем каталоге
COMPONENTS_PATH=content/base_layouts chef validate
```

Папка - `COMPONENTS_PATH`, иначе `componentsPath` из `.factoryrc`, иначе `./components`. Схема -
`./schema/component.m.json`, если есть, иначе копия из пакета. При ошибках - код 1.

## Windows и Cygwin

`chefkit.exe` - обычная Windows-программа: Cygwin (или Git Bash) дает ей только терминал, `PATH` и
текущую папку.

Нужна программа Cygwin - соберите chefkit в самом Cygwin ([development.md](development.md#cygwin)):
у нее POSIX-пути, Cygwin-овские bash, git и tar, и оговорки ниже ее не касаются.

- **Пути.** Cygwin не переводит POSIX-пути в аргументах и переменных окружения для
  Windows-программ (кроме `PATH`, `HOME`, `TMP`). Пути `/home/...` и `/cygdrive/c/...` в
  `LIBRARY_INIT_DIR`, `PROJECTS_DIR`, `COMPONENTS_PATH` и в `.factoryrc` не работают: указывайте
  относительные пути или Windows-путь `"$(cygpath -m /home/user/components)"`.
- **bash-экшены** запускает первый `bash.exe` из `PATH` (Cygwin или Git Bash), WSL-овский
  `System32\bash.exe` пропускается. Пути в переменных (`{$BUILD_PATH}` и др.) - вида `C:/work/proj`.
- **Симлинки.** `ln -s` в Cygwin по умолчанию создает ссылки, которые Windows-программы не видят:
  проект-симлинк в библиотеке будет пропущен. Нужны настоящие симлинки Windows: включите Developer
  Mode и `export CYGWIN=winsymlinks:nativestrict` до создания ссылок и клонирования.
- **Права файлов.** Cygwin-овский `git` может видеть у файлов, записанных chefkit, смену прав, и
  тогда следующий `sync` требует коммит. Отключите: `git config core.fileMode false`.
- **git и ssh.** chefkit берет первый `git` из `PATH`. Cygwin-овский git берет ключи из `~/.ssh`
  домашней папки Cygwin, Git for Windows - из `%USERPROFILE%\.ssh`: ключ к репозиторию фабрики
  должен лежать там, где его ищет ваш git.
- **Локальный репозиторий библиотеки** (`--init-library-repo` - папка, а не URL) указывайте
  POSIX-путем (`/home/user/lib`): chefkit передает его git как есть, а Cygwin-овский git по пути
  `C:/...` не клонирует (`hardlink different from source`).
