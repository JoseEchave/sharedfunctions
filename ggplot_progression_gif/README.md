Goal of this is to is to be able to create fairly easily a gif with the progression of a plot from start of the ideation to finnish.
Based on the idea of @geokaramanis, inspiration: https://twitter.com/geokaramanis/status/1251553605787754503

This is done by calling ggsave() function everytime a plot is rendered in a predefined folder, name is defined by the time when it was rendered.

Then using magick fetch all the images in the predefined folder and create a gif like this

![](plot_progression.gif)
