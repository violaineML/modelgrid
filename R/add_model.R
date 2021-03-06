#' Adds a model specification to a model grid
#'
#' Defines and adds an individual model (and model training) specification to an
#' existing model grid.
#'
#' @param model_grid \code{model_grid}
#' @param model_name \code{character}, your custom name for a given model. Must be
#' unique within the model grid. If you do not provide a name, the model will be
#' given a generic name - 'Model[int]'.
#' @param custom_control \code{list}, any customization to subsettings of the 'trControl'
#' component from the 'shared_settings' of the model grid (will only work if
#' trControl' parameter has actually been set as part of the shared settings).
#' @param ... All (optional) individual settings (including model training settings)
#' that the user wishes to set for the new model.
#'
#' @return \code{model_grid} with an additional individual model specification.
#'
#' @export
#'
#' @examples
#' library(magrittr)
#'
#' # Pre-allocate empty model grid.
#' mg <- model_grid()
#'
#' # Adds 'random forest' model spec.
#' mg <-
#'   mg %>%
#'   add_model(model_name = "Random Forest Test", method = "rf", tuneLength = 5)
add_model <- function(model_grid, model_name = NULL, custom_control = NULL, ...) {

  # check inputs.
  if (is.null(custom_control) && length(list(...)) == 0) {
    stop("No model specific settings were given.")
    }

  if (!inherits(model_grid, "model_grid")) {
    stop("The 'model_grid' argument must inherit from the 'model_grid' class.")
    }

  if (!is.null(model_name) && exists(model_name, model_grid[["models"]])) {
    stop("Model names should be unique. That name is already taken.")
  }

  if (!is.null(custom_control) && !exists("trControl", model_grid[["shared_settings"]])) {
    warning("'custom_control' argument has been set, but no 'trControl' ",
            "component has been specified within 'shared_settings'. This model ",
            "specification will fail to compile, if you do not provide the ",
            "'trControl' component to the shared settings of the model grid.")
  }

  if (!is.null(custom_control) && exists("trControl", list(...))) {
    stop("It is not meaningful to provide BOTH 'custom_control' and 'trControl' ",
         "arguments in the model specific configuration.")
    }

  if (exists("method", list(...)) && !(list(...)[["method"]] %in% caret::modelLookup()[["model"]])) {
    stop("'method' is not supported by this version of caret.")
  }

  # sets model name automatically, if it has not already been set.
  if (is.null(model_name)) {
    if (is.null(model_grid$models)) {
      # indexing starts from zero.
      model_name <- "Model0"
    } else {
      model_name <-
        dplyr::setdiff(
          paste0("Model", c(0, seq_along(model_grid$models))),
          names(model_grid$models)
        ) %>%
        sort(.) %>%
        magrittr::extract2(1)
    }
  }

  # adds model to model grid.
  model_grid[["models"]][[model_name]] <- list(...)

  # prepares any customizations to shared 'trControl'.
  if (!is.null(custom_control)) {
    model_grid[["models"]][[model_name]][["custom_control"]] <- custom_control
  }

  # sorts models by name.
  model_grid[["models"]] <-
    model_grid[["models"]][sort(names(model_grid[["models"]]))]

  # returns model grid with the addition of the specified model.
  model_grid

}
