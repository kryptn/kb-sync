# KbSync

This tool is to easily keep my planck-ez's in sync.

Using a [custom github action][qmk_build] on a fork of QMK I'm able to automate the build of my customized keyboard firmware. This tool will download and extract the most recent build artifact and then call the flashing utility.

I've only tested this on osx and have no intention to broaden that.

## Requirements

- The [planck-ez](https://ergodox-ez.com/pages/planck) uses [wally-cli](https://github.com/zsa/wally) to flash the keyboard so `wally-cli` must be in your path.
- Your own [qmk_firmware](https://github.com/qmk/qmk_firmware) fork with your own build workflow defined, [here's mine.][qmk_build] It's important to remember the filename you use for the workflow.
- A github personal token, you can [create one here](https://github.com/settings/tokens). You only need the `public_repo` scope if you just fork the `qmk/qmk_firmware` repository.
- [Nim installed.](https://nim-lang.org/install.html)
- probably whatever openssl-dev you have
- depends on `unzip` being in installed too

## Setup

```bash
git clone git@github.com:kryptn/kb-sync.git
cd kb-sync
make install
```

This will install the binary to `/usr/local/bin/` so this must be in your path. You can edit this in the makefile or use the binary directly at `./bin/kb_sync`.

## Usage

```bash
cp template.env.sh env.sh
vi env.sh  # edit env.sh to match your token/user/repo/workflow name
source env.sh

kb_sync
```

[qmk_build]: https://github.com/kryptn/qmk_firmware/blob/master/.github/workflows/kryptn_build.yml