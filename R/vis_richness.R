#' Plot alpha diversity with Shannon and Inverse Simpson measures
#'
#' @param physeq
#' @param group_x
#' @param group_color
#'
#' @return
#' @export
#'
#' @examples
vis_richness <- function(physeq, group_x, group_color){

  sample_df <- as.data.frame(sample_data(physeq))
  group_color_num <- pull(sample_df, {{group_color}})
  group_color_num <- length(unique(group_color_num))

  plot <- plot_richness(physeq = physeq,
                        x = as_name(enquo(group_x)),
                        color = as_name(enquo(group_color)),
                        measures = c("Shannon", "InvSimpson"))

  plot <- plot +
    geom_boxplot(data = plot$data,
                 aes(color = NULL),
                 fill = "white",
                 alpha = 1,
                 show.legend = FALSE) +
    geom_point(size = 2,
               alpha = 0.8) +
    theme_classic() +
    scale_fill_manual(values = fetch_color("main1", group_color_num)) +
    scale_color_manual(values = fetch_color("main1", group_color_num)) +
    theme(axis.title.x = element_text(face = "bold",
                                      vjust = -1),
          axis.title.y = element_text(face = "bold",
                                      vjust = 3),
          panel.background = element_rect(fill = "#F7F7F7", color = NA),
          panel.border = element_rect(color = "black", size = 1, fill = NA),
          legend.title = element_text(face = "bold"),
          strip.background = element_rect(color="black",
                                          fill="black",
                                          size=1.5,
                                          linetype="solid"),
          strip.text.x = element_text(color = "white",
                                      face = "bold"))

  return(plot)
}

