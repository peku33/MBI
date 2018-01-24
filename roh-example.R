source('roh.R')

source('bcftools.R')
source('plink.R')

# Zawartość usage-example można pobrać z http://samtools.github.io/bcftools/howtos/roh-calling.html

task <- list()
task$vcf_file_name <- "./usage-example/test.vcf.gz"

bcftools.params <- bcftools.roh.buildparams(task)
print(bcftools.roh.run(bcftools.params))

plink.params <- plink.roh.buildparams(task)
print(plink.roh.run(plink.params))
