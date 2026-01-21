
## basic functionality from RcppSpdlog
if (!requireNamespace("RcppSpdlog", quietly=TRUE)) exit_file("No RcppSpdlog")
## get a stopwatch, check its types
sw <- RcppSpdlog::get_stopwatch()
expect_inherits(sw, "stopwatch")
expect_inherits(sw, "externalptr")

## get elapsed time, ie test stopwatch
td <- RcppSpdlog::elapsed_stopwatch(sw)
expect_inherits(td, "numeric")
expect_true(td > 0)

## sleep and check sleep time has passed
Sys.sleep(0.5)
td2 <- RcppSpdlog::elapsed_stopwatch(sw)
expect_true(td2 - td >= 0.5)



## interfacing using xptr
if (!requireNamespace("xptr", quietly=TRUE)) exit_file("No xptr")
## create a new stopwatch instance from the address of the existing one
sw2 <- xptr::new_xptr(xptr::xptr_address(sw))
expect_inherits(sw2, "externalptr")
attr(sw2, "class") <- c("stopwatch", "externalptr")
expect_inherits(sw2, "stopwatch")
## check its elapsed time
td2 <- RcppSpdlog::elapsed_stopwatch(sw2)
expect_inherits(td2, "numeric")
expect_true(td2 > 0)


## interface the Python package
if (!requireNamespace("reticulate", quietly=TRUE)) exit_file("No reticulate")
library(reticulate)
## check for existing virtualenv to use, or else set one up
venvdir <- Sys.getenv("CHRONOMETRE_VENV", "/opt/venv/chronometre")
if (dir.exists(venvdir)) {
    use_virtualenv(venvdir)
} else {
    virtualenv_create("r-reticulate-env")
    virtualenv_install("r-reticulate-env", packages = c("chronometre"))
    use_virtualenv("r-reticulate-env", required = TRUE)
}
ch <- import("chronometre")

## now create Python object, check elapsed time (in two formats)
sw3 <- ch$Stopwatch(xptr::xptr_address(sw))
expect_inherits(sw3, "python.builtin.object")
expect_inherits(sw3, "pybind11_builtins.pybind11_object")
expect_inherits(sw3, "chronometre._chronometre.Stopwatch")
td3 <- sw3$elapsed()
expect_inherits(td3, "datetime.timedelta")
expect_inherits(td3, "python.builtin.object")
td4 <- sw3$count()
expect_inherits(td4, "numeric")
expect_true(td4 > td2)
