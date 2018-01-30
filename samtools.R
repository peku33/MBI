samtools.bgzip.executable = "/Users/Pro/tabix/bgzip"
samtools.tabix.executable = "/Users/Pro/tabix/tabix"

samtools.bgzip.run <- function(file.name) {

	if(!file.exists(file.name))
		stop("!file.exists(file.name)")

	# Uruchomienie samtools.bgzip.executable
	exit.code <- system2(
		samtools.bgzip.executable, file.name,
	  "", "" # stdout + stderr do konsoli
		#NULL, NULL, # stdout + stderr do kosza
	)

	# Sprawdzamy kod zakończenia
	if(exit.code != 0) {
		stop("exit.code")
	}

	# file.name.gz = paste(file.name, ".gz", sep = "")
	# if(!file.exists(file.name.gz))
	# 	stop("!file.exists(file.name.gz)")

	# Stary plik jest automatycznie usuwany
	# if(!file.remove(file.name))
	# 	stop("!file.remove(file.name)")

	# if(!file.rename(file.name.gz, file.name))
	#	stop("!file.rename(file.name.gz, file.name)")

	return(TRUE)
}

samtools.tabix.buildparams <- function(file.name) {

	params <- ""

	# Z nagłówkiem
	params <- paste(params, "-h")
	
	# Typ wejścia
	params <- paste(params, "-p", sep = "")
	params <- paste(params, "vcf")

	# Nazwa pliku
	params <- paste(params, file.name)
	
}
samtools.tabix.run <- function(params) {
  print(params)
	# Uruchomienie samtools.tabix.executable
	exit.code <- system2(
		samtools.tabix.executable, params,
		"", "" # stdout + stderr do konsoli
		#NULL, NULL, # stdout + stderr do kosza
	)

	# Sprawdzamy kod zakończenia
	if(exit.code != 0) {
		stop("exit.code")
	}

	return(TRUE)
}