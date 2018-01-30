library('RUnit')

source('vcfr.R')

test.vcfr.baf.from.genotype.bad <- function() {
	checkException(vcfr.baf.from.genotype())
	checkException(vcfr.baf.from.genotype(0, 0, 0))
	checkException(vcfr.baf.from.genotype("", ""))
	checkException(vcfr.baf.from.genotype("a", "b"))
}

test.vcfr.baf.from.genotype.good <- function() {
	checkEquals(vcfr.baf.from.genotype(0, 0), 0.0)
	checkEquals(vcfr.baf.from.genotype(0, 1), 0.5)
	checkEquals(vcfr.baf.from.genotype(1, 1), 1.0)
}

test.vcfr.baf.from.genotypes.bad <- function() {
	checkException(vcfr.baf.from.genotypes(c("a")))
	checkException(vcfr.baf.from.genotypes(c("")))
	checkException(vcfr.baf.from.genotypes(c("0|")))
	checkException(vcfr.baf.from.genotypes(c("|0")))
	checkException(vcfr.baf.from.genotypes(c("a|0")))
	checkException(vcfr.baf.from.genotypes(c("0|b")))
	checkException(vcfr.baf.from.genotypes(c("1")))
}
test.vcfr.baf.from.genotypes.good <- function() {
	checkEquals(vcfr.baf.from.genotypes(c()), c())
	checkEquals(vcfr.baf.from.genotypes(c("0|0", "0\\0", "0/0")), c(0.0, 0.0, 0.0))
	checkEquals(vcfr.baf.from.genotypes(c("0|1", "0\\1", "0/1")), c(0.5, 0.5, 0.5))
	checkEquals(vcfr.baf.from.genotypes(c("1|1", "1\\1", "1/1")), c(1.0, 1.0, 1.0))
}