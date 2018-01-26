source('roh.R')

source('bcftools.R')
source('samtools.R')

# Przygotowuje pliki do obróki
# Na podstawie task'a tworzy w tymczasowym katalogu obciete i zindeksowane pliki (.gz + .gz.tbi)
# Zwraca ścieżkę bazową do pliku .gz
subsetter.prepare <- function(task) {

	# Tymczasowy plik
	# print("== TEMP ==")
	file.name.base = tempfile()
	# print(file.name.base)

	# Wycięcię danych według task
	# print("== VIEW ==")
	bcftools.view.params <- bcftools.view.buildparams(task, file.name.base)
	# print(bcftools.view.params)
	bcftools.view.run(bcftools.view.params)

	# BGZip
	# print("== BGZIP ==")
	samtools.bgzip.run(file.name.base)
	file.name.base <- paste(file.name.base, ".gz", sep = "")

	# Tabix
	# print("== TABIX ==")
	samtools.tabix.params <- samtools.tabix.buildparams(file.name.base)
	# print(samtools.tabix.params)
	samtools.tabix.run(samtools.tabix.params)

	return(file.name.base)
}

# Czyści pozostałości po przygotowaniach
# Należy zawołać tę funkcję na końcu zabawy, podając jej na wejściu wynik subsetter.prepare()
subsetter.cleanup <- function(subsetter.prepare.result) {

	file.gz <- subsetter.prepare.result
	file.gz.tbi <- paste(file.gz, ".tbi", sep = "")

	if(!all(file.remove(file.gz, file.gz.tbi)))
		stop("!all(file.remove(file.gz, file.gz.tbi))")

	return(TRUE)
}