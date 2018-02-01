source('roh.R')

bcftools.executable <- "/Users/Pro/BCFtools/bcftools"

# Buduje wiersz polecenia do uruchomienia BCFTools ROH
#
# Wymagane:
# 	vcf.file.name		(string)							Ścieżka do pliku .vcf / .vcf.gz
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
	vcf.file.name,
	af.default = 0.4, pl.value = 30.0,
	ignore.homref = FALSE, skip.indels = FALSE,
	rec.rate = NULL,

	hw.to.az = NULL, az.to.hw = NULL,
	viterbi.training = NULL
) {

	params <- "roh"

	if(is.null(vcf.file.name))
		stop('is.null(vcf.file.name)')

	# vcf.file.name
	params <- paste(params, vcf.file.name)

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
bcftools.roh.run <- function(
	params
) {
	# Wyjście do pliku tymczasowgo
	file.name = tempfile()

	params <- paste(params, "--output")
	params <- paste(params, file.name)

	# Chcemy tylko informacje o samplach
	params <- paste(params, "-O")
	params <- paste(params, "s")

	# Uruchomienie bcftools
	exit.code <- system2(
		bcftools.executable, params,
		"", "" # stdout + stderr do konsoli
		# NULL, NULL, # stdout + stderr do kosza
	)

	# Sprawdzamy kod zakończenia
	if(exit.code != 0) {
		stop("exit.code")
	}

	# Czy plik istnieje?
	if(!file.exists(file.name)) {
		stop("!file.exists(file.name)")
	}

	# Parsujemy wyjście
	bcftools.roh.table <- read.table(file.name)
	result <- bcftools.roh.table.to.regions(bcftools.roh.table)

	# Usuwamy plik tymczasowy
	if(!file.remove(file.name)) {
		stop("!file.remove(file.name)")
	}

	# Zwracamy wynik
	return(result)
}

# Zamienia tabelę roh odczytaną przez bcftools na format roh (roh.R)
bcftools.roh.table.to.regions <- function(table) {

	# Nagłówek: 
	# V1	V2				V3				V4				V5						V6
	# ST    [2]Sample       [3]Chromosome   [4]Position     [5]State (0:HW, 1:AZ)   [6]Quality (fwd-bwd phred score)

	t <- table[c("V4", "V5", "V6")]
	colnames(t) <- c("position", "homozygosity", "score")
	t$homozygosity = as.logical(t$homozygosity)
	return(t)
}

# Buduje zestaw parametrów do uruchomienia BCFTools view
# 	task - zadanie, zdefiniowane w pliku roh.R
# 	output.file.name - wyjściowa nazwa pliku, do którego zostaną zapisane dane.
bcftools.view.buildparams <- function(task, output.file.name) {

	params <- "view"

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

	# Typ wyjścia - .vcf.gz
	params <- paste(params, "--output-type")
	params <- paste(params, "v")

	# Wyjście
	params <- paste(params, "-o")
	params <- paste(params, output.file.name)

	return(params)
}
# Uruchamia podprogram view z parametrami zbudowanymi przez bcftools.view.buildparams
bcftools.view.run <- function(params) {
	# Uruchomienie bcftools
	exit.code <- system2(
		bcftools.executable, params,
		 "", "" # stdout + stderr do konsoli
		#NULL, NULL, # stdout + stderr do kosza
	)

	# Sprawdzamy kod zakończenia
	if(exit.code != 0) {
		stop("exit.code")
	}

	return(TRUE)
}