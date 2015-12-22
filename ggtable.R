#' ggtable - quick bar plots with ggplot2
#'
#' Function to plot fequencies and crosstabulations as horizontal bars or
#' stacked bars, using frequencies or percentages. Please visit
#' \url{http://github.com/briatte/ggtable} for the latest version of
#' \code{ggtable}.
#'
#' @export
#' @param x, y the vectors to plot. If \code{y} is provided, the function
#' returns the stacked bars corresponding to \code{table(x, y)}.
#' @param weights a vector of probability weights that applies to \code{x} and
#' \code{y}.
#' Defaults to \code{NULL} (no weighting).
#' @param percent whether to use percentages instead of frequencies.
#' Defaults to \code{FALSE}.
#' @param breaks the number of breaks to show on the count or percent scale.
#' Defaults to \code{5}.
#' @param name when \code{y} is supplied, the title of its colour legend.
#' @param order whether to sort the levels of \code{x} by decreasing order of
#' frequency.
#' Defaults to \code{FALSE} (no reordering).
#' @param label whether to add text labels to the bars.
#' Defaults to \code{FALSE}.
#' @param hjust horizontal adjustment for the bar labels.
#' Defaults to \code{0.5} (centered).
#' @param fill when \code{y} is \emph{not} supplied, the color of the bars.
#' Defaults to \code{"grey20"} (dark grey).
#' @param color color for the bar labels.
#' Defaults to \code{"grey90"} (quasi-white).
#' @param append a character string to append to the bar labels.
#' Defaults to \code{""} (nothing).
#' @param round the rounding to apply to the bar labels, if they are shown.
#' Defaukts to \code{0} (integer rounding).
#' @param palette when \code{y} is supplied, the name of a ColorBrewer palette
#' to color the bars with.
#' Defaults to \code{NULL} (use default colors).
#' @param position when \code{y} is supplied, the position of the bars split by
#' \code{y}.
#' Defaults to \code{"stack"}.
#' @param legend.position location of the legend for bar colors and weights.
#' Accepts all positions supported by \code{\link[ggplot2]{themes}}.
#' Defaults to \code{"right"}.
#' @param ... other arguments supplied to \code{\link[gpplot2]{geom_text}} to
#' label the bars.
#' @note \code{ggtable} gets rid of all missing observations before plotting; to
#' include them in the plot, recode \code{NA} values before using the function.
#' @seealso \code{\link[likert]{plot.likert}} in the \link[likert]{likert}
#' package
#' @author Francois Briatte
#' @examples
#' if (require(GGally)) {
#'   data(happy, package = "GGally")
#'
#'   # one-way tables
#'
#'   ggtable(happy$marital, weights = happy$wtssall)
#'   ggtable(happy$marital, weights = happy$wtssall, percent = TRUE, order = TRUE)
#'   ggtable(happy$marital, weights = happy$wtssall, percent = TRUE, label = TRUE, append = "%")
#'
#'   # two-way tables
#'
#'   ggtable(happy$marital, happy$sex, weights = happy$wtssall)
#'   ggtable(happy$sex, happy$marital, weights = happy$wtssall)
#'   ggtable(happy$sex, happy$marital, weights = happy$wtssall, percent = TRUE)
#'
#'   # using options
#'
#'   ggtable(happy$degree, happy$health, weights = happy$wtssall, percent = TRUE,
#'           label = TRUE, name = "", palette = "PRGn") +
#'     labs(y = NULL, x = NULL, title = "Health status, by education level") +
#'     theme_bw(16) +
#'     theme(legend.position = "top", axis.ticks = element_blank())
#' }
ggtable <- function(x, y = NULL, weights = NULL, percent = FALSE, breaks = 5,
                    name = NULL, order = FALSE, label = FALSE, hjust = 0.5,
                    fill = "grey20", color = "grey90",
                    append = "", round = 0, big.mark = ",", decimal.mark = ".",
                    palette = NULL, horizontal = TRUE,
                    position = "stack", legend.position = "right", ...) {

  # -- required packages -------------------------------------------------------

  require(ggplot2, quietly = TRUE)
  require(plyr, quietly = TRUE)
  require(scales, quietly = TRUE)

  # -- checks ------------------------------------------------------------------

  if (nchar(decimal.mark) < 1) {
    stop("incorrect decimal.mark value")
  }

  if (!is.null(y) && (length(x) != length(y))) {
    stop("x and y are of unequal length")
  }

  if (is.null(weights)) {
    weights = rep(1, length(x))
  }

  if (length(x) != length(weights)) {
    stop("x and weights are of unequal length")
  }

  # -- remove missing values ---------------------------------------------------

  m = is.na(x) || is.na(weights)
  if (!is.null(y)) m = m || is.na(y)

  x = x[ !m ]
  if (!is.null(y)) y = y[ !m ]

  weights = weights[ !m ]

  # -- variable names for axis and legend titles -------------------------------

  get_variable = function(x, name = NULL) {
    if (is.null(name)) {
      x = as.character(x)
      x[ length(x) ]
    } else {
      name
    }
  }

  get_number = function(x, y) {
    if (percent && big.mark == decimal.mark) big.mark = ""
    if (percent) x = round(100 * x, round)
    x = scales::format_format(big.mark = big.mark, decimal.mark = decimal.mark,
                              scientific = FALSE)(x)
    paste0(x, y)
  }

  # -- get the table as frequencies or percentages -----------------------------

  # get table
  if (is.null(y)) {
    t = tapply(weights, x, sum, simplify = TRUE)
  } else {
    t = tapply(weights, list(x, y), sum, simplify = TRUE)
  }
  t = as.table(t)

  if (percent && is.null(y)) {
    t = prop.table(t)
  } else if (percent && !is.null(y)) {
    t = prop.table(t, 1)
  }

  # preserve/add levels
  t = data.frame(t, stringsAsFactors = TRUE)

  # optional reorder(x)
  if (isTRUE(order)) {
    t$Var1 = with(t, reorder(Var1, Freq, mean))
  }

  # -- plot structure ----------------------------------------------------------

  if (is.null(y)) {

    # -- one-way horizontal bars -----------------------------------------------

    g = ggplot(data = t, aes(x = Var1, y = Freq), fill = fill) +
      geom_bar(stat = "identity") +
      xlab(get_variable(substitute(x)))

    if (percent) {
      g = g + scale_y_continuous(breaks = scales::pretty_breaks(breaks),
                                 labels = scales::percent_format()) +
        ylab("percent")

    } else {
      g = g +
        scale_y_continuous(breaks = scales::pretty_breaks(breaks)) +
        ylab("count")
    }

    if (label) {
      g = g +
        geom_text(aes(y = Freq / 2, label = get_number(Freq, append)),
                  hjust = hjust, color = color, ...)
    }

  } else {

    # -- two-way horizontal bars -----------------------------------------------

    pos = plyr::ddply(t, .(Var1), transform, ycoord = (cumsum(Freq) - Freq / 2))

    g = ggplot(data = t, aes(x = Var1, y = Freq, fill = Var2)) +
      geom_bar(stat = "identity", position = position) +
      xlab(get_variable(substitute(x)))

    if (is.null(palette)) {
      g = g + scale_fill_discrete(get_variable(substitute(y), name))
    } else {
      g = g + scale_fill_brewer(get_variable(substitute(y), name), palette = palette)
    }

    if (percent) {
      g = g + scale_y_continuous(breaks = scales::pretty_breaks(breaks),
                                 labels = scales::percent_format()) +
        ylab("percent")

    } else {
      g = g +
        scale_y_continuous(breaks = scales::pretty_breaks(breaks)) +
        ylab("count")
    }

    if (label) {

      g = g +
        geom_text(data = pos,
                  aes(label = get_number(Freq, append), x = Var1, y = ycoord),
                  hjust = hjust, color = color, ...)
    }

  }

  # -- horizontal flip ---------------------------------------------------------

  if (horizontal) g = g + coord_flip()

  # -- finalize ----------------------------------------------------------------

  g = g +
    theme(legend.position = legend.position)

  return(g)

}
