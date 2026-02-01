
## chronometre: Simple Stopwatch Class

[![CI](https://github.com/eddelbuettel/chronometre-r/actions/workflows/ci.yaml/badge.svg)](https://github.com/eddelbuettel/chronometre-r/actions/workflows/ci.yaml)
[![License](https://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](https://www.r-project.org/Licenses/GPL-2)
[![CRAN](https://www.r-pkg.org/badges/version/chronometre)](https://cran.r-project.org/package=chronometre)
[![r-universe](https://eddelbuettel.r-universe.dev/badges/chronometre)](https://eddelbuettel.r-universe.dev/chronometre)
[![Dependencies](https://tinyverse.netlify.app/badge/chronometre)](https://cran.r-project.org/package=chronometre)
[![Downloads](https://cranlogs.r-pkg.org/badges/chronometre?color=brightgreen)](https://www.r-pkg.org:443/pkg/chronometre)
[![Last Commit](https://img.shields.io/github/last-commit/eddelbuettel/chronometre-r)](https://github.com/eddelbuettel/chronometre-r)
[![pypi](https://img.shields.io/pypi/v/chronometre?color=3776ab)](https://pypi.org/project/chronometre/)


### Motivation

Interacting with Python code from R has become very convenient via the [reticulate][reticulate]
package which also takes care of most standard data types used by R users.  On top of that,
[arrow][arrow] facilitates exchange of vectors and especially data.frame (or in its parlance
RecordBatch) objects. Using [nanoarrow][nanoarrow] to do so takes the (considerable) pain of
building with arrow away.

But sometimes we want bespoke custom objects from a specific library. R does well with external
pointer objects, so a recent question in the [Rcpp][rcpp] context was: how do we do this with
Python?

This repository has one answer and working demonstration. It uses a very small but clever class: a
'stopwatch' implementation taken (with loving appreciation and a nod) from the lovely
[spdlog][spdlog] library, and specifically the already simplified version in
[RcppSpdlog][rcppspdlog] presented by [this 'spdlog_stopwatch.h' file][spdlog_stopwatch].

It cooperates with the [Python package](https://pypi.org/project/chronometre/) from the
corresponding the sibbling Python repo [chronometre-py][chronometre-py].

### R Demo

So once the [Python package][chronometre-py] is installed (and a virtual environment for it has been
set up), the demo file in this repository and package can be used. It also relies on (CRAN) packages
[reticulate][reticulate] (to talk to Python), [RcppSpdlog][rcppspdlog] for the stopwatch object, and
[xptr][xptr] for some convenient external pointer helpers.

It allocates a stopwatch object, demonstrates it, 'clones' it via a the 'from address string'
constructor in the Python package we access as object `ch` provided via the [reticulate][reticulate]
`import` of the Python package.

This generated sample output such as the following:

```r
> library(chronometre)
> demo("chronometre", ask=FALSE)


        demo(chronometre)
        ---- ~~~~~~~~~~~

> #!/usr/bin/env r
> 
> stopifnot("Demo requires 'reticulate'" = requireNamespace("reticulate", quietly=TRUE))

> stopifnot("Demo requires 'RcppSpdlog'" = requireNamespace("RcppSpdlog", quietly=TRUE))

> stopifnot("Demo requires 'xptr'" = requireNamespace("xptr", quietly=TRUE))

> library(reticulate)

> ## reticulate and Python in general these days really want a venv so we will use one,
> ## the default value is a location used locally; if needed create one
> ## check for existing virtualenv to use, or else set one up
> venvdir <- Sys.getenv("CHRONOMETRE_VENV", "/opt/venv/chronometre")

> if (dir.exists(venvdir)) {
+ >     use_virtualenv(venvdir, required = TRUE)
+ > } else {
+ >     ## create a virtual environment, but make it temporary
+ >     Sys.setenv(RETICULATE_VIRTUALENV_ROOT=tempdir())
+ >     virtualenv_create("r-reticulate-env")
+ >     virtualenv_install("r-reticulate-env", packages = c("chronometre"))
+ >     use_virtualenv("r-reticulate-env", required = TRUE)
+ > }


> sw <- RcppSpdlog::get_stopwatch()                   # we use a C++ struct as example

> Sys.sleep(0.5)                                      # imagine doing some code here

> print(sw)                                           # stopwatch shows elapsed time
0.501220 

> xptr::is_xptr(sw)                                   # this is an external pointer in R
[1] TRUE

> xptr::xptr_address(sw)                              # get address, format is "0x...."
[1] "0x58adb5918510"

> sw2 <- xptr::new_xptr(xptr::xptr_address(sw))       # cloned (!!) but unclassed

> attr(sw2, "class") <- c("stopwatch", "externalptr") # class it .. and then use it!

> print(sw2)                                          # `xptr` allows us close and use
0.501597 

> sw3 <- ch$Stopwatch(  xptr::xptr_address(sw) )      # new Python object via string ctor

> print(sw3$elapsed())                                # shows output via Python I/O
datetime.timedelta(microseconds=502013)

> cat(sw3$count(), "\n")                              # shows double
0.502657 

> print(sw)                                           # object still works in R
0.502721 
> 
```

demonstrating that the memory address is in fact the same, and the behavior is shared. It can also
be run via `Rscript` or `r` or via its shebang; in the latter two cases using `r` only explicit
`print()` statements show output: (and we add comments here as illustration)

```r
$ demo/chronometre.R 
0.501075                                  # R object after 500 msec sleep
0.501281                                  # cloned R object shares that time 
datetime.timedelta(microseconds=501725)   # so does the new Python object
0.502482                                  # or Python returning double
0.502513                                  # and original R object still works    
```

### Author

Dirk Eddelbuettel

### License

GPL (version 2 or later).



[reticulate]: https://github.com/rstudio/reticulate
[arrow]: https://arrow.apache.org/
[nanoarrow]: https://github.com/apache/arrow-nanoarrow
[rcpp]: https://www.rcpp.org
[spdlog]: https://github.com/gabime/spdlog
[rcppspdlog]: https://github.com/eddelbuettel/rcppspdlog
[spdlog_stopwatch]: https://github.com/eddelbuettel/rcppspdlog/blob/master/inst/include/spdlog_stopwatch.h
[xptr]: https://github.com/eddelbuettel/xptr
[chronometre-py]: https://github.com/eddelbuettel/chronometre-py
