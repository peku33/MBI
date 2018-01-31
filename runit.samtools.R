library('RUnit')

source('samtools.R')

test.samtools.tabix.buildparams.invalid <- function() {
	checkException(samtools.tabix.buildparams(NULL))
}

test.samtools.tabix.buildparams.1 <- function() {
	checkEquals(
		"-h -p vcf test.vcf.gz",
		samtools.tabix.buildparams("test.vcf.gz"),
	)
}