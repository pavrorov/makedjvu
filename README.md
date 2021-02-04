# `makedjvu` — A simple Makefile script to produce DjVu book from a set of page images

The script were tested with [ScanTailor
Advanced](https://github.com/4lex4/scantailor-advanced) output, but
will probably work with any other bilevel and mixed output too.

**Для описания на русском языке обратитесь к [README.rus.md](https://github.com/pavrorov/makedjvu/blob/main/README.rus.md).**

## Installation and requirements

Just download the `Makefile` and place it near the `out/` directory
containing the ScanTailor output images:

```
$ cd ~/MyLibrary/MyNewBook
$ ls
out/ MyNewBook.ScanTailor
$ wget https://github.com/pavrorov/makedjvu/blob/main/Makefile
```

You can also clone this repo and copy `Makefile` to the book folder:

```
$ git clone https://github.com/pavrorov/makedjvu.git
$ cd makedjvu
$ cp Makefile ~/MyLibrary/MyNewBook
$ cd ~/MyLibrary/MyNewBook
```

### Requirements

In order to work, the script needs the following software to be
installed:

* GNU Coreutils (https://www.gnu.org/software/coreutils/coreutils.html).
* GNU Make (https://www.gnu.org/software/make/).
* ImageMagick (https://imagemagick.org/index.php).
* Utils from the DjVuLibre project (http://djvu.sourceforge.net/).

Having that software installed, the following commands should be
available on the system: `make`, `tr`, `cat`, `sed`, `identify`,
`convert`, `cjb2`, `c44`, `djvumake`, `djvuextract`, `djvm`.


## Usage

### Basic usage

To produce the book DjVu file using the default options, just
enter:

```
make
```

However, before stating the process it's better to overview it. `make
info` will show you the brief description of what and how be produced:

```
$ make info
Book name: MyNewBook.djvu
Mixed pages: out/00-front.tif out/page-0002_1L.tif out/zz-back.tif
Cover pages: out/00-front.tif out/zz-back.tif
C44 options: (default)
CJB2 options: -lossy -clean
Mask threshold: 1%
Cover dpi: 100
Workdir: djvudir
```

First of all, the book DjVu file is named after the name of the
folder the `Makefile` resides. Please note, however, that any spaces in
the filename are substituted by `_` in order to make the filename
compatible with `make`.

Below the book filename there are lists of mixed (i.e. with
illustrations) and cover pages. The cover pages, if any, are assumed
to be the first and the last pages in `out/` and only if they are
color images. Bitonal covers are processed as any other pages. 

After the list of special pages the command prints image processing
parameters. For the set of `c44` options see `c44(1)` manual page, and
for `cjb2` options, please, refer to the `cjb2(1)`. The mask threshold
value is the number used to extract the foreground layer from the
mixed pages.

Please note, that the current version of the `Makefile` _doesn't
support ScanTailor's "split output" mode_ for mixed pages. Instead of
that it uses the threshold filter to split the image of a mixed page
onto foreground and background parts. The default threshold value of
`%1` for white seems to be enough because ScanTailor is known to make
foreground parts completely black.

The next notable parameter is the DPI for cover pages. While the other
(including the mixed ones) pages of the book are processed as are, the
cover pages are _downsampled_ by default. Why? Because from my point
of view it isn't good to make the resulting DjVu file 3-5 times
bigger than it could be just to have the covers included.

The last info line is the name of the working directory that is used
to keep intermediate files.


### Advanced usage

All the above and some additional parameters can be overridden on the
command line. For instance, run:

```
make CJB2_OPTS="-losslevel 0"
```

to keep all bitonal material identical to TIFF images.

Another example: overriding the page directory and file suffixes:

```
make PAGESUF=.png PAGEDIR=pngdir
```

By the above command the script will look for PNG image files in the
`pngdir/` directory.

The complete list of currently supported options:

Option  | Comment                            | Default value
------- | ---------------------------------- | -------------
`PAGEDIR`  | Page image directory.                  | `out`
`PAGESUF`  | Image file suffix (including the dot). | `.tif`
`C44`      | Name (path) of `c44` command.          | `c44`
`CJB2`     | Name (path) of `cjb2` command.         | `cjb2`
`CONVERT`  | Name (path) of `convert` command.      | `convert`
`IDENTIFY` | Name (path) of `identify` command.     | `identify`
`DJVUMAKE` | Name (path) of `djvumake` command.     | `djvumake`
`DJVUEXTRACT` | Name (path) of `djvuextract` command. | `djvuextract`
`DJVM`     | Name (path) of `djvm` command.         | `djvm`
`C44_OPTS` | Options for `c44` command.             | _(no options)_
`CJB2_OPTS` | Options for `cjb2` command.           | `-lossy -clean`
`THRESHOLD` | White threshold value for mixed page separation. | 1%
`COVER_DPI` | DPI to downsample cover images to.    | 100
`NAME`      | Book base name.                       | After the name of the current folder with spaces substituted by `_`.
`FILENAME`  | Book file name.                        | `NAME` + `.djvu`
`WORKDIR`   | Name of the directory for intermediate files. | `djvudir`


# License

`makedjvu` — produce DjVu book from a set of page images.

Copyright (C) 2021  Pavel Avrorov.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
