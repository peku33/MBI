library('RUnit')

source('plink.R')

test.plink.roh.buildparams.empty <- function() {
	checkException(plink.roh.buildparams(NULL))
}
test.plink.roh.buildparams.1 <- function() {

	vcf_file_name <- "test1.test2.vcf.gz"

	params <- plink.roh.buildparams(
		vcf_file_name,
		1, 2, 3, 4, 5,
		6, 7, 8, 9,
		10
	)

	checkEquals(
		params,
		"--vcf test1.test2.vcf.gz --homozyg --homozyg-snp 1 --homozyg-kb 2 --homozyg-density 3 --homozyg-gap 4 --homozyg-het 5 --homozyg-window-snp 6 --homozyg-window-het 7 --homozyg-window-missing 8 --homozyg-window-threshold 9 --homozyg-match 10"
	)
}