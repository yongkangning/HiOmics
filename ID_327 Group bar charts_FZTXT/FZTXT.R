
args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("FZTXT.R libPath inputFile outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]#



outputFileName <- args[3]##
if (is.na(outputFileName)) {
  outputFileName <- "FZTXT"
}

library(ggplot2)
library(tidyverse)
filename = inputFile

  file_suffix <- strsplit(filename, "\\.")[[1]]
  filetype <- file_suffix[length(file_suffix)]
  
  encode <-
    guess_encoding(filename, n_max = 1000)[1, 1, drop = TRUE]
  # print(encode)
  if(is.na(encode)) {
    stop(paste("[ERRO]", filename,"encoding_nonsupport"))
  }
  if(filetype %in% c("csv","txt")){
  
read_data <- function(filename, has_header,has_rownames) {
 
    if (filetype == "csv") {
    df <-
      tryCatch(
        read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep=",",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.csv(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep=",",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  } else if (filetype == "txt") {
    df <-
      tryCatch(
        read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = encode,sep="\t",check.names=FALSE,fill=TRUE, na.string = ""),
        warning = function(e) {
          read.table(filename, header = has_header, row.names =has_rownames, fileEncoding = "UTF-8-BOM",sep="\t",check.names=FALSE,fill=TRUE, na.string = "")
        }
      )
  }  else {
    stop("[ERRO] Only support txt csv xls xlsx")
  }
  return(df)
    
}
data = read_data(file = filename,has_header = T,has_rownames=1)

}else if (filetype %in% c("xls", "xlsx")) {

read_data <- function(filename, has_header) {
if(filetype %in% c("xls", "xlsx")){
    df <- readxl::read_excel(filename,col_names=has_header)
	
  } else {
  stop("[ERRO] Only support txt csv xls xlsx")}
  }

  
  data = read_data(file = filename,has_header = T)
  data =as.data.frame(data)
  
  }




#data <- data.frame(
#  individual=paste( "Mister ", seq(1,60), sep=""),
#  group=c( rep('A', 10), rep('B', 30), rep('C', 14), rep('D', 6)) ,
#  value=sample( seq(10,100), 60, replace=T)
#)

#head(data)
##   individual group value
## 1   Mister 1     A    59
## 2   Mister 2     A    31
## 3   Mister 3     A    64
## 4   Mister 4     A    34
## 5   Mister 5     A    23
## 6   Mister 6     A    48


# Set a number of 'empty bar' to add at the end of each group
empty_bar <- 4
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$group <- rep(levels(data$group), each=empty_bar)
data <- rbind(data, to_add)
data <- data %>% arrange(group)
data$id <- seq(1, nrow(data))
#head(data)
##   individual group value id
## 1   Mister 1     A    59  1
## 2   Mister 2     A    31  2
## 3   Mister 3     A    64  3
## 4   Mister 4     A    34  4
## 5   Mister 5     A    23  5
## 6   Mister 6     A    48  6


# Get the name and the y position of each label
label_data <- data
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)
#head(label_data)
##   individual group value id hjust    angle
## 1   Mister 1     A    59  1     0 87.63158
## 2   Mister 2     A    31  2     0 82.89474
## 3   Mister 3     A    64  3     0 78.15789
## 4   Mister 4     A    34  4     0 73.42105
## 5   Mister 5     A    23  5     0 68.68421
## 6   Mister 6     A    48  6     0 63.94737


#p <- ggplot(data, aes(x=as.factor(id), y=value, fill=group)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
#  geom_bar(stat="identity", alpha=0.5) +
#  ylim(-100,120) +
#  theme_minimal() +
#  theme(
#    legend.position = "none",
#    axis.text = element_blank(),
#    axis.title = element_blank(),
#    panel.grid = element_blank(),
#    plot.margin = unit(rep(-1,4), "cm") 
#  ) +
#  coord_polar() + 
#  geom_text(data=label_data, aes(x=id, y=value+10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) 
#p



# Order data:
data = data %>% arrange(group, value)
data$id <- seq(1, nrow(data))
#head(data)
##   individual group value id
## 1   Mister 5     A    23  1
## 2   Mister 8     A    25  2
## 3   Mister 2     A    31  3
## 4   Mister 4     A    34  4
## 5   Mister 6     A    48  5
## 6   Mister 1     A    59  6


# Get the name and the y position of each label
label_data <- data
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)
#head(label_data)
##   individual group value id hjust    angle
## 1   Mister 5     A    23  1     0 87.63158
## 2   Mister 8     A    25  2     0 82.89474
## 3   Mister 2     A    31  3     0 78.15789
## 4   Mister 4     A    34  4     0 73.42105
## 5   Mister 6     A    48  5     0 68.68421
## 6   Mister 1     A    59  6     0 63.94737




