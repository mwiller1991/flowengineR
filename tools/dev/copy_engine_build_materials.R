# dev/copy_engine_build_materials.R

#' Copies development files into inst/ for engine-building ZIP functionality
#'
#' Run this before a release or when the ZIP should work in installed packages
#' using system.file(). It ensures all files needed for build_engine_with_llm_zip()
#' are available in inst/example_enginebuild_LLM/.
fs::dir_create("inst/example_enginebuild_LLM")

---
#Splitter  
---

fs::file_copy(
  "R/2_1_c__engine_split_random__mwiller.R",
  "inst/example_enginebuild_LLM/engine_split_random.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_split.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_split.Rmd",
  overwrite = TRUE
)


---
#Eval  
---
  
fs::file_copy(
  "R/2_7_2_a__engine_eval_mse__mwiller.R",
  "inst/example_enginebuild_LLM/engine_eval_mse.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_evaluation.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_evaluation.Rmd",
  overwrite = TRUE
)
