# Compilation guide for 64 bit Windows (using MinGW-w64)

This guide contains steps required to allow compilation of Cataclysm-DDA on Windows under MinGW.

Steps from current guide were tested on Windows 10 (64 bit) and MinGW-w64 (64 bit), but should work for other versions of Windows too.

## Prerequisites:

* Computer with 64 bit version of modern Windows operating system installed (Windows 10, Windows 8.1 or Windows 7);
* NTFS partition with ~10 Gb free space (~1 Gb for MinGW-w64 installation, ~3 Gb for repository and ~5 Gb for ccache);
* 64 bit version of MinGW-w64 (installer can be downloaded from [MinGW-64 homepage](http://www.mingw-w64.org/));

## Installation:

1. Go to [MinGW-w64 homepage](http://www.mingw-w64.org/) and download installer (e.g. [mingw-w64-install.exe](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/installer/mingw-w64-install.exe/download)).

2. Run downloaded file and install MinGW-w64. (Click `Next` button, specify settings, click `Next` button again, specify directory where MinGW-w64 will be installed (e.g. `C:\MinGW-w64`) and click `Next` button again,  wait until download is finished and click `Next` button again, then click `Finish` button).

**Note:** Following settings are recommended:

* `Version` - `8.1.0`;
* `Architecture` - `x86_64`;
* `Threads` - `posix`;
* `Exception` - `seh`;
* `Build Revision` - `0`.

3. After MinGW-w64 installation is complete run it either via `Run terminal` shortcut in `MinGW-W64` folder in Start menu or via `C:\MinGW-w64\mingw-w64.bat`.

## Confuguration:

1. Add following lines after `@echo off` into `mingw-w64.bat`:

```
cd "C:\Projects\Cataclysm-DDA"
set CCACHE_DIR=C:\Projects\Cataclysm-DDA\.ccache
```

## Cloning and compilation:

1. Clone Cataclysm-DDA repository with following command line:

**Note:** This will download whole CDDA repository. If you're just testing you should probably add `--depth=1`.

```bash
git clone https://github.com/CleverRaven/Cataclysm-DDA.git
cd Cataclysm-DDA
```

2. Compile with following command line:

```bash
mingw32-make CCACHE=1 RELEASE=1 SDL=1 TILES=1 SOUND=1 LOCALIZE=1 LANGUAGES=all LINTJSON=0 ASTYLE=0 RUNTESTS=0
```

**Note**: This will compile release version with Sound and Tiles support and all localization languages, skipping checks and tests and using ccache for faster build. You can use other switches too.

## Running:

1. Run from within MinGW-w64 with following command line:

```bash
./cataclysm-tiles
```

***

**Note:** If you want to run compiled executable from Explorer you will also need to update user or system `PATH` variable with path to MSYS2 runtime binaries (e.g. `C:\msys64\mingw64\bin`).
