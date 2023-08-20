## ----OPTIONS,cache=FALSE,echo=FALSE,results='hide',message=FALSE,warning=FALSE----
require(knitr)
opts_chunk$set(concordance=TRUE, 
               echo=FALSE,
               autodep=TRUE,
               tidy=FALSE,
               cache=TRUE, 
               message=FALSE, 
               warning=FALSE,
               results='hide',
               size='scriptsize',
               comment=NA, 
               out.width='.75\\textwidth',
               fig.show='hold')

## Do not cache reading of libraries or options - these are one 
## of the few things that cannot be cached!
library(np)
options(np.messages=FALSE,crs.messages=FALSE)
library(maps)
library(mapdata)
load("data.RData")

## ----out.width='.5\\textwidth'-------------------------------------------
foo <- read.table("Data/npcdist/leg1_sanae50.dat",header=TRUE)
attach(foo)
plot(CO2f~Chl,
     ylab="Mean fCO2",
     xlab="Chlorophyll-a",
     type="b")


## ------------------------------------------------------------------------
lon.adjust <- 1
foo.leg1.50$Lon <- foo.leg1.50$Lon
foo.leg1.51$Lon <- foo.leg1.51$Lon-lon.adjust
foo.leg1.52$Lon <- foo.leg1.52$Lon+lon.adjust
foo.leg1.53$Lon <- foo.leg1.53$Lon-2*lon.adjust
foo.leg1.54$Lon <- foo.leg1.54$Lon+2*lon.adjust

foo <- rbind(foo.leg1.50,
             foo.leg1.51,
             foo.leg1.52,
             foo.leg1.53,
             foo.leg1.54)

foo <- na.omit(subset(foo,CruiseLeg==1))

## Note - we use the entire pooled sample for computing the color
## palatte here, so all is good.

z <- foo$Chl_conc
z.main <- "Chlorophyll-a Leg 1"

map(database = 'world',
    regions = c("antarctica","south africa"),
    xlim = c(-30, 40), ## longitude
    ylim = c(-75, -25), ## latitude
    fill = T,
    col = 'lightgrey',
    resolution = 0,
    bg = 'white')

box()

## Scalebar

## colorRampPalette returns a function that takes an integer argument
## (the required number of colors, here num.color) and returns a
## character vector of colors (see rgb) interpolating the given
## sequence

num.colors <- 10
color.pal <- c('black','lightblue','yellow','green')
zcol <- colorRampPalette(colors=color.pal,interpolate="spline")(num.colors)[as.numeric(cut(z, breaks = quantile(z,seq(0,1,length=num.colors)), include.lowest=TRUE))]

pch.ctr <- 21
Trip <- sort(unique(foo$Trip))

for(t in Trip) {
    points(foo$Lon[foo$Trip==t],
           foo$Lat[foo$Trip==t],
           bg = zcol[foo$Trip==t],
           pch = pch.ctr,
           cex = .5,
           col = NA)
    pch.ctr <- pch.ctr+1
}

legend("topleft",Trip,pch=21:25,bty="n",cex=.5)

axis(1, labels = T)
axis(2, labels = T)
grid()

title(xlab = 'Longitude',
      ylab = 'Latitude',
      main = z.main)

## set the location and the colorbar gradation
xleft <- -20
xright <- -15
yint <- (65 - 50) / num.colors
ybot <- -65 - yint
ytop <- ybot + yint

## create the bar by stacking a bunch of colored rectangles
for(c in  colorRampPalette(colors=color.pal)(num.colors)){
  ybot = ybot + yint
  ytop = ytop + yint
  rect(xleft, ybot, xright, ytop, border = NA, col = c)
}

## generate labels

label.length <- 11 ## deciles

labels <- formatC(quantile(z,seq(0,1,length=label.length)),format="f",digits=2)

## add the labels to the plot
text(c(xleft - 0.2),
     seq(-65, -50, length.out = label.length),
     labels = as.character(labels),
     cex = 0.8,
     pos = 2)

## ------------------------------------------------------------------------
###############################################################################

z <- foo$CO2f_sst
z.main <- "fCO2 Leg 1"

map(database = 'world',
    regions = c("antarctica","south africa"),
    xlim = c(-30, 40), ## longitude
    ylim = c(-75, -25), ## latitude
    fill = T,
    col = 'lightgrey',
    resolution = 0,
    bg = 'white')

