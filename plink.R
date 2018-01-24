source('roh.R')

plink.roh.executable <- "./plink_linux_x86_64/plink"

# Na podstawie https://www.cog-genomics.org/plink/1.9/ibd

# Buduje wiersz parametrów wywołania programu plink
#
# task - task (roh.R)
#
# Opcjonalnie:
# snp (int) - min SNP count
# kb (int) - min length
# density (int) - max inverse density (kb/SNP)
# gap (int) - max internal gap kb length
# het (int) - max hets
# window.snp (int) - scanning window size
# window.het (int) - max hets in scanning window hit
# window.missing (int) - max missing calls in scanning window hit
# window.threshold (int) - min scanning window hit rate
# match (int) - min overlap rate
plink.roh.buildparams <- function(
		task,
		snp = NULL, kb = NULL, density = NULL, gap = NULL, het = NULL,
		window.snp = NULL, window.het = NULL, window.missing = NULL, window.threshold = NULL,
		match = NULL
) {
	params <- ""

	if(is.null(task))
		stop("is.null(task)")

	# task$vcf_file_name
	params <- paste(params, "--vcf", sep = "") # Bez spacji
	params <- paste(params, task$vcf_file_name)

	# task$sample
	# TODO: Dodać filtrowanie po task$sample.
	# W plinku możliwe FID albo IID?
	if(!is.null(task$sample)) {
		stop("No support for sample filtering in plink. Sorry. Use filtered file and set task$sample to NULL")
	}

	# task$chromosomes
	task.chromosomes.string <- task.chromosomes.to.string(task$chromosomes)
	if(!is.null(task.chromosomes.string)) {
		params <- paste(params, "--chr")
		params <- paste(params, task.chromosomes.string)
	}

	# 
	params <- paste(params, "--homozyg")

	# snp
	if(!is.null(snp)) {
		params <- paste(params, "--homozyg-snp")
		params <- paste(params, snp)
	}

	# kb
	if(!is.null(kb)) {
		params <- paste(params, "--homozyg-kb")
		params <- paste(params, kb)
	}

	# density 
	if(!is.null(density)) {
		params <- paste(params, "--homozyg-density")
		params <- paste(params, density)
	}

	# gap
	if(!is.null(gap)) {
		params <- paste(params, "--homozyg-gap")
		params <- paste(params, gap)
	}

	# het
	if(!is.null(het)) {
		params <- paste(params, "--homozyg-het")
		params <- paste(params, het)
	}

	# window.snp
	if(!is.null(window.snp)) {
		params <- paste(params, "--homozyg-window-snp")
		params <- paste(params, window.snp)
	}

	# window.het
	if(!is.null(window.het)) {
		params <- paste(params, "--homozyg-window-het")
		params <- paste(params, window.het)
	}

	# window.missing
	if(!is.null(window.missing)) {
		params <- paste(params, "--homozyg-window-missing")
		params <- paste(params, window.missing)
	}

	# window.threshold
	if(!is.null(window.threshold)) {
		params <- paste(params, "--homozyg-window-threshold")
		params <- paste(params, window.threshold)
	}

	# match
	if(!is.null(match)) {
		params <- paste(params, "--homozyg-match")
		params <- paste(params, match)
	}

	return(params)
}


# Uruchamia plink roh o podanych parametrach
# Zwraca zawartość wyjściowego pliku, tymczasowe usuwa
plink.roh.run <- function(
	params
) {

	# W wyniku spodziewamy się powstania plików
	# .log - w zasadzie to co na wyjściu do konsoli
	# .hom - lista regionów z brakami heterozygotyczności dla wszystkich osobników
	# .hom.indiv - podsumowanie po jednym wersje dla osobnika
	# .hom.summary - pełna lista wszystkich regionów z zaznaczonymi elementami homo i hetero
	# .nosex - w zasadzie FID + IID

	# Losowa nazwa pliku
	file.name.base = tempfile()

	# Ścieżki spodziewanych wyjść
	file.name.log <- paste(file.name.base, ".log", sep = "")
	file.name.hom <- paste(file.name.base, ".hom", sep = "")
	file.name.hom.indiv <- paste(file.name.base, ".hom.indiv", sep = "")
	file.name.hom.summary <- paste(file.name.base, ".hom.summary", sep = "")
	file.name.nosex <- paste(file.name.base, ".nosex", sep = "")

	# Dodajemy ścieżkę bazową do polecenia
	params <- paste(params, "--out")
	params <- paste(params, file.name.base)

	# Uruchomienie plink, zgubienie wyjścia
	exit.code <- system2(
		plink.roh.executable, params,
		# "", "", # stdout + stderr do konsoli
		NULL, NULL, # stdout + stderr do kosza
	)

	if(exit.code != 0) {
		stop("exit.code")
	}

	# Sprawdzamy czy powstały wyjściowe pliki
	if(!all(file.exists(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))) {
		stop("!all(file.exists(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))")
	}

	# Procesujemy wyjście programu
	plink.roh.table <- read.table(file.name.hom, TRUE)
	regions <- plink.roh.table.to.regions(plink.roh.table)

	# Usuwamy wyjściowe pliki
	if(!all(file.remove(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))) {
		stop("!all(file.remove(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))")
	}

	return(regions)
}

# Zamienia tabelę roh odczytaną przez plink na format roh (roh.R)
plink.roh.table.to.regions <- function(table) {
	t <- table[c("POS1", "POS2")]
	colnames(t) <- c("begin", "end")
	return(t)
}