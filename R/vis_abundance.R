#' Plot the relative abundances for merged species of the same taxonomic rank.
#'
#' @param physeq a phyloseq object.
#' @param group_x the x axis sample variable to plot.
#' @param group_split name of the sample data column to group by.
#' @param level_glom name of the level to agglomerate counts. Default is "Phylum".
#' @param level_select specified level to target for specified group (e.g., domain level - useful with add_level()). Default is NULL.
#' @param group_select specified group to target in specified level (e.g., Prokaryotes in the domain level). Default is NULL.
#' @param lower_limit relative abundance threshold in percentages for visualizing the abundance. Abundances less than the threshold is pooled together.
#' @param remove_grid remove the grid splitting groups. Default is FALSE.
#'
#' @return a abundance plot created with ggplot.
#' @export
#'
#' @examples
vis_abundance <- function(physeq,
                          group_x,
                          group_split,
                          level_glom = Phylum,
                          level_select = NULL,
                          group_select = NULL,
                          lower_limit = 2,
                          remove_grid = FALSE){
  # Agglomerate counts.
  physeq_df <- physeq |>
    tax_glom(taxrank = as_name(enquo(level_glom)),
             NArm = FALSE) |>
    transform_sample_counts(function(x) x/sum(x)*100) |>
    psmelt() |>
    mutate({{level_glom}} := replace_na(.data[[as_name(enquo(level_glom))]], "Unassigned"),  # Replace NA with "Unassigned"
           {{level_glom}} := ifelse(Abundance < lower_limit,
                                    paste("< ", lower_limit, "%", sep = ""),
                                    .data[[as_name(enquo(level_glom))]]),
           {{level_glom}} := reorder(.data[[as_name(enquo(level_glom))]], Abundance),
           {{level_glom}} := factor({{level_glom}}),
           {{group_split}} := factor({{group_split}}))

  # Get number of unique colors to use.
  group_unique <- unique(pull(physeq_df, {{level_glom}}))
  group_color_num <- length(group_unique)

  # Specify the color of the low detection and unassigned groups.
  if ("Unassigned" %in% group_unique){
    physeq_df <- physeq_df |>
      mutate({{level_glom}} := fct_relevel({{level_glom}}, "Unassigned", after = 1))
    group_unique <- unique(pull(physeq_df, {{level_glom}}))
    group_color <- c("#878787", "#4b4b4a", rev(fetch_color("main3", group_color_num-2)))
  } else if ("Unknown function" %in% group_unique){
    physeq_df <- physeq_df |>
      mutate({{level_glom}} := fct_relevel({{level_glom}}, "Unknown function", after = 1))
    group_unique <- unique(pull(physeq_df, {{level_glom}}))
    group_color <- c("#878787", "#4b4b4a", rev(fetch_color("main3", group_color_num-2)))
  } else if ("Others" %in% group_unique){
    physeq_df <- physeq_df |>
      mutate({{level_glom}} := fct_relevel({{level_glom}}, "Others", after = 1))
    group_unique <- unique(pull(physeq_df, {{level_glom}}))
    group_color <- c("#878787", "#4b4b4a", rev(fetch_color("main3", group_color_num-2)))
  } else {
    group_color <- c("#878787", rev(fetch_color("main3", group_color_num-1)))
  }

  # Subset data if specified by user.
  if (!is.null(level_select) && !is.null(level_select)){
    physeq_df <- physeq_df |>
      filter(.data[[as_name(sym(level_select))]] %in% group_select)
  }

  # Update colors.
  group_reduced_unique <- unique(pull(physeq_df, {{level_glom}}))
  index_color <- which(levels(group_unique) %in% group_reduced_unique)
  group_color <- group_color[index_color]

  # Create plot.
  plot <- ggplot(data = physeq_df,
                 mapping = aes(x = {{group_x}},
                               y = Abundance,
                               fill = {{level_glom}})) +
    geom_bar(stat = "identity") +
    labs(x = "",
         y = "Relative abundance [%]") +
    theme_classic() +
    theme(axis.ticks.x = element_blank(),
          axis.text.x = element_text(angle = 90, hjust = 1),
          axis.title.x = element_text(face = "bold",
                                      vjust = -1),
          axis.title.y = element_text(face = "bold",
                                      vjust = 3),
          panel.background = element_rect(fill = "#F7F7F7", color = NA),
          panel.grid.major.y = element_line(color = "white", size = 1),
          panel.grid.minor.y = element_line(color = "white", size = 0.5),
          panel.border = element_rect(color = "black", size = 1, fill = NA),
          legend.title = element_text(face = "bold"),
          strip.background = element_rect(color="black",
                                          fill="black",
                                          size=1.5,
                                          linetype="solid"),
          strip.text.x = element_text(color = "white",
                                      face = "bold")) +
    scale_fill_manual(values = group_color)

  # Add the grid to distinguish between groups.
  if (remove_grid == FALSE){
    plot <- plot + facet_grid(cols = vars({{group_split}}), scales = "free_x", space = "free_x")
  }

  return(plot)
}