box()

## Scalebar

## colorRampPalette returns a function that takes an integer argument
## (the required number of colors, here num.color) and returns a
## character vector of colors (see rgb) interpolating the given
## sequence

color.pal <- c('black','lightblue','yellow','purple')
zcol <- colorRampPalette(colors=color.pal,interpolate="spline")(num.colors)[as.numeric(cut(z, breaks = quantile(z,seq(0,1,length=num.colors)), include.lowest=TRUE))]

pch.ctr <- 21
Trip <- sort(unique(foo$Trip))

for(t in Trip) {
    points(foo$Lon[foo$Trip==t],
           foo$Lat[foo$Trip==t],
           bg = zcol[foo$Trip==t],
           pch = pch.ctr,
           cex = .5,
           col = NA)
    pch.ctr <- pch.ctr+1
}

legend("topleft",Trip,pch=21:25,bty="n",cex=.5)

axis(1, labels = T)
axis(2, labels = T)
grid()

title(xlab = 'Longitude',
      ylab = 'Latitude',
      main = z.main)

## set the location and the colorbar gradation
xleft <- -20
xright <- -15
yint <- (65 - 50) / num.colors
ybot <- -65 - yint
ytop <- ybot + yint

## create the bar by stacking a bunch of colored rectangles
for(c in  colorRampPalette(colors=color.pal)(num.colors)){
  ybot = ybot + yint
  ytop = ytop + yint
  rect(xleft, ybot, xright, ytop, border = NA, col = c)
}

## generate labels

label.length <- 11 ## deciles

labels <- formatC(quantile(z,seq(0,1,length=label.length)),format="f",digits=2)

## add the labels to the plot
text(c(xleft - 0.2),
     seq(-65, -50, length.out = label.length),
     labels = as.character(labels),
     cex = 0.8,
     pos = 2)


## ------------------------------------------------------------------------
###############################################################################

z <- foo$Salt_tsg
z.main <- "Salinity Leg 1"

map(database = 'world',
    regions = c("antarctica","south africa"),
    xlim = c(-30, 40), ## longitude
    ylim = c(-75, -25), ## latitude
    fill = T,
    col = 'lightgrey',
    resolution = 0,
    bg = 'white')

box()

## Scalebar

## colorRampPalette returns a function that takes an integer argument
## (the required number of colors, here num.color) and returns a
## character vector of colors (see rgb) interpolating the given
## sequence

color.pal <- c('black','lightblue','yellow','orange')
zcol <- colorRampPalette(colors=color.pal,interpolate="spline")(num.colors)[as.numeric(cut(z, breaks = quantile(z,seq(0,1,length=num.colors)), include.lowest=TRUE))]

pch.ctr <- 21
Trip <- sort(unique(foo$Trip))

for(t in Trip) {
    points(foo$Lon[foo$Trip==t],
           foo$Lat[foo$Trip==t],
           bg = zcol[foo$Trip==t],
           pch = pch.ctr,
           cex = .5,
           col = NA)
    pch.ctr <- pch.ctr+1
}

legend("topleft",Trip,pch=21:25,bty="n",cex=.5)

axis(1, labels = T)
axis(2, labels = T)
grid()

title(xlab = 'Longitude',
      ylab = 'Latitude',
      main = z.main)

## set the location and the colorbar gradation
xleft <- -20
xright <- -15
yint <- (65 - 50) / num.colors
ybot <- -65 - yint
ytop <- ybot + yint

## create the bar by stacking a bunch of colored rectangles
for(c in  colorRampPalette(colors=color.pal)(num.colors)){
  ybot = ybot + yint
  ytop = ytop + yint
  rect(xleft, ybot, xright, ytop, border = NA, col = c)
}

## generate labels

label.length <- 11 ## deciles

labels <- formatC(quantile(z,seq(0,1,length=label.length)),format="f",digits=2)

## add the labels to the plot
text(c(xleft - 0.2),
     seq(-65, -50, length.out = label.length),
     labels = as.character(labels),
     cex = 0.8,
     pos = 2)


## ------------------------------------------------------------------------
###############################################################################

z <- foo$Temp_intake
z.main <- "Temperature Leg 1"

