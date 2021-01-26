#! /usr/bin/env Rscript

library(optparse)
library(BSgenome)
library(SNPlocs.Hsapiens.dbSNP151.GRCh38)

############################################################################################
## OPTPARSE
############################################################################################
Option_list <- list(
	make_option(c("-i", "--input_file"), type = 'character',
		help = "File containing a list of dbSNP:rs ids"),
	make_option(c("-o", "--output_file"), type = 'character', default= 'id2pos_table_results.txt',
		help = "Output file name, will contain the chromosome location of the snp IDs")
)

opt <- parse_args(OptionParser(option_list = Option_list))

############################################################################################
## MAIN
############################################################################################
snps = SNPlocs.Hsapiens.dbSNP151.GRCh38
dbsnp_ids = as.vector(read.table(opt$input_file)$V1)
my_rsids = sub('.*:', "", dbsnp_ids)

ids2pos_table = snpsById(snps, my_rsids, ifnotfound = "drop")
write.table(ids2pos_table, opt$output_file, sep = "\t", row.names = FALSE)
