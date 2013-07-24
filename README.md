# Twigg

Twigg collects statistics for a set of Git repositories. It assumes that all the
repositories are in one directory and up-to-date.

## Commands

### `twigg stats` (command-line tool)

Shows how many commits each person has made in a given timespan and in what
repositories.

Usage:

    twigg stats [--verbose|-v] <repos dir> <number of days>

### `twigg app` (web app)

The web app shows the same information as `twigg stats`. To run it, configure
`~/.twiggrc` to specify the `repositories_directory` containing all the
repositories you want to analyze (`twigg init` can be used to produce the
`~/.twiggrc` file) and ensure the twigg-app gem is installed (`gem install
twigg-app`).

Usage:

    twigg app # assumes `~/.twiggrc` at default location
    TWIGGRC=config.yml twigg app # custom location for configuration file

### `twigg gerrit`

This subcommand clones a set of projects from a Gerrit instance, or updates an
existing set of clones.

    twigg gerrit [--verbose|-v] clone
    twigg gerrit [--verbose|-v] update

In order to use the `gerrit` subcommand the twigg-gerrit gem must be installed
(`gem install twigg-gerrit`).

### `twigg github`

This subcommand clones a set of projects from a GitHub, or updates an existing
set of clones.

    twigg github [--verbose|-v] clone
    twigg github [--verbose|-v] update

### `twigg init`

Emits a sample `.twiggrc` configuration file to standard out, which you can
redirect into a file; for example, to place the sample file at `~/.twiggrc`:

    twigg init > ~/.twiggrc

### Options common to all commands

All Twigg commands can take a `--verbose` or `-v` flag to increase their
verbosity, or a `--debug` or `-d` flag to show debugging information in the
event of an error.

All Twigg commands will attempt to read configuration from `~/.twiggrc`, if
present. The path to the configuration file can also be set via the `TWIGGRC`
variable in the environment.

## Development

Use Bundler when manually running or testing `twigg` subcommands from a local
clone of the Twigg Git repo:

    cd $(git rev-parse --show-cdup)/twigg
    bundle exec bin/twigg stats <repos dir> <number of days>
    bundle exec bin/twigg app
    TWIGGRC=custom bundle exec bin/twigg app # custom config location

For the web app, you can use Shotgun to get auto-reloading behavior on every
request:

    cd $(git rev-parse --show-cdup)/twigg-app
    bundle exec shotgun -o 0.0.0.0 config.ru # with default config at ~/.twiggrc
    TWIGGRC=custom bundle exec shotgun -p 0.0.0.0 config.ru # with custom config

To interact with Twigg in a REPL:

    cd $(git rev-parse --show-cdup)/twigg
    TWIGGRC=custom bundle exec irb -r twigg

## Why "Twigg"

According to Merriam-Webster:

> twig (transitive verb)<br>
> <br>
> 1. notice, observe<br>
> 2. to understand the meaning of : comprehend

Originally, the gem was to be called "twig", but there is a pre-existing project
with that name, so we chose "twigg".

## Requirements

Twigg requires Ruby 2.0 or above.
