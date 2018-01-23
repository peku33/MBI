library('RUnit')

source('plink.R')

test.plink.roh.buildparams.empty <- function() {
	checkException(plink.roh.buildparams(NULL))
}
test.plink.roh.buildparams.1 <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"
	task$chromosomes <- list()
	task$chromosomes$chromosome <- 1

	params <- plink.roh.buildparams(task)

	checkEquals(
		params,
		"--vcf test1.test2.vcf.gz --chr 1 --homozyg"
	)
}
test.plink.roh.buildparams.2 <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"
	task$chromosomes <- list()
	task$chromosomes$chromosome <- 1
	task$chromosomes$region <- list()
	task$chromosomes$region$begin <- 234
	task$chromosomes$region$end <- 4567

	params <- plink.roh.buildparams(task)

	checkEquals(
		params,
		"--vcf test1.test2.vcf.gz --chr 1:234-4567 --homozyg"
	)
}
test.plink.roh.buildparams.3 <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"
	task$chromosomes <- list()
	task$chromosomes$region <- list()
	task$chromosomes$region$begin <- 1234
	task$chromosomes$region$end <- 45678

	params <- plink.roh.buildparams(task)

	checkEquals(
		params,
		"--vcf test1.test2.vcf.gz --chr 1234-45678 --homozyg"
	)
}
test.plink.roh.buildparams.4 <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"
	task$sample <- "HG00096"

	checkException(plink.roh.buildparams(task))
}
test.plink.roh.buildparams.5 <- function() {

	task <- list()
	task$vcf_file_name <- "test1.test2.vcf.gz"

	params <- plink.roh.buildparams(
		task,
		1, 2, 3, 4, 5,
		6, 7, 8, 9,
		10
	)

	checkEquals(
		params,
		"--vcf test1.test2.vcf.gz --homozyg --homozyg-snp 1 --homozyg-kb 2 --homozyg-density 3 --homozyg-gap 4 --homozyg-het 5 --homozyg-window-snp 6 --homozyg-window-het 7 --homozyg-window-missing 8 --homozyg-window-threshold 9 --homozyg-match 10"
	)
}