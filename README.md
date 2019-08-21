# Nagios Plugins for Monitoring Remote Hosts over SSH

Tests to monitor hosts with only an SSH connection. No NRPE needed.

---

## Development

Development will primarily be in Perl, although we are open to other languages
due to the extremely simple interface for Nagios tests, or, as they are called
in Nagios parlance, “plugins.”

### Target Platform

The target platform is Linux, but these plugins can be reasonably run on
macOS, BSDs, and, with some effort, even on Windows.

However, they must be runnable on CentOS 7 systems as of this writing.
Compatibility with other platforms is a nice-to-have, but not a requirement.

Due to a dependency on `String::ShellQuote`, which quotes strings to avoid
interpretation by the target shell, we are currently theoretically limited to
the Bourne line of shells on the SSH target. In practice, this will not be a
problem, unless some really exotic strings and filenames are passed around.

### Shebang

Keeping the **Target Platform** section in mind, it makes sense to let the
environment dictate the right interpreter for plugins in interpreted
languages.

In simpler words, do this:
```perl
#!/usr/bin/env perl
```

instead of this:
```perl
#!/usr/bin/perl
```

### Code Style

As prescribed by the relevant standards for the language. PEP 8, `go fmt`,
etc.

If such a prescription is unavailable, or untenable, the following applies:

| Characteristic         | Prescription    |
|------------------------|-----------------|
| Indentation            | 4 spaces        |
| Line Width             | 78 characters   |
| Braces                 | KnR             |
| Newlines               | UNIX (LF, `\n`) |
| Last Character of File | Newline         |

### Libraries

Include library directories on the library path of plugins, preferably by
using code within the plugins, instead of relying on environment variables.

Such code must not rely on absolute paths, so as to keep the script runnable
from any directory. Rely on relative paths instead.

In simpler words, prefer this:
```perl
use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';
```

over this:
```perl
use lib '/../lib/perl5';
```

over this:
```bash
export PERL5LIB="/opt/monsh/lib/perl5:$PERL5LIB"
```

### Boilerplate

A typical Perl `package` will begin with the following:
```perl
package MonSH::Foo;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;
```

That `split` spell may look perversely Perlish, but it is well-tested, and
saves potential person-months of debugging efforts directed at the
“environment.” Assuming the “person” even knows that they have to fix the
“environment.”

Said spell also works with arbitrary depths of modules, so long as the
directory structure is what Perl expects. So, for example, it works fine for
`MonSH::Foo::Bar::Qux`, without modification.

A typical Perl script will begin with the following:
```perl
#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;
```

### Configuration

Config data is stored in JSON format due to the ubiquity of JSON parsers in
all languages.

Do not use a special-snowflake config format or write homebrew parsers.

---

## The Nagios Contract

Nagios executes the plugins, and expects the following:

### Return Code

| Code | State    |
|-----:|:---------|
|    0 | OK       |
|    1 | WARNING  |
|    2 | CRITICAL |
|    3 | UNKNOWN  |

### First Line on `STDOUT`

The line must contain the status, `OK`, `WARNING`, `CRITICAL`, or `UNKNOWN`,
followed by ` - `, followed by a brief description of the observations. The
whole line must not be longer than 80 characters.

Example “first lines”:
```
OK - Logs indicate no error.
WARNING - No logs recorded for 5 hours!
CRITICAL - No updates downloaded for 24 hours!
UNKNOWN - Unable to SSH into remote host. Has the IP changed?
```

### Execution Time

Must not exceed 60 seconds of execution time. Analogous to `command_timeout`
in `/etc/nagios/nrpe.cfg`.

### Forbidden Practices

There are other extensions to this simple contract, like performance data, and
miscellaneous information spread over multiple lines of output. However, we
will not be using these in this codebase.

As the basic contract is so simple, it shall not be wrapped into a library.
Use simple `say 'OK - ...'; exit 0;` style constructs instead of writing
“reusable” subroutines or entire packages to do this. It has been observed
that “reusable” components do not actually get reused for simple contracts,
creating a lot of useless “reusable” code scattered through the codebase.

---

## Directories

The code is organised into the following directories.

### `lib/`

Common code relied on by multiple plugins goes here, in language-specific
sub-directories, like `perl5/`, `python3/`, etc. Please read the **Forbidden
Practices** section before writing any Nagios-related libraries.

### `etc/`

Configuration files go here. Typical examples include an `ssh_config` with
remote host details, which can be parsed by the `Net::SSH::Perl` module.

### `plugins/`

Contains the executable plugins. All files here must have the execute bit set,
and must actually be executable.

No subdirectories are allowed here; not even language-specific subdirectories.

Run any file using `./filename.pl; echo $?`, or `./filename.py; echo $?`, etc.

Implementors please take note. The files should actually be runnable with
simple invocations like the above. No setup or environment required, beyond
installing required CPAN modules, or PyPI packages, etc.

### `commands/`

Contains executable Nagios commands, which are different from plugins in that
commands are free-form, and can perform any task, print anything, and return
anything. All files here must have the execute bit set, and must actually be
executable.

No subdirectories are allowed here; not even language-specific subdirectories.

The files may expect environment variables and command-line arguments, which
will be provided by Nagios in the normal course of events, so they are not
expected to be runnable with simple invocations, unlike plugins.

### `data/`

Contains files to be used for tests. Typical examples include a Bash script
that can be `scp`’d over to a host for execution, or an Apache config file
that can be deposited in the right location to check Apache’s behaviour.

This is not a place for temporary files. Use `/tmp` or other local mechanisms
for temporary files.

### `tools/`

Contains housekeeping tools, like a tool to fix file permissions, so Nagios
Core can actually read our config files and plugins.

---

## Contributors

If you are a new contributor, please add your name to the `CONTRIBUTORS` file
in the following format.
```
Name Surname (CPANHANDLE) <email@example.org>
```

You may leave one or more fields empty, but leave the placeholders intact.
Please note the leading spaces below.
```
Name Surname () <>
 (CPANHANDLE) <email@example.org>
 () <email@example.org>
```

---

## Corrections in this Document

If you feel the guidelines here are too restrictive, or permissive, or
outdated, feel free to raise a PR to append, remove, or amend them, but
wait for the PR to be merged to `master` while continuing to follow the
guidelines that are already on `master`.

Thank you.
