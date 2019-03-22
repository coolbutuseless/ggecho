

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Replicate copies of the original data for a blur/echo effect
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_point
#' @param n number of echoes
#' @param alpha_factor multiplication factor for 'alpha' with each echo
#' @param size_increment size change with each echo
#' @param x_offset,y_offset position offset for each echo
#'
#' @import ggplot2
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stat_echo <- function(mapping = NULL, data = NULL,
                      geom = "point", position = "identity",
                      ...,
                      na.rm           = FALSE,

                      n                = 3,
                      alpha_factor     = 0.5,
                      size_increment   = 1,
                      x_offset         = 0,
                      y_offset         = 0,

                      show.legend     = NA,
                      inherit.aes     = TRUE) {

  layer(
    data = data,
    mapping     = mapping,
    stat        = StatEcho,
    geom        = geom,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm            = FALSE,

      n                = n,
      alpha_factor     = alpha_factor,
      size_increment   = size_increment,
      x_offset         = x_offset,
      y_offset         = y_offset,
      ...
    )
  )
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Stat for Echo
#'
#' @format NULL
#' @usage NULL
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StatEcho <- ggproto(
  "StatEcho", Stat,

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set default params
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  setup_params = function(data, params) {
    modifyList(list(n = 3, alpha_factor = 0.5, size_increment = 1,
                    x_offset = 0, y_offset = 0, angle_increment = 0), params)
  },

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Echo the data at the highest level so that graph limits
  # are properly set
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  compute_layer = function(self, data, params, layout) {

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Call the 'parent' method to do all the proper stuff at the levels of
    # panel and group
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data <- ggproto_parent(Stat, self)$compute_layer(data, params, layout)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # If the data is ungrouped, then an explicit grouping is added. This
    # is needed for proper drawing of disjoint lines (otherwise the tail of
    # one echo would join the head of another)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (!'group' %in% colnames(data))  data$group <- 1

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Calculate the maximum group in the data, so that echoes have
    # group numbers which don't overlap
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    max_group <- max(data$group, na.rm = TRUE)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Echo the data 'n' times
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    dfs <- lapply(seq(params$n, 0), function(i) {
      transform(data,
                x_orig = x,
                y_orig = y,
                x      = x     + params$x_offset * i,
                y      = y     + params$y_offset * i,
                group  = group + max_group       * i,
                echo   = i
      )
    })

    do.call('rbind', dfs)
  },



  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 'compute_group()' - the args to this method are used to define the
  # automatically define the params for this Stat
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  compute_group = function(
    data, scales,
    n                = 3,
    alpha_factor     = 0.5,
    size_increment   = 1,
    x_offset         = 0,
    y_offset         = 0,
    angle_increment  = 0
  ) { data },



  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 'finish_layer()' is our only chance to access and change the final
  # derived aesthetic values.
  # This is where the 'alpha' and 'size' values are re-written based upon
  # the echo depth
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  finish_layer = function(data, params) {

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Set defaults
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    params <- modifyList(list(n = 3, alpha_factor = 0.5, size_increment = 1,
                              x_offset = 0, y_offset = 0, angle_increment = 0), params)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Sanity check
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stopifnot(params$n > 0)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Ensure that we have something to work with
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (!'size'  %in% colnames(data))  data$size  <- 2.0

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Need to do some group manipulation
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    max_group <- max(data$group, na.rm = TRUE)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # If alpha not set anywhere, then it defaults to NA, but I really need
    # it to be numeric so setting it to 1.0
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data$alpha[is.na(data$alpha)] <- 1.0

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # 'alpha' and 'size' are only calculated by the time we get to finish layer
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    transform(data,
              alpha  = alpha * params$alpha_factor   ^ echo,
              size   = size  + params$size_increment * echo
    )
  }
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Testing
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (FALSE) {
  library(ggplot2)

  ggplot(mtcars) +
    stat_echo(aes(mpg, wt, colour = as.factor(am)), geom = "point") +
    theme_bw() +
    theme(legend.position = 'none')

  ggplot(mtcars) +
    geom_point(aes(mpg, wt, colour = as.factor(am)), stat = 'echo') +
    theme_bw() +
    theme(legend.position = 'none')

  ggplot(mtcars) +
    geom_line(aes(mpg, wt, colour = as.factor(am)), stat = 'echo', size_increment = 2) +
    theme_bw() +
    theme(legend.position = 'none')


}

