.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\nWelcome to flowengineR!\n\n",
    "Get started: run_workflow() or vignette(\"getting_started\")\n",
    "Try: flowengineR_start() for an interactive tour\n",
    "Help: ?run_workflow\n"
  )
}
