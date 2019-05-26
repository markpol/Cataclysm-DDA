# Compilation guide for 64 bit Windows (using CYGWIN)

This guide contains steps required to allow compilation of Cataclysm-DDA on Windows under CYGWIN.

Steps from current guide were tested on Windows 10 (64 bit) and CYGWIN (64 bit), but should work for other versions of Windows and also CYGWIN (32 bit) if you download 32 bit version of all files.

## Prerequisites:

* Computer with 64 bit version of modern Windows operating system installed (Windows 10, Windows 8.1 or Windows 7);
* NTFS partition with ~10 Gb free space (~2 Gb for CYGWIN installation, ~3 Gb for repository and ~5 Gb for ccache);
* 64 bit version of CYGWIN (installer can be downloaded from [CYGWIN homepage](https://cygwin.com/));

## Installation:

1. Go to [CYGWIN homepage](https://cygwin.com/) and download 64 bit installer (e.g. [setup-x86_64.exe](https://cygwin.com/setup-x86_64.exe).

2. Run downloaded file and install CYGWIN (click `Next` button, select instalation source (e.g. `Install from Internet`), click `Next` button, specify directory where CYGWIN 64 bit will be installed (e.g. `C:\cygwin64`), select whether to install for all users or just you, click `Next` button again, select local package directory (e.g. `C:\Distr\Cygwin`), click `Next` button, select Internet connection settings, click `Next` button again, choose a download site from the list of available download sites,  click `Next` button again).

3. After CYGWIN installation is complete select following packages and press `Next` button to download and install them:

* ;
* ;
* .

Install _autorebase 001007-1
Install alternatives 1.3.30c-10
Install astyle 2.06-1
Install base-cygwin 3.8-1
Install base-files 4.2-4
Install bash 4.4.12-3
Install binutils 2.29-1 (automatically added)
Install bzip2 1.0.6-3
Install ca-certificates 2.26-1
Install ccache 3.1.9-2
Install coreutils 8.26-2
Install crypto-policies 20190218-1
Install csih 0.9.11-1 (automatically added)
Install cygrunsrv 1.62-1 (automatically added)
Install cygutils 1.4.16-2
Install cygwin 3.0.6-1
Install cygwin-devel 3.0.6-1
Install dash 0.5.9.1-1
Install desktop-file-utils 0.23-1 (automatically added)
Install diffutils 3.5-2
Install dri-drivers 18.0.5-1 (automatically added)
Install editrights 1.03-1
Install file 5.32-1
Install findutils 4.6.0-1
Install gamin 0.1.10-15 (automatically added)
Install gawk 4.2.1-1
Install gcc-core 7.4.0-1 (automatically added)
Install gcc-g++ 7.4.0-1
Install getent 2.18.90-4
Install gettext 0.19.8.1-2
Install gettext-devel 0.19.8.1-2
Install git 2.17.0-1
Install grep 3.0-2
Install groff 1.22.4-1
Install gsettings-desktop-schemas 3.24.1-1 (automatically added)
Install gzip 1.8-1
Install hostname 3.13-1
Install info 6.6-1
Install ipc-utils 1.0-2
Install less 530-1
Install libFLAC8 1.3.2-1 (automatically added)
Install libGL1 18.0.5-1 (automatically added)
Install libSDL-devel 1.2.15-3 (automatically added)
Install libSDL1.2_0 1.2.15-3 (automatically added)
Install libSDL2-devel 2.0.7-1
Install libSDL2_2.0_0 2.0.7-1
Install libSDL2_image-devel 2.0.2-1
Install libSDL2_image2.0_0 2.0.2-1
Install libSDL2_mixer-devel 2.0.2-1
Install libSDL2_mixer2.0_0 2.0.2-1
Install libSDL2_ttf-devel 2.0.14-1
Install libSDL2_ttf2.0_0 2.0.14-1
Install libSDL_ttf-devel 2.0.11-1
Install libSDL_ttf2.0_0 2.0.11-1
Install libX11-xcb1 1.6.5-1 (automatically added)
Install libX11_6 1.6.5-1 (automatically added)
Install libXau6 1.0.8-1 (automatically added)
Install libXcursor1 1.1.15-1 (automatically added)
Install libXdmcp6 1.1.2-1 (automatically added)
Install libXext6 1.3.3-1 (automatically added)
Install libXfixes3 5.0.3-1 (automatically added)
Install libXi6 1.7.9-1 (automatically added)
Install libXinerama1 1.1.3-1 (automatically added)
Install libXrandr2 1.5.1-1 (automatically added)
Install libXrender1 0.9.9-1 (automatically added)
Install libXss1 1.2.2-1 (automatically added)
Install libargp 20110921-3
Install libasyncns0 0.8-1 (automatically added)
Install libatomic1 7.4.0-1 (automatically added)
Install libattr1 2.4.48-2
Install libblkid1 2.33.1-1
Install libbz2_1 1.0.6-3
Install libcharset1 1.14-3 (automatically added)
Install libcom_err2 1.44.5-1 (automatically added)
Install libcroco0.6_3 0.6.12-1 (automatically added)
Install libcrypt0 2.1-1 (automatically added)
Install libcurl4 7.59.0-1 (automatically added)
Install libdb5.3 5.3.28-2 (automatically added)
Install libdbus1_3 1.10.22-1 (automatically added)
Install libedit0 20130712-1 (automatically added)
Install libexpat1 2.2.6-1 (automatically added)
Install libfam0 0.1.10-15 (automatically added)
Install libfdisk1 2.33.1-1
Install libffi6 3.2.1-2
Install libfluidsynth1 1.1.10-1 (automatically added)
Install libfreetype-devel 2.8.1-1
Install libfreetype6 2.8.1-1
Install libgc1 8.0.4-1 (automatically added)
Install libgcc1 7.4.0-1
Install libgdbm4 1.12-1
Install libgettextpo-devel 0.19.8.1-2
Install libgettextpo0 0.19.8.1-2
Install libglapi0 18.0.5-1 (automatically added)
Install libglib2.0_0 2.54.3-1 (automatically added)
Install libgmp10 6.1.2-1
Install libgomp1 7.4.0-1 (automatically added)
Install libgsm1 1.0.17-1 (automatically added)
Install libgssapi_krb5_2 1.15.2-2 (automatically added)
Install libguile2.0_22 2.0.14-3 (automatically added)
Install libiconv 1.14-3
Install libiconv-devel 1.14-3 (automatically added)
Install libiconv2 1.14-3
Install libidn2_0 2.0.4-1 (automatically added)
Install libintl-devel 0.19.8.1-2 (automatically added)
Install libintl8 0.19.8.1-2
Install libisl15 0.16.1-1 (automatically added)
Install libjbig2 2.0-14 (automatically added)
Install libjpeg8 1.5.3-1 (automatically added)
Install libk5crypto3 1.15.2-2 (automatically added)
Install libkrb5_3 1.15.2-2 (automatically added)
Install libkrb5support0 1.15.2-2 (automatically added)
Install libllvm5.0 5.0.1-1 (automatically added)
Install libltdl7 2.4.6-6 (automatically added)
Install liblzma5 5.2.3-1
Install libmad-devel 0.15.1b-11
Install libmad0 0.15.1b-11
Install libmodplug1 0.8.9.0-2 (automatically added)
Install libmpc3 1.1.0-1 (automatically added)
Install libmpfr6 4.0.2-1
Install libmpg123_0 1.25.10-1 (automatically added)
Install libncursesw10 6.0-12.20171125
Install libnghttp2_14 1.37.0-1 (automatically added)
Install libogg0 1.3.1-1 (automatically added)
Install libopenldap2_4_2 2.4.42-1 (automatically added)
Install libp11-kit0 0.23.15-1
Install libpcre1 8.43-1
Install libpipeline1 1.4.0-1
Install libpkgconf3 1.6.0-1 (automatically added)
Install libpng-devel 1.6.34-1 (automatically added)
Install libpng16 1.6.34-1 (automatically added)
Install libpng16-devel 1.6.34-1 (automatically added)
Install libpopt-common 1.16-2
Install libpopt0 1.16-2
Install libpsl5 0.18.0-1 (automatically added)
Install libpulse-simple0 11.1-1 (automatically added)
Install libpulse0 11.1-1 (automatically added)
Install libquadmath0 7.4.0-1 (automatically added)
Install libreadline7 7.0.3-3
Install libsamplerate0 0.1.8-1 (automatically added)
Install libsasl2_3 2.1.26-11 (automatically added)
Install libsigsegv2 2.10-2
Install libsmartcols1 2.33.1-1
Install libsndfile1 1.0.28-2 (automatically added)
Install libsqlite3_0 3.27.2-1 (automatically added)
Install libssh2_1 1.7.0-1 (automatically added)
Install libssl1.0 1.0.2r-2 (automatically added)
Install libssl1.1 1.1.1b-1
Install libstdc++6 7.4.0-1
Install libtasn1_6 4.13-1
Install libtiff6 4.0.9-1 (automatically added)
Install libunistring2 0.9.10-1 (automatically added)
Install libuuid-devel 2.33.1-1 (automatically added)
Install libuuid1 2.33.1-1
Install libvorbis 1.3.6-1 (automatically added)
Install libvorbis0 1.3.6-1 (automatically added)
Install libvorbisenc2 1.3.6-1 (automatically added)
Install libvorbisfile3 1.3.6-1 (automatically added)
Install libwebp-devel 0.6.1-2
Install libwebp7 0.6.1-2
Install libwebpdecoder3 0.6.1-2 (automatically added)
Install libwebpdemux2 0.6.1-2 (automatically added)
Install libwebpmux3 0.6.1-2 (automatically added)
Install libwrap0 7.6-26 (automatically added)
Install libxcb-glx0 1.12-2 (automatically added)
Install libxcb1 1.12-2 (automatically added)
Install libxml2 2.9.9-2 (automatically added)
Install login 1.13-1
Install make 4.2.1-2
Install man-db 2.7.6.1-1
Install mingw64-x86_64-SDL2 2.0.7-1
Install mingw64-x86_64-SDL2_image 2.0.2-1
Install mingw64-x86_64-SDL2_mixer 2.0.2-1
Install mingw64-x86_64-SDL2_ttf 2.0.14-1
Install mingw64-x86_64-binutils 2.29.1.787c9873-1 (automatically added)
Install mingw64-x86_64-bzip2 1.0.6-4 (automatically added)
Install mingw64-x86_64-flac 1.3.2-1 (automatically added)
Install mingw64-x86_64-fluidsynth 1.1.10-1 (automatically added)
Install mingw64-x86_64-freetype2 2.8.1-1
Install mingw64-x86_64-gcc-core 7.4.0-1 (automatically added)
Install mingw64-x86_64-gcc-g++ 7.4.0-1
Install mingw64-x86_64-gettext 0.19.8.1-2
Install mingw64-x86_64-glib2.0 2.54.3-1 (automatically added)
Install mingw64-x86_64-gsm 1.0.17-1 (automatically added)
Install mingw64-x86_64-headers 6.0.0-1 (automatically added)
Install mingw64-x86_64-jbigkit 2.1-1 (automatically added)
Install mingw64-x86_64-libffi 3.2.1-2 (automatically added)
Install mingw64-x86_64-libgnurx 2.5-3 (automatically added)
Install mingw64-x86_64-libjpeg-turbo 1.5.3-1 (automatically added)
Install mingw64-x86_64-libmad 0.15.1b-1
Install mingw64-x86_64-libmodplug 0.8.9.0-1 (automatically added)
Install mingw64-x86_64-libogg 1.3.2-1 (automatically added)
Install mingw64-x86_64-libpng 1.6.34-1 (automatically added)
Install mingw64-x86_64-libsndfile 1.0.28-2 (automatically added)
Install mingw64-x86_64-libvorbis 1.3.6-1 (automatically added)
Install mingw64-x86_64-libwebp 0.6.1-1
Install mingw64-x86_64-mpg123 1.25.10-1 (automatically added)
Install mingw64-x86_64-ncurses 6.0-12.20171125
Install mingw64-x86_64-pcre 8.40-3 (automatically added)
Install mingw64-x86_64-readline 7.0.1-1 (automatically added)
Install mingw64-x86_64-runtime 6.0.0-1 (automatically added)
Install mingw64-x86_64-tiff 4.0.9-1 (automatically added)
Install mingw64-x86_64-win-iconv 0.0.6-2 (automatically added)
Install mingw64-x86_64-windows-default-manifest 6.4-1 (automatically added)
Install mingw64-x86_64-winpthreads 6.0.0-1 (automatically added)
Install mingw64-x86_64-xz 5.2.3-1 (automatically added)
Install mingw64-x86_64-zlib 1.2.11-1 (automatically added)
Install mintty 3.0.0-1
Install ncurses 6.0-12.20171125
Install openssh 7.9p1-1 (automatically added)
Install openssl 1.1.1b-1
Install p11-kit 0.23.15-1
Install p11-kit-trust 0.23.15-1
Install perl 5.26.3-1 (automatically added)
Install perl-Error 0.17027-1 (automatically added)
Install perl-Scalar-List-Utils 1.50-1 (automatically added)
Install perl-TermReadKey 2.38-1 (automatically added)
Install perl_autorebase 5.26.3-1 (automatically added)
Install perl_base 5.26.3-1 (automatically added)
Install pkg-config 1.6.0-1
Install pkgconf 1.6.0-1 (automatically added)
Install publicsuffix-list-dafsa 20180523-1 (automatically added)
Install python-pip-wheel 19.0.3-1 (automatically added)
Install python-setuptools-wheel 40.8.0-1 (automatically added)
Install python3 3.6.8-1 (automatically added)
Install python36 3.6.8-1 (automatically added)
Install rebase 4.4.4-1
Install rsync 3.1.2-1 (automatically added)
Install run 1.3.4-2
Install sed 4.4-1
Install shared-mime-info 1.8-1 (automatically added)
Install tar 1.29-1
Install terminfo 6.0-12.20171125
Install tzcode 2018i-1
Install tzdata 2018i-1
Install util-linux 2.33.1-1
Install vim-minimal 8.0.1567-1
Install w32api-headers 5.0.4-1 (automatically added)
Install w32api-runtime 5.0.4-1 (automatically added)
Install which 2.20-2
Install windows-default-manifest 6.4-1 (automatically added)
Install xz 5.2.3-1
Install zlib-devel 1.2.11-1 (automatically added)
Install zlib0 1.2.11-1

Check boxes to add shortcuts to Start Menu and/or Desktop, then press `Finish` button.

***

## Configuration:

1. Update the package database and core system packages with:

```bash
pacman -Syu
```

2. If asked close MSYS2 window and restart it from Start Menu or `C:\msys64\msys2_shell.cmd`.

3. Update remaining packages with:

```bash
pacman -Su
```

4. Install packages required for compilation with:

```bash
pacman -S git git-extras-git make mingw-w64-x86_64-{astyle,ccache,gcc,libmad,libwebp,ncurses,pkg-config,SDL2} mingw-w64-x86_64-SDL2_{image,mixer,ttf}
```

5. Update paths in system-wide profile file (e.g. `C:\msys64\etc\profile`) as following:

- find lines:

```
    MSYS2_PATH="/usr/local/bin:/usr/bin:/bin"
    MANPATH='/usr/local/man:/usr/share/man:/usr/man:/share/man'
    INFOPATH='/usr/local/info:/usr/share/info:/usr/info:/share/info'
```

and

```
    PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig:/lib/pkgconfig"
```

- and replace them with:

```
    MSYS2_PATH="/usr/local/bin:/usr/bin:/bin:/mingw64/bin"
    MANPATH='/usr/local/man:/usr/share/man:/usr/man:/share/man:/mingw64/share/man'
    INFOPATH='/usr/local/info:/usr/share/info:/usr/info:/share/info:/mingw64/share/man'
```

and

```
    PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig:/lib/pkgconfig:/mingw64/lib/pkgconfig:/mingw64/share/pkgconfig"
```

6. Restart MSYS2 to apply path changes.

## Cloning and compilation:

1. Clone Cataclysm-DDA repository with following command line:

**Note:** This will download whole CDDA repository. If you're just testing you should probably add `--depth=1`.

```bash
git clone https://github.com/CleverRaven/Cataclysm-DDA.git
cd Cataclysm-DDA
```

2. Compile with following command line:

```bash
make CCACHE=1 RELEASE=1 MSYS2=1 DYNAMIC_LINKING=1 SDL=1 TILES=1 SOUND=1 LOCALIZE=1 LANGUAGES=all LINTJSON=0 ASTYLE=0 RUNTESTS=0
```

**Note**: This will compile release version with Sound and Tiles support and all localization languages, skipping checks and tests and using ccache for faster build. You can use other switches, but `MSYS2=1`, `DYNAMIC_LINKING=1` and probably `RELEASE=1` are required to compile without issues.

## Running:

1. Run from within MSYS2 with following command line:

```bash
./cataclysm-tiles
```

**Note:** If you want to run compiled executable from Explorer you will also need to update user or system `PATH` variable with path to MSYS2 runtime binaries (e.g. `C:\msys64\mingw64\bin`).
