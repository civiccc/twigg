Twigg collects statistics for a set of Git repositories. It assumes that
all the repositories are in one directory and up-to-date.

# twigg-stats (command-line tool)

A script to show how many commits each person has made in a given
timespan and in what repositories.

Usage:

    twigg-stats [--verbose|-v] repos dir> <number of days>

# twigg-app (web app)

The web app shows the same information as `twigg-stats`. To run it,
copy `config.yml.example` to `config.yml` and set `repositories_directory`
to the directory that contains all the repositories you want to analyze.

Usage:

    twigg-app

For development, you can use Shotgun to get auto-reloading behavior on every
request:

    bundle exec shotgun -o 0.0.0.0 config.ru

# Why "Twigg"

According to Merriam-Webster:

> twig (transitive verb)<br>
> <br>
> 1. notice, observe<br>
> 2. to understand the meaning of : comprehend

Originally, the gem was to be called "twig", but there is a pre-existing project
with that name, so we chose "twigg".

# Requirements

Twigg requires Ruby 1.9 or above.

Twigg is often used with, but does not require, Rubygems. If you wish to use
Rubygems with Twigg you may need to:

    export RUBYOPT=rubygems
