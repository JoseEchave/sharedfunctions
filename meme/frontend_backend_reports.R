library(magick)
library(tidyverse)
homer <- magick::image_read("https://i.kym-cdn.com/photos/images/newsfeed/001/399/024/3cc.jpg") %>% 
  image_annotate("Reproducible \n report",location = "+40+100",size = 30) %>% 
  image_annotate("Rmd with  \n lots of code",location = "+40+550",size = 30)
homer

homer%>% 
  image_write("output/front_end_rmd.jpg")
