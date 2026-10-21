# Contributing

Bug reports, new tool support and skill examples are welcome.

## Setup

No dependencies beyond a POSIX shell. Run the tests with:

```sh
sh tests/run.sh
```

CI also runs [ShellCheck](https://www.shellcheck.net/) on `install.sh` and `tests/run.sh`.

## Pull requests

- Keep `install.sh` POSIX `sh`: no bashisms, it must work on macOS and Linux.
- Add a case to `tests/run.sh` for every behaviour change. Tests run against a throwaway `$HOME`, never your real one.
- Skills in `skills/` are examples. Keep them generic: no personal names, paths or company details.
- One change per PR, with a short description of what and why.

## Adding support for a tool

See [docs/tools.md](docs/tools.md#adding-a-tool).
