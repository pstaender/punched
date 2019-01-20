# Punchcard
## Minimal time tracking tool for cli

[![Build Status](https://img.shields.io/travis/pstaender/punched.svg?branch=v1.0.0&style=flat-square)](https://travis-ci.org/pstaender/punched)

[![asciicast](https://asciinema.org/a/fCNgCmKJhHLtDsez5amQrgTnv.svg)](https://asciinema.org/a/fCNgCmKJhHLtDsez5amQrgTnv)

### Requirements

  * ruby 2.1+

### Install

```sh
  $ gem install punched
```

### Usage

#### Start Project

```sh
  $ punched start "Punchcard (programming)"
```

#### Wildcard

Save keystrokes by using wildcard. The first last active project, which matches the pattern (case insensitive) will be selected:

```sh
  $ punched start "Punch*"
```

#### Stop Project

```sh
  $ punched stop "Punch*"
```

#### Toggle

Toggle between start and stop:

```sh
  $ punched toggle "Punch*"
```

#### Status

```sh
  $ punched status "Punch*"

    Punchcard (programming)
    01:10:09
```

#### List details

```sh
  $ punched details "Punch*"

    Punchcard (programming) (stopped)

    00:00:08	2017-05-07 08:16:06 - 2017-05-07 08:16:14
    00:04:35	2017-05-07 08:22:02 - 2017-05-07 08:26:37
    ...
    ========
    01:10:04	(total)
```

#### Set Hourly Rate

```sh
  $ punched set "Punch*" hourlyRate 250€
```

#### Total time in seconds

```sh
  $ punched total "Punch*"
```

#### Rename and delete Project

```sh
  $ punched rename "Old Title" "New Title"
```

```sh
  $ punched remove "Punchcard (programming)"
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
    | Website                                | stopped | 2017-05-07 15:50:00 |    00:04:40    | 95.0 €      | 380.00 € |
    |----------------------------------------|---------|---------------------|----------------|-------------|----------|
    | Punchcard (programming)                | stopped | 2017-07-11 12:47:42 |    01:10:04    |             |          |
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
