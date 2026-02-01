#!/usr/bin/env r

stopifnot("Demo requires 'reticulate'" = requireNamespace("reticulate", quietly=TRUE))
stopifnot("Demo requires 'RcppSpdlog'" = requireNamespace("RcppSpdlog", quietly=TRUE))
stopifnot("Demo requires 'xptr'" = requireNamespace("xptr", quietly=TRUE))

library(reticulate)
## reticulate and Python in general these days really want a venv so we will use one,
## the default value is a location used locally; if needed create one
## check for existing virtualenv to use, or else set one up
venvdir <- Sys.getenv("CHRONOMETRE_VENV", "/opt/venv/chronometre")
if (dir.exists(venvdir)) {
    use_virtualenv(venvdir, required = TRUE)
} else {
    ## create a virtual environment, but make it temporary
    Sys.setenv(RETICULATE_VIRTUALENV_ROOT=tempdir())
    virtualenv_create("r-reticulate-env")
    virtualenv_install("r-reticulate-env", packages = c("chronometre"))
    use_virtualenv("r-reticulate-env", required = TRUE)
}
ch <- import("chronometre")

sw <- RcppSpdlog::get_stopwatch()                   # we use a C++ struct as example
Sys.sleep(0.5)                                      # imagine doing some code here
print(sw)                                           # stopwatch shows elapsed time

xptr::is_xptr(sw)                                   # this is an external pointer in R
xptr::xptr_address(sw)                              # get address, format is "0x...."

sw2 <- xptr::new_xptr(xptr::xptr_address(sw))       # cloned (!!) but unclassed
attr(sw2, "class") <- c("stopwatch", "externalptr") # class it .. and then use it!
print(sw2)                                          # `xptr` allows us close and use

sw3 <- ch$Stopwatch(  xptr::xptr_address(sw) )      # new Python object via string ctor
print(sw3$elapsed())                                # shows output via Python I/O
cat(sw3$count(), "\n")                              # shows double


print(sw)                                           # object still works in R
