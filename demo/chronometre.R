#!/usr/bin/env r

library(reticulate)
## Python (these days ...) really wants a venv so we will use one, the default
## value is a location I used
use_virtualenv(Sys.getenv("CHRONOMETRE_VENV", "/opt/venv/chronometre"))
ch <- import("chronometre")

sw <- RcppSpdlog::get_stopwatch()                   # we use a simple C++ struct as example
Sys.sleep(0.5)                                      # imagine doing some code here
print(sw)                                           # stopwatch shows elapsed time

xptr::is_xptr(sw)                                   # this is an external pointer in R
xptr::xptr_address(sw)                              # we can get the address, format is "0x...."

sw2 <- xptr::new_xptr(xptr::xptr_address(sw))       # cloned (!!) but unclassed
attr(sw2, "class") <- c("stopwatch", "externalptr") # class it .. and then use it!
print(sw2)                                          # so `xptr` allows us close and use

sw3 <- ch$Stopwatch(  xptr::xptr_address(sw) )      # so does the Python object _with a string ctor_
print(sw3$elapsed())                                # shows output via Python I/O

print(sw)                                           # object still works in R
