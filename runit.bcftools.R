if (! "RUnit" %in% row.names(installed.packages()))
  install.packages("RUnit")
  
library('RUnit')

source('bcftools.R')

test.bcftools.roh.buildparams.empty <- function() {
	checkException(bcftools.roh.buildparams(NULL))
}
test.bcftools.roh.buildparams.all <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"

	params <- bcftools.roh.buildparams(
		task,
		1.0, 2.0,
		TRUE, TRUE, 
		3.0,

		0.4, 0.5,
		0.6
	)

	print(params)

	checkEquals(
		params,
		"roh test1.test2.vcf.gz --AF-dflt 1 --GTs-only 2 --ignore-homref --skip-indels --rec-rate 3 --hw-to-az 0.4 --az-to-hw 0.5 --viterbi-training 0.6"
	)
}
test.bcftools.roh.buildparams.default <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"
	task$sample <- "HG00096"
	task$chromosomes <- list()
	task$chromosomes$chromosome <- 1
	task$chromosomes$region <- list()
	task$chromosomes$region$begin <- 234
	task$chromosomes$region$end <- 4567

	params <- bcftools.roh.buildparams(task)

	checkEquals(
		params,
		"roh test1.test2.vcf.gz -s HG00096 -r 1:234-4567 --AF-dflt 0.4 --GTs-only 30"
	)
}