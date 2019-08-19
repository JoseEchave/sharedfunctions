#' Add company Logo to last created ggplot2 graph
#' Creates image with the last_plot() and adds a grid with Ensto Logo
#' @param width Width of image to be created
#' @param height Height of image to be created
#' @param dim_units Unit of width and heights can be "in","px",...
#' @param res resolution of image to be created in dpi
#'
#' @export
add_logo<-function(width=6,height=5,res=300,dim_units="in"){
  logo_URL<-system.file(file.path("logos","your_logo.jpg"),package="your package") #Save the logo in your package (more consistent directory)
  logo  <- magick::image_read(logo_URL)

  while (!is.null(grDevices::dev.list())) { grDevices::dev.off()}

  temp_file_1<-paste0(tempfile(), ".png")
  grDevices::png(temp_file_1, units=dim_units, width=width, height=0.25, res=res) #Adapt height if needed
  p<-grid::grid.raster(logo, x = 0.07, y = 0.03, just = c('left', 'bottom'), width = grid::unit(1, 'inches')) #Adapt footer size for your logo
  print(p)
  invisible(grDevices::dev.off())
  background<-magick::image_read(temp_file_1)

  temp_file_2<-paste0(tempfile(), ".png")
  grDevices::png(temp_file_2, units=dim_units, width=width, height=height, res=res)
  p2<-ggplot2::last_plot()
  print(p2)
  invisible(grDevices::dev.off())
  plot<-magick::image_read(temp_file_2)

  final_plot <- magick::image_append(c(plot, background),stack=TRUE)
  print(final_plot)

}
