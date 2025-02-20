#' Plot the Shepard diagram to asses the goodness of fit for data reduction using NMDS
#'
#' @param physeq_rel a phyloseq object
#'
#' @return shepard diagram created with ggplot.
#' @export
#'
#' @examples
#' vis_shepard(physeq_rel)
vis_shepard <- function(physeq_rel){

  physeq_nmds <- ordinate(physeq_rel,
                          method = "NMDS",
                          distance = "bray")

  invisible(physeq_nmds)

  shepard_df <- data.frame(dissimilarity = physeq_nmds$diss,
                           distance = physeq_nmds$dist,
                           fit = physeq_nmds$dhat)

  nonmetric_fit_stat <- round(1-physeq_nmds$stress^2, 3)
  linear_fit_stat <- round(cor(physeq_nmds$dhat, physeq_nmds$dist)^2, 3)

  x_range <- range(shepard_df$dissimilarity) + c(-0.1, 0.1)
  y_range <- range(shepard_df$distance) + c(-0.1, 0.1)

  ggplot(data = shepard_df,
         mapping = aes(x = dissimilarity,
                       y = distance)) +
    theme_classic() +
    geom_point(color = "#003d73",
               alpha = 0.6,
               size = 2) +
    geom_step(mapping = aes(y = fit),
              direction = "vh",
              linewidth = 0.8) +
    xlab("Observed Dissimilarity") +
    ylab("Ordination Distance") +
    theme(axis.title.x = element_text(face = "bold",
                                      vjust = -1),
          axis.title.y = element_text(face = "bold",
                                      vjust = 3),
          panel.background = element_rect(fill = "#F7F7F7", color = NA),
          panel.grid.major = element_line(color = "white", size = 1),
          panel.grid.minor = element_line(color = "white", size = 0.5)) +
    geom_label(label = paste("Non-metric fit:",
                             nonmetric_fit_stat,
                             "\n",
                             "Linear fit:",
                             linear_fit_stat),
               x = min(shepard_df$dissimilarity),
               y = max(shepard_df$distance),
               label.padding = unit(0.55, "lines"), # Rectangle size around label
               label.size = 0.35,
               color = "#003d73",
               fill="white",
               fontface = "bold",
               hjust = 0,
               vjust = 1)
}
