source('roh.R')

source('bcftools.R')
source('plink.R')

# Zawartość usage-example można pobrać z http://samtools.github.io/bcftools/howtos/roh-calling.html

task <- list()
task$vcf_file_name <- "./usage-example/test.vcf.gz"

bcftools.params <- bcftools.roh.buildparams(task)
bcftools.output <- bcftools.roh.run(bcftools.params)
print(bcftools.output)

plink.params <- plink.roh.buildparams(task)
plink.output <- plink.roh.run(plink.params)
print(plink.output)
