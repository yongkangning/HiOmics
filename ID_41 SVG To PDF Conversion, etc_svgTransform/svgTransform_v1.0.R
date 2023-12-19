

args = commandArgs(trailingOnly=TRUE)
argsCount = 2
if (length(args) != argsCount) {
  stop("svgTransform.R inputFile outputFile")
}

library(rsvg)
inputFile <- args[1]
outputFile <- args[2]
rsvg_pdf(inputFile,outputFile)
