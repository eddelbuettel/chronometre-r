
if (!requireNamespace("RcppSpdlog", quietly=TRUE))
    q(save="no")
sw <- RcppSpdlog::get_stopwatch()
stopifnot(inherits(sw, "stopwatch"))
stopifnot(inherits(sw, "externalptr"))

td <- RcppSpdlog::elapsed_stopwatch(sw)
stopifnot(inherits(td, "numeric"))
stopifnot(td > 0)

Sys.sleep(0.5)
td2 <- RcppSpdlog::elapsed_stopwatch(sw)
stopifnot(td2 - td >= 0.5)


if (!requireNamespace("xptr", quietly=TRUE))
    q(save="no")

sw2 <- xptr::new_xptr(xptr::xptr_address(sw))
attr(sw2, "class") <- c("stopwatch", "externalptr")

td3 <- RcppSpdlog::elapsed_stopwatch(sw2)
stopifnot(inherits(td3, "numeric"))
stopifnot(td3 > 0)


venvdir <- Sys.getenv("CHRONOMETRE_VENV", "/opt/venv/chronometre")
if (!dir.exists(venvdir))
    q(save="no")

if (!requireNamespace("reticulate", quietly=TRUE))
    q(save="no")
library(reticulate)
use_virtualenv(venvdir)
ch <- import("chronometre")

sw3 <- ch$Stopwatch(xptr::xptr_address(sw))
res <- sw3$elapsed()  # char, need a as.numeric alike
stopifnot(inherits(res, "character"))
