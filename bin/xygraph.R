#! /usr/bin/env Rscript

library(optparse)
library(ggplot2)

############################################################################################
## OPTPARSE
############################################################################################
Option_list <- list(
	make_option(c("-d", "--data_file"), type = 'character',
		help = "Tabulated file with the information about the comparison between disease profiles"),
	make_option(c("-o", "--output_file"), type = 'character', default= 'results',
		help = "Output graph file name"),
	make_option(c("-x", "--x_column"), type="integer", 
		help="Number of column to be used for X dimension"),
	make_option(c("-y", "--y_column"), type="integer", 
		help="Number of column to be used for Y dimension")

)

opt <- parse_args(OptionParser(option_list = Option_list))

############################################################################################
## MAIN
############################################################################################
data <- read.table(opt$data_file, sep="\t", header=TRUE)

pdf(paste(opt$output, '.pdf', sep=""))
	ggplot(data, aes(x=data[[opt$x_column]], y=data[[opt$y_column]])) +
 		geom_point(shape=1, alpha=0.5) +
		xlab("Profiles A phenotype match percentages") +
		ylab("Profiles B phenotype match percentages")
dev.off()