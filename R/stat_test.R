

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Leave data as is, but print the head() of the data at each stage
#'
#' The identity statistic leaves the data unchanged but was a useful way to
#' figure out how Stats work.
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_point
#'
#' @import ggplot2
#' @export
#'
#' @examples
#' \dontrun{
#'   ggplot(mtcars) +
#'    stat_debug(aes(mpg, wt, colour = as.factor(cyl)), geom = 'point') +
#'    theme_bw()
#' }
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stat_debug <- function(mapping = NULL, data = NULL,
                       geom = "point", position = "identity",
                       ...,
                       show.legend = NA,
                       inherit.aes = TRUE) {
  layer(
    data = data,
    mapping     = mapping,
    stat        = StatDebug,
    geom        = geom,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = FALSE,
      ...
    )
  )
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Stat for Debug
#'
#' @format NULL
#' @usage NULL
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StatDebug <- ggproto(
  "StatDebug", Stat,

  setup_params = function(data, params) {
    cat("===================  setup_params() ==================\n")
    print(head(data))

    params
  },

  compute_layer = function(self, data, params, layout) {
    cat("===================  compute_layer() ==================\n")
    print(head(data))

    ggproto_parent(Stat, self)$compute_layer(data, params, layout)
  },

  compute_panel = function(self, data, scales) {
    cat("===================  compute_panel() ==================\n")
    print(head(data))

    ggproto_parent(Stat, self)$compute_panel(data, scales)
  },

  compute_group = function(data, scales) {
    cat("===================  compute_group() ==================\n")
    print(head(data))

    data
  },

  finish_layer = function(data, params) {
    cat("===================  finish_layer() ==================\n")
    print(head(data))

    data
  }


)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Testing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (FALSE) {
  ggplot(mtcars) +
    stat_debug(aes(mpg, wt, colour = as.factor(cyl)), geom = 'point') +
    theme_bw()
}


