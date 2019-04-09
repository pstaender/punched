# Punchcard
## Minimal time tracking tool for cli

[![Build Status](https://img.shields.io/travis/pstaender/punched.svg?branch=v1.0.0&style=flat-square)](https://travis-ci.org/pstaender/punched)

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

`totalsum` calculates human readable spended time on project(s):

```sh
  $ punched totalsum punched_programming
  02:05:06
```

Use wildcard to sum many projects:

```sh
  $ punched totalsum 'punched*'
  12:11:38
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

To use `md` or `csv` as output format:

```sh
  $ punched all csv

    "project","status","last active on","total duration","hourly rate","earnings"
    "Website","stopped","2017-05-07 15:50:00","04:06:00","95.0 €","380.00 €"
    "Punchcard (programming)","stopped","2017-07-11 12:47:42","01:10:04","",""
```

You can use `all` with any other action as well, e.g. `punched all stop` to stop all running projects.

### Store projects files in a custom folder and sync them between computers

By default, PunchCard will store the data in `~/.punchcard/`. Define your custom destination with:

```sh
  export PUNCHCARD_DIR=~/Nextcloud/punchcard
```


### Tests

```sh
  $ bundle exec rspec
```