p <- ggplot(data, aes(x=as.factor(id), y=value, fill=group)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  geom_bar(stat="identity", alpha=0.5) +
  ylim(-100,120) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  coord_polar() + 
  geom_text(data=label_data, aes(x=id, y=value+10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) 
p



#data <- data.frame(
#  individual=paste( "Mister ", seq(1,60), sep=""),
#  group=c( rep('A', 10), rep('B', 30), rep('C', 14), rep('D', 6)) ,
#  value=sample( seq(10,100), 60, replace=T)
#)

#head(data)
##   individual group value
## 1   Mister 1     A    98
## 2   Mister 2     A    29
## 3   Mister 3     A    12
## 4   Mister 4     A    10
## 5   Mister 5     A    94
## 6   Mister 6     A    57


# Set a number of 'empty bar' to add at the end of each group
empty_bar <- 2
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$group <- rep(levels(data$group), each=empty_bar)
data <- rbind(data, to_add)
data <- data %>% arrange(group)
data$id <- seq(1, nrow(data))
#head(data)
##   individual group value id
## 1   Mister 1     A    98  1
## 2   Mister 2     A    29  2
## 3   Mister 3     A    12  3
## 4   Mister 4     A    10  4
## 5   Mister 5     A    94  5
## 6   Mister 6     A    57  6


# Get the name and the y position of each label
label_data <- data
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)
#head(label_data)
##   individual group value id hjust    angle
## 1   Mister 1     A    98  1     0 87.35294
## 2   Mister 2     A    29  2     0 82.05882
## 3   Mister 3     A    12  3     0 76.76471
## 4   Mister 4     A    10  4     0 71.47059
## 5   Mister 5     A    94  5     0 66.17647
## 6   Mister 6     A    57  6     0 60.88235

# prepare a data frame for base lines
base_data <- data %>% 
  group_by(group) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))
#head(base_data)
## # A tibble: 4 x 4
## # Rowwise: 
##   group start   end title
##   <fct> <int> <dbl> <dbl>
## 1 A         1    10   5.5
## 2 B        13    42  27.5
## 3 C        45    58  51.5
## 4 D        61    66  63.5

# prepare a data frame for grid (scales)
grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]
#head(grid_data)
## # A tibble: 3 x 4
## # Rowwise: 
##   group start   end title
##   <fct> <dbl> <dbl> <dbl>
## 1 B        12    11  27.5
## 2 C        44    43  51.5
## 3 D        60    59  63.5

# Make the plot

p1 <- ggplot(data, aes(x=as.factor(id), y=value, fill=group)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  
  geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
  ylim(-50,max(na.omit(data$value))+30) +
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 80, xend = start, yend = 80), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 60, xend = start, yend = 60), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 40, xend = start, yend = 40), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  
  # Add text showing the value of each 100/75/50/25 lines
  annotate("text", x = rep(max(data$id),4), y = c(20, 40, 60, 80), label = c("20", "40", "60", "80") , color="grey", size=3 , angle=0, fontface="bold", hjust=1) +
  
  theme_minimal() +
  theme(
    #legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  coord_polar() + 

  geom_text(data=label_data, aes(x=id, y=value+8, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
  geom_text(data=label_data, aes(x=id, y=value-10, label=value, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  
  geom_segment(data=base_data, aes(x = start, y = -5, xend = end, yend = -5), colour = "black", alpha=0.8, size=0.8 , inherit.aes = FALSE )  +

  geom_text(data=base_data, aes(x = title, y = -12, label=group), colour = "black", alpha=0.8, size=4, fontface="bold", inherit.aes = FALSE) +

  scale_fill_brewer(palette = "Set2")
p1


ggsave(plot = p1,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=15,dpi=600)