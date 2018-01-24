source('roh.R')

bcftools.roh.executable <- "./BCFtools/bcftools"

# Buduje wiersz polecenia do uruchomienia BCFTools ROH
#
# Wymagane:
# 	task (roh.R)
#
# Opcjonalne:
# 	af.default			--AF-dflt <float>					if AF is not known, use this allele frequency [skip]
#	pl.value			-G, --GTs-only <float>				use GTs and ignore PLs, instead using <float> for PL of the two least likely genotypes. Safe value to use is 30 to account for GT errors.
#	ignore.homref		-i, --ignore-homref 				skip hom-ref genotypes (0/0)
#	skip.indels			-I, --skip-indels					skip indels as their genotypes are enriched for errors
#	rec.rate			-M, --rec-rate <float>				constant recombination rate per bp
#
#	hw.to.az			-a, --hw-to-az <float>				P(AZ|HW) transition probability from HW (Hardy-Weinberg) to AZ (autozygous) state [6.7e-8]
#	az.to.hw			-H, --az-to-hw <float>				P(HW|AZ) transition probability from AZ to HW state [5e-9]
#	viterbi.training	-V, --viterbi-training <float>		estimate HMM parameters, <float> is the convergence threshold, e.g. 1e-10 (experimental)

bcftools.roh.buildparams <- function(
	task,
	af.default = 0.4, pl.value = 30.0,
	ignore.homref = FALSE, skip.indels = FALSE,
	rec.rate = NULL,

	hw.to.az = NULL, az.to.hw = NULL,
	viterbi.training = NULL
) {

	params <- "roh"

	if(is.null(task))
		stop("is.null(task)")

	# task$vcf_file_name
	params <- paste(params, task$vcf_file_name)

	# task$sample
	if(!is.null(task$sample)) {
		params <- paste(params, "-s")
		params <- paste(params, task$sample)
	}

	# task$chromosomes
	task.chromosomes.string <- task.chromosomes.to.string(task$chromosomes)
	if(!is.null(task.chromosomes.string)) {
		params <- paste(params, "-r")
		params <- paste(params, task.chromosomes.string)
	}


	# af.default
	if(!is.null(af.default)) {
		params <- paste(params, "--AF-dflt")
		params <- paste(params, af.default)
	}

	# pl.value
	if(!is.null(pl.value)) {
		params <- paste(params, "--GTs-only")
		params <- paste(params, pl.value)
	}

	# ignore.homref
	if(ignore.homref) {
		params <- paste(params, "--ignore-homref")
	}

	# skip.indels
	if(skip.indels) {
		params <- paste(params, "--skip-indels")
	}

	# rec.rate
	if(!is.null(rec.rate)) {
		params <- paste(params, "--rec-rate")
		params <- paste(params, rec.rate)
	}


	# hw.to.az
	if(!is.null(hw.to.az)) {
		params <- paste(params, "--hw-to-az")
		params <- paste(params, hw.to.az)
	}

	# az.to.hw
	if(!is.null(az.to.hw)) {
		params <- paste(params, "--az-to-hw")
		params <- paste(params, az.to.hw)
	}

	# viterbi.training
	if(!is.null(viterbi.training)) {
		params <- paste(params, "--viterbi-training")
		params <- paste(params, viterbi.training)
	}

	return(params)
}

# Uruchamia bcftools roh o podanych parametrach
# Zwraca zawartość wyjściowego pliku, tymczasowe usuwa
bcftools.roh.run <- function(
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

	# Uruchomienie bcftools, zgubienie wyjścia
	system2(
		bcftools.roh.executable, params,
		# "", "", # stdout + stderr do konsoli
		NULL, NULL, # stdout + stderr do kosza
	)

	# Sprawdzamy czy powstały wyjściowe pliki
	if(!all(file.exists(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))) {
		stop("!all(file.exists(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))")
	}

	# Procesujemy wyjście programu
	bcftools.roh.table <- read.table(file.name.hom, TRUE)
	regions <- bcftools.roh.table.to.regions(bcftools.roh.table)

	# Usuwamy wyjściowe pliki
	if(!all(file.remove(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))) {
		stop("!all(file.remove(file.name.log, file.name.hom, file.name.hom.indiv, file.name.hom.summary, file.name.nosex))")
	}

	return(regions)
}

# Zamienia tabelę roh odczytaną przez bcftools na format roh (roh.R)
bcftools.roh.table.to.regions <- function(table) {
	t <- table[c("POS1", "POS2")]
	colnames(t) <- c("begin", "end")
	return(t)
}