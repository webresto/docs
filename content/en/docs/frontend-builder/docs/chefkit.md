---
title: "Chefkit - Project factory manager"
linkTitle: "Chefkit cli"
description: >
  Working with custom factory projects
---

# Chef Kit CLI

Chef Kit (project factory manager) is a tool for developers of custom projects. Its goal is to
reduce working with the factory when producing a custom project to regular work on a project. The
npm package installs the `chef` and `pjfm` commands, which run the native `chefkit` binary, so
`chefkit <command>` works the same when the binary is run directly.

- **`init`** takes the factory, builds a starter recipe and creates a project with all the necessary
  files.
- **`sync`** builds the recipe again and transfers new factory files into the project.

The developer, knowing the component settings, edits the recipe, and Chef Kit, as a project manager,
places the factory components into the right directories and modifies them. For example, you need
to change the color of a dish card: the developer changes it in `recipe.json`, runs `chef sync` —
the generated files are updated. The whole project, including the generated files and the recipe,
is stored in git.

Inside, Chef Kit uses the same builder as `builder build` (see [README](README.md)), with these
differences:

- the recipe may contain comments;
- `archive.tar.gz` is not created;
- the recipe target (`target`) is never built.

Unimplemented features and known issues are listed in [ideas.md](ideas.md#chefkit).

## Commands

```
chef init [arguments]                     create a project in an empty directory
chef sync [projectname] [--force] [--package] [--upgrage-factory]
                                          rebuild the recipe and update project files
chef help [init|sync]                     help
chef -V                                   npm package version
chef validate                             validate component manifests
```

## Requirements

- `git` in `PATH` (init adds the factory as a submodule, sync checks the commit and updates the
  factory);
- access to the factory repository (an ssh key for `git@...`);
- `bash` — if the factory manifests contain `bash` actions;
- Node.js and npm — for installation from npm and for `chef validate`.

## Typical workflow

```bash
mkdir my-project && cd my-project
chef init                             # project from the base_layouts factory
git add -A && git commit -m "init"

# edit recipe.json: colors, components, texts
git commit -am "recipe: new colors"
chef sync                             # factory files are updated according to the recipe
git status                            # see what changed
git commit -am "sync"

chef sync --upgrage-factory           # pull the latest factory (it gets into the next sync)
chef sync
```

`sync` overwrites your own edits to generated files. To keep a file untouched, add it to
`.factoryignore`.

## Installation

```bash
npm i -g @chef-kit/all            # Linux, macOS, Windows
npm i -g @chef-kit/linux-x86-64   # Linux x86-64 only
npm i -g @chef-kit/all@next       # build from the kit-next branch
```

The package installs the `chef` and `pjfm` commands (they are the same). The Node.js wrapper:

- `chef -V`, `chef --version` — npm package version;
- `chef validate` — validation of component manifests (see below);
- everything else is passed to the `chefkit` binary for the current platform.

## Project layout

```
my-project/                 # git repository of the custom project
├── .factoryrc              # Chef Kit settings
├── .factorylock            # list of project files, see sync
├── .factoryignore          # what sync does not overwrite
├── .gitignore              # Chef Kit appends .tmp_factory to it
├── recipe.json             # recipe
├── components/             # libraries-dir
│   └── base_layouts/       # factory repository, git submodule
├── .tmp_factory/cache/     # the recipe is built here before being copied into the project
└── ...                     # project files: generated and your own
```

### `.factoryrc`

JSON, comments are allowed.

```json
{
  "libraries-dir": "components/base_layouts/content",
  "recipe-filename": "recipe.json",
  "projects-dir": "projects"
}
```

| Key | Default | Meaning |
|---|---|---|
| `libraries-dir` | `components` | component library from which the recipe is built. The first directory of the path (`components`) is where the factory repositories are located |
| `recipe-filename` | `recipe.json` | recipe file name |
| `projects-dir` | empty | directory with projects; if set — multi-project mode |
| `is-multiproject` | `false` | enable multi-project mode explicitly |

Without `.factoryrc`, `chef sync` exits with code 2.

### `.factoryignore`

Each non-empty line, except those starting with `#`, is a **regular expression**. A build file whose
name matches one of them is not copied into the project by `sync`. Only the file name is checked,
without directories: `^one\.txt$` skips both `one.txt` and `extra/sub/one.txt`. A whole directory
cannot be excluded.

```
^package\.json$
^environment\.json$
```

`init` creates `.factoryignore` with the line `.gitignore`.

Your own files that are not in the build do not need to be added to `.factoryignore`: `sync` does
not touch them.

## `chef init`

Creates a project in an **empty** directory:

```bash
mkdir my-project && cd my-project
chef init --init-library-repo=git@git.hm:webresto/factory/base_layouts.git
```

| Argument | Variable | Default | Meaning |
|---|---|---|---|
| `--init-library-repo` | `LIBRARY_INIT_REPO` | `git@git.hm:webresto/factory/base_layouts.git` | factory repository |
| `--init-library-dirrectory` | `LIBRARY_INIT_DIR` | `components` | where to add the factory repository |
| `--init-library-project` | `LIBRARY_INIT_PROJECT` | see below | library project to start from |
| `--recipe-filename` | `recipe_filename` | `recipe.json` | recipe file name |
| `--is-multiproject` | `IS_MULTIPROJECT` | `0` | `1` — multi-project mode |
| `--projects-dir` | `PROJECTS_DIR` | `projects` | projects directory (multi-project mode) |
| `--projectname` | `PROJECTNAME` | - | project name; required with `--is-multiproject=1` |

What happens:

1. The directory must be empty, otherwise it exits with code 39.
2. `git init`, then `git submodule add <repo> <libraries-dir>/<repository name>`.
3. Choosing the library, the project and the starter recipe:
   - **`content/` structure** (the factory repository has a `content/` directory): library —
     `<libraries-dir>/<repo>/content`. Project — `--init-library-project`; without it —
     `base_layouts`, and if there is no such project and there is only one project — that one;
     otherwise an error with the list of names. Starter recipe — `content/<project dir>/init.json`;
     for `base_layouts` without its own `init.json`, `<repo>/init.json` is used.
   - **Old structure** (no `content/`): library — `<libraries-dir>`, recipe — `<repo>/init.json`.
4. The recipe is copied to `<recipe-filename>` (in multi-project mode —
   `<projects-dir>/<projectname>/<recipe-filename>`).
5. The recipe's `unit` must belong to the selected project, otherwise an error (code 2).
6. Build into `.tmp_factory/cache/` (multi-project mode — `.tmp_factory/cache/<projectname>/`).
7. `.factoryrc` is written (`libraries-dir`, `recipe-filename`, and `projects-dir` in multi-project
   mode).
8. `.factorylock` — list of build files.
9. The build is copied into the project (to the root or to `<projects-dir>/<projectname>`).
10. `.factoryignore` with the line `.gitignore`; `.tmp_factory` is appended to `.gitignore`.

A project or recipe selection error exits with code 2, a build error with code 255.

## `chef sync`

```bash
chef sync                         # project in the root
chef sync <projectname>           # multi-project mode (or env PROJECTNAME)
```

| Flag | What it does |
|---|---|
| `--force` | do not check that changes are committed |
| `--package` | ask about every dependency mismatch in `package.json` |
| `--upgrage-factory` | pull the latest commits of the factory repositories |

What happens:

1. `.factoryrc` is read; in multi-project mode `projectname` is required (otherwise code 2).
2. Without `--force`: `git status -uno --porcelain` must be empty (changes in tracked files are
   committed), otherwise code 17.
3. `.tmp_factory/cache/` is cleared and the recipe is built into it. A build error exits with code
   255, the project is not changed.
4. `.factorylock` is overwritten with the list of all files in the project directory except
   `node_modules`, `.git`, the first directory of `libraries-dir`, `.gitmodules`, `.factorylock`,
   `.factoryrc` and the recipe file.
5. `package.json`: the dependencies (`dependencies` and `devDependencies`) of the build are compared
   with the project. Without `--package`, only the dependencies missing from the project are printed.
   With `--package`, a `[y/n]` question is asked for every version mismatch and missing dependency,
   and the project's `package.json` is edited.
6. Factory repositories (all git repositories in the first directory of `libraries-dir`): commits
   from `origin` that are not present locally are printed. With `--upgrage-factory` —
   `git reset --hard` and `git pull`. The new commits get into the project on the **next** `sync`:
   the build in step 3 is already done.
7. Copying from `.tmp_factory/cache/` into the project: only new files and files with different
   content (by SHA-256); files matching `.factoryignore` are skipped.

Important:

- `package.json` is required both in the build and in the project, and both must contain
  `dependencies` and `devDependencies`. Otherwise `sync` fails (code 101).
- In step 7 the build's `package.json` is copied over the project's one if it differs and is not
  listed in `.factoryignore`; the answers in step 5 only make sense if it is in `.factoryignore`.
- Files that disappeared from the factory are **not deleted** from the project.
- In multi-project mode `sync` currently fails (code 101) — see [ideas.md](ideas.md#chefkit).

## Multi-project mode

A single custom project repository can hold several projects built from one factory. The mode is
enabled with `--is-multiproject=1` during `init` or with the `projects-dir` (`is-multiproject`) key
in `.factoryrc`.

```
my-repo/
├── .factoryrc                  # "projects-dir": "projects"
├── components/base_layouts/    # factory shared by all projects
├── .tmp_factory/cache/<name>/  # build cache of each project
└── projects/
    ├── shop/
    │   ├── recipe.json         # project recipe
    │   ├── .factorylock
    │   └── ...                 # project files
    └── landing/
        └── ...
```

```bash
chef init --is-multiproject=1 --projectname=shop
chef sync shop
```

> ⚠️ `chef sync <projectname>` in multi-project mode currently fails (code 101) — see
> [ideas.md](ideas.md#chefkit).

## `chef validate`

Validates all `*.m.yml` files (except `index*`) against the component schema:

```bash
chef validate                               # components directory in the current directory
COMPONENTS_PATH=content/base_layouts chef validate
```

The directory is `COMPONENTS_PATH`, otherwise `componentsPath` from `.factoryrc`, otherwise
`./components`. The schema is `./schema/component.m.json` if it exists, otherwise the copy from the
package. On errors — code 1.

A manifest whose first line is the comment `# invalid by design` is reported with a warning and not
checked against the schema: this is how deliberately invalid test fixtures are marked.

## Windows and Cygwin

`chefkit.exe` is a regular Windows program: Cygwin (or Git Bash) only gives it a terminal, `PATH`
and the current directory.

If you need a Cygwin program, build Chef Kit in Cygwin itself
([development.md](development.md#cygwin)): it has POSIX paths, Cygwin's bash, git and
tar, and the caveats below do not apply to it.

- **Paths.** Cygwin does not convert POSIX paths in arguments and environment variables for Windows
  programs (except `PATH`, `HOME`, `TMP`). The paths `/home/...` and `/cygdrive/c/...` in
  `LIBRARY_INIT_DIR`, `PROJECTS_DIR`, `COMPONENTS_PATH` and in `.factoryrc` do not work: use
  relative paths or a Windows path `"$(cygpath -m /home/user/components)"`.
- **bash actions** are run by the first `bash.exe` in `PATH` (Cygwin or Git Bash); WSL's
  `System32\bash.exe` is skipped. Paths in variables (`{$BUILD_PATH}` etc.) look like `C:/work/proj`.
- **Symlinks.** By default, `ln -s` in Cygwin creates links that Windows programs cannot see: a
  project symlink in the library will be skipped. You need real Windows symlinks: enable Developer
  Mode and `export CYGWIN=winsymlinks:nativestrict` before creating links and cloning.
- **File permissions.** Cygwin's `git` may see a permission change on files written by Chef Kit, and
  then the next `sync` requires a commit. Disable it: `git config core.fileMode false`.
- **git and ssh.** Chef Kit uses the first `git` in `PATH`. Cygwin's git takes keys from `~/.ssh` in
  the Cygwin home directory, Git for Windows — from `%USERPROFILE%\.ssh`: the key to the factory
  repository must be where your git looks for it.
- **Local library repository** (`--init-library-repo` is a directory, not a URL): specify it as a
  POSIX path (`/home/user/lib`): Chef Kit passes it to git as is, and Cygwin's git does not clone
  from a `C:/...` path (`hardlink different from source`).
