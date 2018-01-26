source('roh.R')

source('bcftools.R')
source('plink.R')
source('samtools.R')
source('subsetter.R')

# Zawartość usage-example można pobrać z http://samtools.github.io/bcftools/howtos/roh-calling.html

task <- list()
#task$vcf_file_name <- "./ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz"
task$vcf_file_name <- "./usage-example/test.vcf.gz"
# task$sample <- 'HG00096'
task$chromosomes <- list()
task$chromosomes$chromosome = 1
task$chromosomes$region <- list()
task$chromosomes$region$begin = 10000000
task$chromosomes$region$end = 20000000

print("== subsetter.prepare ==")
subsetter.prepare.result <- subsetter.prepare(task)

# BCFTools ROH
print("== BCFTools ROH ==")
bcftools.roh.params <- bcftools.roh.buildparams(subsetter.prepare.result)
print(bcftools.roh.params)
bcftools.roh.output <- bcftools.roh.run(bcftools.roh.params)
# print(bcftools.roh.output)

# Plink ROH
print("== Plink ROH ==")
plink.roh.params <- plink.roh.buildparams(subsetter.prepare.result)
print(plink.roh.params)
plink.roh.output <- plink.roh.run(plink.roh.params)
# print(plink.roh.output)

print("== subsetter.cleanup ==")
subsetter.cleanup(subsetter.prepare.result)

print(sum(bcftools.roh.output$homozygosity))
print(sum(plink.roh.output$homozygosity))

bitmap(file = "roh-example.bmp")
plot(bcftools.roh.output$position, bcftools.roh.output$homozygosity)
plot(plink.roh.output$position, plink.roh.output$homozygosity)
dev.off()