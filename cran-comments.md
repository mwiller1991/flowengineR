## Submission

This is the first submission of flowengineR to CRAN.

flowengineR accompanies a manuscript submitted to the Journal of
Statistical Software, which requires the package to be available on
CRAN. A preprint is available at <doi:10.48550/arXiv.2511.00079>.

## Test environments

* local: macOS 26.6 (aarch64-apple-darwin20), R 4.5.0
* GitHub Actions: ubuntu-latest (R release and R devel),
  windows-latest (R release), macos-latest (R release)
* win-builder: R-devel and R-release

## R CMD check results

0 errors | 0 warnings | 1 note

* New submission.

## Additional comments

* Random numbers: `create_dataset_bank()` and the splitter engines take
  a user-facing `seed` argument for reproducible data generation and
  data splitting. The random number generator state of the R session is
  restored on exit (`withr::local_seed()` in `create_dataset_bank()`,
  `withr::local_preserve_seed()` in `run_workflow()`).
* By default, files are only written to `tempdir()`. Output folders for
  publishing and batchtools registries can be set by the user; the SLURM
  engines require the user to set them explicitly.
* Examples, tests and vignettes use at most two cores.