Profile Life
============

Github profile page hack to display a glider moving across my contribution
timeline.

Inspired by https://github.com/will/githubprofilecheat2

Usage
=====

    $ ./bin/pattern-to-commits.sh patterns/glider.cells 2012-04-15 | sh
    $ git push


WTF?
====

GitHub has a neat display of historical activity on each user's profile page.
This 53x7 grid shows the number of commits and other GItHub interactions that
the user performed on each day for the last year. This script will create
a commit history in a repository to "game" this graph to display a user
specified pattern.

Currently the patterns generated are fairly simple. A cell can either be
colored with the "more" color (dark green) or left alone. The script reads
a file in the form of a [plaintext Life files][] and outputs a list of shell
commands that will populate a git repository with 23 empty commits for the day
corresponding with a cell that is populated with an `O` character.

Notes
=====
On Apple OS X or other BSD boxen, you'll need to have a copy of GNU date
available to do the date formatting. You can tell the script to use
a different `date` binary by setting the `DATE_PGRM` environment variable.

On OS X this can be accomplished by installing the `coreutils` package:

    $ brew install coreutils
    $ DATE_PRGM=gdate ./bin/pattern-to-commits.sh ...

---
[plaintext Life files]: http://www.conwaylife.com/wiki/Plaintext
