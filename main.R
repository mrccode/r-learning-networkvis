# In most R functions, you can use named colors, hex, or rgb values:

plot(x=1:10, y=rep(5,10), pch=19, cex=5, col="dark red")
points(x=1:10, y=rep(6, 10), pch=19, cex=5, col="#557799")
points(x=1:10, y=rep(4, 10), pch=19, cex=5, col=rgb(.25, .5, .3))

# In the simple base plot chart above, x and y are point coordinates, 'pch' 
# is the point symbol shape, 'cex' is the point size, and 'col' is the color.
# to see the parameters for plotting in base R, check out ?par

# If you plan on using the built-in color names, here's what they are: 
colors() # all colors
grep("blue", colors(), value=T) # colors that have 'blue' in the name

# You may notice that rgb here ranges from 0 to 1. While this is the R default,
# you can also set it for the more typical 0-255 range: 
rgb(10, 100, 100, maxColorValue=255) 

# --TRANSPARENCY--

# We can also set the opacity/transparency using the parameter 'alpha' (range 0-1):
plot(x=1:5, y=rep(5,5), pch=19, cex=16, col=rgb(.25, .5, .3, alpha=.5), xlim=c(0,6))  

# If we have a hex color representation, we can set the transparency alpha 
# using 'adjustcolor' from package 'grDevices'. For fun, let's also set the
# the plot background to black using the par() function for graphical parameters.
# We could also set the margins in par() with mar=c(bottom, left, top, right).
par(bg="black")

col.tr <- grDevices::adjustcolor("#557799", alpha=0.7)
plot(x=1:5, y=rep(5,5), pch=19, cex=20, col=col.tr, xlim=c(0,6)) 

par(bg="white")

# --PALETTES--

# In many cases, we need a number of contrasting colors, or multiple shades of a color.
# R comes with some predefined palette function that can generate those for us.
pal1 <- heat.colors(5, alpha=1)   # generate 5 colors from the heat palette, opaque
pal2 <- rainbow(5, alpha=.5)      # generate 5 colors from the heat palette, semi-transparent
plot(x=1:10, y=1:10, pch=19, cex=10, col=pal1)
par(new=TRUE) # tells R not to clear the first plot before adding the second one
plot(x=10:1, y=1:10, pch=19, cex=10, col=pal2)

# We can also generate our own gradients using colorRampPalette().
# Note that colorRampPalette returns a *function* that we can use 
# to generate as many colors from that palette as we need.

palf <- colorRampPalette(c("gray70", "dark red")) 
plot(x=10:1, y=1:10, pch=19, cex=10, col=palf(10)) 

# To add transparency to colorRampPalette, you need to add a parameter `alpha=TRUE`:
palf <- colorRampPalette(c(rgb(1,1,1, .2),rgb(.8,0,0, .7)), alpha=TRUE)
plot(x=10:1, y=1:10, pch=19, cex=10, col=palf(10)) 

# --COLORBREWER--

# Finding good color combinations is a tough task - and the built-in R palettes
# are rather limited. Thankfully there are other available packages for this:

# install.packages("RColorBrewer")
library("RColorBrewer")

display.brewer.all()

# This package has one main function, called 'brewer.pal'.
# Using it, you just need to select the desired palette and a number of colors.
# Let's take a look at some of the RColorBrewer palettes:
display.brewer.pal(8, "Set3")
display.brewer.pal(8, "Spectral")
display.brewer.pal(8, "Blues")

# Plot figures using ColorBrewer
# We'll use par() to plot multiple figures.
# plot row by row: mfrow=c(number of rows, number of columns)
# plot column by column: mfcol=c(number of rows, number of columns)

par(mfrow=c(1,2)) # plot two figures - 1 row, 2 columns

pal3 <- brewer.pal(10, "Set3")
plot(x=10:1, y=10:1, pch=19, cex=6, col=pal3)
plot(x=10:1, y=10:1, pch=19, cex=6, col=rev(pal3)) # backwards

dev.off() # shut off the  graphic device to clear the two-figure configuration.

detach("package:RColorBrewer")

#  ------->> Fonts in R plots --------

# Using different fonts for R plots may take a little bit of work.
# Especially for Windows - Mac & Linux users may not have to do this.
# First we'd use the 'extrafont' package to import the fonts from the OS into R:

# install.packages("extrafont")

library("extrafont")

# Import system fonts - may take a while, so DO NOT run this during the workshop.
#font_import() 
fonts() # See what font families are available to you now.

#The next step is to register the fonts in the afm table with R's PDF (or PostScript) output device. This is needed to create PDF files with the fonts. As of extrafont version 0.13, this must be run only in the first session when you import your fonts. In sessions started after the fonts have been imported, simply loading the package with library(extrafont) this step isn't necessary, since it will automatically register the fonts with R.
# Only necessary in session where you ran font_import()
loadfonts()
# For PostScript output, use loadfonts(device="postscript")
# Suppress output with loadfonts(quiet=TRUE)

# Now you should be able to do  this:
plot(x=10:1, y=10:1, pch=19, cex=6, main="This is a plot", 
     col="orange", family="DejaVu Serif" )

# To embed the fonts & use them in PDF files:
# The command 'pdf' will send all the plots we output before dev.off() to a pdf file: 
pdf(file="DejaVuSerif.pdf")

plot(x=10:1, y=10:1, pch=19, cex=6, main="This is a plot", 
     col="orange", family="DejaVu Serif" )

dev.off()

detach("package:extrafont")

# ================ 2. Reading in the network data ================

# Clear your workspace by removing all objects returned by ls():
rm(list = ls()) 

# --DATASET 1: edgelist--

nodes <- read.csv("./Data files/Dataset1-Media-Example-NODES.csv", header=T, as.is=T)
links <- read.csv("./Data files/Dataset1-Media-Example-EDGES.csv", header=T, as.is=T)

# Examine the data:
head(nodes)
head(links)

nrow(nodes); length(unique(nodes$id))
nrow(links); nrow(unique(links[,c("from", "to")]))
nrow(unique(links[,c("from", "to", "type")]))

# Collapse multiple links of the same type between the same two nodes
# by summing their weights, using aggregate() by "from", "to", & "type":
links <- aggregate(links[,3], links[,-3], sum)
links <- links[order(links$from, links$to),]
colnames(links)[4] <- "weight"
rownames(links) <- NULL

nrow(links); nrow(unique(links[,c("from", "to")]))

# --DATASET 2: matrix--

nodes2 <- read.csv("./Data files/Dataset2-Media-User-Example-NODES.csv", header=T, as.is=T)
links2 <- read.csv("./Data files/Dataset2-Media-User-Example-EDGES.csv", header=T, row.names=1)

# Examine the data:
head(nodes2)
head(links2)

# links2 is a matrix for a two-mode network:
links2 <- as.matrix(links2)
dim(links2)
dim(nodes2)

# ================ 3. Plotting networks with igraph ================


#  ------->> Turning networks into igraph objects  --------

library("igraph")

# DATASET 1 

# Converting the data to an igraph object:
# The graph_from_data_frame() function takes two data frames: 'd' and 'vertices'.
# 'd' describes the edges of the network - it should start with two columns 
# containing the source and target node IDs for each network tie.
# 'vertices' should start with a column of node IDs.
# Any additional columns in either data frame are interpreted as attributes.

net <- graph_from_data_frame(d=links, vertices=nodes, directed=T) 