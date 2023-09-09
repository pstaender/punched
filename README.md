# Punchcard
## Minimal time tracking tool for cli

![status](https://github.com/pstaender/punched/actions/workflows/specs.yml/badge.svg)

[![asciicast](https://asciinema.org/a/222572.svg)](https://asciinema.org/a/222572)

### Requirements

  * ruby 2.1+

### Install

```sh
  $ gem install punched
```

### Usage

#### Start and stop a Project

```sh
  $ punched toggle punchcard_programming
  'punchcard_programming' started (00:00:00 total)
```

To stop:

```sh
  $ punched toggle punchcard_programming
  'punchcard_programming' stopped (00:01:25 total)
```

To be more explicit, you can also use `start` and `stop` instead of `toggle`.

#### Wildcard

Save keystrokes by using wildcard. The first last active project, which matches the (case insensitive) pattern will be selected:

```sh
  $ punched toggle 'punched*'
```

#### Status

```sh
  $ punched status punched_programming

    punched_programming
    01:10:09
```

#### List details

```sh
  $ punched details punched_programming

    punched_programming (stopped)

    00:00:08	2017-05-07 08:16:06 - 2017-05-07 08:16:14
    00:04:35	2017-05-07 08:22:02 - 2017-05-07 08:26:37
    ...
    ========
    01:10:04	(total)
```

#### Filtering

You can filter your spend time with `startAt` and `endAt`:

```sh
  $ punched totalsum myproject --startAt=15.05.2020
  $ punched totalsum myproject --startAt=15.05.2020 --endAt=30.05.2020
  $ punched all plain --startAt=15.05.2020 --endAt=30.05.2020
```

#### Set Hourly Rate

```sh
  $ punched set punched_programming hourlyRate 250€
  {"hourlyRate":"250€"}
```

#### Sum spended time on project(s)

`total` returns the total spend time in seconds:

```sh
  $ punched total punched_programming
  13505
```

`totalsum` calculates human readable spended time on project(s) (wildcard is used by default):

```sh
  $ punched totalsum punched_programming
  02:05:06
```

Use `startAt` and/or `endAt` to set a time range:

```sh
  $ punched totalsum punched_programming --startAt=2020-05-01 --endAt=2020-05-03
  01:02:36
```

#### Help

List all available actions:

```sh
  $ punched help
    Usage: punched all|csv|details|remove|rename|set|start|status|stop|toggle|total 'Name of my project'
```

#### List all projects with total time

```sh
  $ punched all

    |========================================|=========|=====================|================|=============|==========|
    | project                                | status  |   last active on    | total duration | hourly rate | earnings |
    |========================================|=========|=====================|================|=============|==========|
    | website                                | stopped | 2017-05-07 15:50:00 |    00:04:40    | 95.0 €      | 380.00 € |
    |----------------------------------------|---------|---------------------|----------------|-------------|----------|
    | punchcard_programming                  | stopped | 2017-07-11 12:47:42 |    01:10:04    |             |          |
    |========================================|=========|=====================|================|=============|==========|

```

To use `plain`, `md` or `csv` as output format:

```sh
  $ punched all csv

    "project","status","last active on","total duration","hourly rate","earnings"
    "Website","stopped","2017-05-07 15:50:00","04:06:00","95.0 €","380.00 €"
    "Punchcard (programming)","stopped","2017-07-11 12:47:42","01:10:04","",""
```

You can use `all` with any other action as well, e.g. `punched all stop` to stop all running projects.

Here you can also filter your spend time with `startAt` and `endAt`, respectively.

### Store projects files in a custom folder and sync them between computers

By default, PunchCard will store the data in `~/.punchcard/`. Define your custom destination with:

```sh
  export PUNCHCARD_DIR=~/Nextcloud/punchcard
```

### Bash auto complete

It is possible to add an auto completion for punchcard to your bash (tested on zsh so far). Add the following to your `.zshrc` / `.bashrc`:

```bash
PUNCHCARD_EXEC_PATH=$(which punched)

punchcard_projects () {
  ls $PUNCHCARD_DIR
  return 0
}

[ -f $PUNCHCARD_EXEC_PATH ] && complete -F punchcard_projects $PUNCHCARD_EXEC_PATH
```

Ensure that the `$PUNCHCARD_DIR` environment variable is also set (see `Store projects files in a custom folder and sync them between computers`).

Now you get a list of your existing projects everytime hitting a tab-key while using `punched`.

In `rvm` the return value of `which punched` will be empty; use rvm to get the absolute path and / or set the path manually.

### Tests

```sh
  $ bundle exec rspec
```
