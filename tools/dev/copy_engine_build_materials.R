# dev/copy_engine_build_materials.R

#' Copies development files into inst/ for engine-building ZIP functionality
#'
#' Run this before a release or when the ZIP should work in installed packages
#' using system.file(). It ensures all files needed for build_engine_with_llm_zip()
#' are available in inst/example_enginebuild_LLM/.
fs::dir_create("inst/example_enginebuild_LLM")

#---
#Splitter  
#---

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


#---
#Execution  
#---

fs::file_copy(
  "R/2_2_1_a__engine_execution_basic_sequential__mwiller.R",
  "inst/example_enginebuild_LLM/engine_execution_basic_sequential.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_execution.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_execution.Rmd",
  overwrite = TRUE
)


#---
#preprocessing  
#---

fs::file_copy(
  "R/2_3_a__engine_preprocessing_fairness_resampling__mwiller.R",
  "inst/example_enginebuild_LLM/engine_preprocessing_fairness_resampling.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_preprocessing.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_preprocessing.Rmd",
  overwrite = TRUE
)


#---
#train  
#---

fs::file_copy(
  "R/2_4_b__engine_train_glm__mwiller.R",
  "inst/example_enginebuild_LLM/engine_train_glm.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_train.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_train.Rmd",
  overwrite = TRUE
)


#---
#inprocessing  
#---

fs::file_copy(
  "R/2_5_a__engine_inprocessing_fairness_adversialdebiasing__mwiller.R",
  "inst/example_enginebuild_LLM/engine_inprocessing_fairness_adversialdebiasing.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_inprocessing.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_inprocessing.Rmd",
  overwrite = TRUE
)


#---
#postprocessing  
#---

fs::file_copy(
  "R/2_6_a__engine_postprocessing_fairness_genresidual__mwiller.R",
  "inst/example_enginebuild_LLM/engine_postprocessing_fairness_genresidual.R",
  overwrite = TRUE
)

fs::file_copy(
  "vignettes/detail_engines_postprocessing.Rmd",
  "inst/example_enginebuild_LLM/detail_engines_postprocessing.Rmd",
  overwrite = TRUE
)


#---
#Eval  
#---
  
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
