# flowengineR

[![R-CMD-check](https://github.com/mwiller1991/flowengineR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mwiller1991/flowengineR/actions/workflows/R-CMD-check.yaml)

`flowengineR` is an R package for defining and running modular
workflows, including fairness-aware preprocessing, in-processing, and
post-processing options.

------------------------------------------------------------------------

## ✨ Features

- Modular architecture with interchangeable engines
- Control-based configuration interface
- Fairness integration at all pipeline levels
- Support for batchtools and adaptive execution
- Integrated reporting and publishing engines
- LLM-assisted engine builder for rapid prototyping of new engines

------------------------------------------------------------------------

## 🚀 Installation

``` r
# Install from GitHub
install.packages("devtools")
devtools::install_github("mwiller1991/flowengineR", build_vignettes = TRUE)
library(flowengineR)
```

------------------------------------------------------------------------

## 🎮 Interactive Start Menu

To make the first steps with `flowengineR` easier, the package provides an **interactive start menu**.  
This menu helps you explore the most important entry points, including running the example workflow, browsing vignettes, or inspecting the structure of control objects.

```r
# Launch the start menu
flowengineR_start()
```

When you run the function, you will see a menu in your console:

```
Where would you like to start?
1: ▶ Run example workflow
2: ☰ Open 'Index' vignette for overview of all vignettes
3: ℹ Open 'Getting Started' vignette
4: ⏺ List available engines
5: ❓ Help for run_workflow()
6: ★ Show structure of control-object
7: ℹ Open 'How to build custom Engines' vignette
8: ℹ Open 'How to use LLM-Engine-Builder' vignette
9: ✖ Exit
```

------------------------------------------------------------------------

## 🧪 Example

``` r
control <- list()

results <- run_workflow(control)
```

------------------------------------------------------------------------

## 📚 Learn more

Check out the vignettes for detailed examples and explanations:

- Index Vignette for flowengineR
- Getting Started with flowengineR
- Why flowengineR had to be built
- End-to-End Workflow Example
- How to Build Custom Engines
- How to Use the LLM-Assisted Engine Builder
- …and many more

You can view them in R using:

``` r
browseVignettes("flowengineR")

vignette("index", package = "flowengineR")
vignette("getting_started", package = "flowengineR")
vignette("why_flowengineR", package = "flowengineR")
vignette("example_workflow_credit", package = "flowengineR")

?run_workflow
```

------------------------------------------------------------------------

## 📚 Citation

For citation please use:

```r
citation("flowengineR")
```

------------------------------------------------------------------------

## 📄 License

MIT © [Maximilian Willer](mailto:willer.maximilian@googlemail.com) and Peter Ruckdeschel

For full license terms, see the LICENSE file in this repository.



