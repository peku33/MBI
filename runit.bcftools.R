if (! "RUnit" %in% row.names(installed.packages()))
  install.packages("RUnit")
  
library('RUnit')

source('bcftools.R')

test.bcftools.roh.buildparams.empty <- function() {
	checkException(bcftools.roh.buildparams(NULL))
}
test.bcftools.roh.buildparams.all <- function() {

	vcf_file_name <- "test1.test2.vcf.gz"

	params <- bcftools.roh.buildparams(
		vcf_file_name,
		1.0, 2.0,
		TRUE, TRUE, 
		3.0,

		0.4, 0.5,
		0.6
	)

	checkEquals(
		params,
		"roh test1.test2.vcf.gz --AF-dflt 1 --GTs-only 2 --ignore-homref --skip-indels --rec-rate 3 --hw-to-az 0.4 --az-to-hw 0.5 --viterbi-training 0.6"
	)
}