map(database = 'world',
    regions = c("antarctica","south africa"),
    xlim = c(-30, 40), ## longitude
    ylim = c(-75, -25), ## latitude
    fill = T,
    col = 'lightgrey',
    resolution = 0,
    bg = 'white')

box()

## Scalebar

## colorRampPalette returns a function that takes an integer argument
## (the required number of colors, here num.color) and returns a
## character vector of colors (see rgb) interpolating the given
## sequence

color.pal <- c('black','lightblue','yellow','red')
zcol <- colorRampPalette(colors=color.pal,interpolate="spline")(num.colors)[as.numeric(cut(z, breaks = quantile(z,seq(0,1,length=num.colors)), include.lowest=TRUE))]

pch.ctr <- 21
Trip <- sort(unique(foo$Trip))

for(t in Trip) {
    points(foo$Lon[foo$Trip==t],
           foo$Lat[foo$Trip==t],
           bg = zcol[foo$Trip==t],
           pch = pch.ctr,
           cex = .5,
           col = NA)
    pch.ctr <- pch.ctr+1
}

legend("topleft",Trip,pch=21:25,bty="n",cex=.5)

axis(1, labels = T)
axis(2, labels = T)
grid()

title(xlab = 'Longitude',
      ylab = 'Latitude',
      main = z.main)

## set the location and the colorbar gradation
xleft <- -20
xright <- -15
yint <- (65 - 50) / num.colors
ybot <- -65 - yint
ytop <- ybot + yint

## create the bar by stacking a bunch of colored rectangles
for(c in  colorRampPalette(colors=color.pal)(num.colors)){
  ybot = ybot + yint
  ytop = ytop + yint
  rect(xleft, ybot, xright, ytop, border = NA, col = c)
}

## generate labels

label.length <- 11 ## deciles

labels <- formatC(quantile(z,seq(0,1,length=label.length)),format="f",digits=2)

## add the labels to the plot
text(c(xleft - 0.2),
     seq(-65, -50, length.out = label.length),
     labels = as.character(labels),
     cex = 0.8,
     pos = 2)


## ------------------------------------------------------------------------
###############################################################################

z <- foo$MLD
z.main <- "MLD Leg 1"

map(database = 'world',
    regions = c("antarctica","south africa"),
    xlim = c(-30, 40), ## longitude
    ylim = c(-75, -25), ## latitude
    fill = T,
    col = 'lightgrey',
    resolution = 0,
    bg = 'white')

box()

## Scalebar

## colorRampPalette returns a function that takes an integer argument
## (the required number of colors, here num.color) and returns a
## character vector of colors (see rgb) interpolating the given
## sequence

color.pal <- c('black','lightblue','yellow','maroon')
zcol <- colorRampPalette(colors=color.pal,interpolate="spline")(num.colors)[as.numeric(cut(z, breaks = quantile(z,seq(0,1,length=num.colors)), include.lowest=TRUE))]

pch.ctr <- 21
Trip <- sort(unique(foo$Trip))

for(t in Trip) {
    points(foo$Lon[foo$Trip==t],
           foo$Lat[foo$Trip==t],
           bg = zcol[foo$Trip==t],
           pch = pch.ctr,
           cex = .5,
           col = NA)
    pch.ctr <- pch.ctr+1
}

legend("topleft",Trip,pch=21:25,bty="n",cex=.5)

axis(1, labels = T)
axis(2, labels = T)
grid()

title(xlab = 'Longitude',
      ylab = 'Latitude',
      main = z.main)

## set the location and the colorbar gradation
xleft <- -20
xright <- -15
yint <- (65 - 50) / num.colors
ybot <- -65 - yint
ytop <- ybot + yint

## create the bar by stacking a bunch of colored rectangles
for(c in  colorRampPalette(colors=color.pal)(num.colors)){
  ybot = ybot + yint
  ytop = ytop + yint
  rect(xleft, ybot, xright, ytop, border = NA, col = c)
}

## generate labels

label.length <- 11 ## deciles

labels <- formatC(quantile(z,seq(0,1,length=label.length)),format="f",digits=2)

## add the labels to the plot
text(c(xleft - 0.2),
     seq(-65, -50, length.out = label.length),
     labels = as.character(labels),
     cex = 0.8,
     pos = 2)

dev.off()

