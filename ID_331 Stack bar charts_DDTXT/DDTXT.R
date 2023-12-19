
args = commandArgs(trailingOnly=TRUE)
argsCount = 3

if (length(args)!=argsCount) {
  stop("DDTXT.R libPath inputFile outputFileName")
}
.libPaths(args[1])
inputFile <- args[2]#



outputFileName <- args[3]##
if (is.na(outputFileName)) {
  outputFileName <- "DDTXT"
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
#  value1=sample( seq(10,100), 60, replace=T),
#  value2=sample( seq(10,100), 60, replace=T),
#  value3=sample( seq(10,100), 60, replace=T)
#)
#head(data)
##   individual group value1 value2 value3
## 1   Mister 1     A     41     50     25
## 2   Mister 2     A     81     33     92
## 3   Mister 3     A     81     55     50
## 4   Mister 4     A     94     37     98
## 5   Mister 5     A     12     46     63
## 6   Mister 6     A     73     15     92


# Transform data in a tidy format (long format)
data <- data %>% gather(key = "observation", value="value", -c(1,2)) 
#head(data)
##   individual group observation value
## 1   Mister 1     A      value1    41
## 2   Mister 2     A      value1    81
## 3   Mister 3     A      value1    81
## 4   Mister 4     A      value1    94
## 5   Mister 5     A      value1    12
## 6   Mister 6     A      value1    73


# Set a number of 'empty bar' to add at the end of each group
empty_bar <- 2
nObsType <- nlevels(as.factor(data$observation))
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group)*nObsType, ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$group <- rep(levels(data$group), each=empty_bar*nObsType )
data <- rbind(data, to_add)
data <- data %>% arrange(group, individual)
data$id <- rep( seq(1, nrow(data)/nObsType) , each=nObsType)
#head(data)
##   individual group observation value id
## 1   Mister 1     A      value1    41  1
## 2   Mister 1     A      value2    50  1
## 3   Mister 1     A      value3    25  1
## 4  Mister 10     A      value1    90  2
## 5  Mister 10     A      value2    32  2
## 6  Mister 10     A      value3    39  2

# 
# Get the name and the y position of each label
label_data <- data %>% group_by(id, individual) %>% summarize(tot=sum(value))
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)
#head(label_data)
## # A tibble: 6 x 5
## # Groups:   id [6]
##      id individual   tot hjust angle
##   <int> <fct>      <int> <dbl> <dbl>
## 1     1 Mister 1     116     0  87.4
## 2     2 Mister 10    161     0  82.1
## 3     3 Mister 2     206     0  76.8
## 4     4 Mister 3     186     0  71.5
## 5     5 Mister 4     229     0  66.2
## 6     6 Mister 5     121     0  60.9

# prepare a data frame for base lines
base_data <- data %>% 
  group_by(group) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

# prepare a data frame for grid (scales)
grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

# Make the plot
p<- ggplot(data) +      
  
  # Add the stacked bar
  geom_bar(aes(x=as.factor(id), y=value, fill=observation), stat="identity", alpha=0.5) +
  scale_fill_brewer(palette = "Paired") +
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 0, xend = start, yend = 0), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 50, xend = start, yend = 50), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 100, xend = start, yend = 100), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 150, xend = start, yend = 150), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 200, xend = start, yend = 200), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  
  # Add text showing the value of each 100/75/50/25 
  ggplot2::annotate("text", x = rep(max(data$id),5), y = c(0, 50, 100, 150, 200), label = c("0", "50", "100", "150", "200") , color="grey", size=6 , angle=0, fontface="bold", hjust=1) +
  
  ylim(-150,max(label_data$tot, na.rm=T)) +
  theme_minimal() +
  theme(
    #legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  coord_polar() +
  
  # Add labels on top of each bar
  geom_text(data=label_data, aes(x=id, y=tot+10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=5, angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  geom_segment(data=base_data, aes(x = start, y = -5, xend = end, yend = -5), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
  geom_text(data=base_data, aes(x = title, y = -18, label=group), colour = "black", alpha=0.8, size=4, fontface="bold", inherit.aes = FALSE)
p


ggsave(plot = p,filename=paste(outputFileName,"svg",sep="."),device='svg',units="cm",width=20,height=20,dpi=600)