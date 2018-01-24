# Obiekt task
# task <- list()
#	task$vcf_file_name = string # Ścieżka do pliku .vcf lub .vcf.gz
#	task$sample <- string / NULL # Próbka dla której zostaną odfiltrowane wyniki z .vcf lub NULL aby pominąć filtrowanie
#	task$chromosomes <- list() / NULL # Ustawienia filtra chromosomów. Kolekcja opisana niżej albo NULL dla braku filtrowania
#		task$chromosomes$chromosome <- int / NULL # Numer chromosomu lub NULL dla braku filtrowania
#		task$chromosomes$region <- list() / NULL # Ustawienie zakresu lub NULL dla braku filtrowania
#			task$chromosomes$region$begin <- int # Początek zakresu
#			task$chromosomes$region$end <- int # Koniez zakresu

# Obiekt roh
# roh <- data.frame()
# kolumny:
#	begin - index początku homozygotycznośći
#	end - index końca homozygotyczności



task.chromosomes.to.string <- function(task.chromosomes) {

	# Dla wartości NULL zwracamy NULL
	if(is.null(task.chromosomes)) {
		return(NULL)
	}

	# Albo chromosom albo region albo jedno i drugie
	if(is.null(task.chromosomes$chromosome) && is.null(task.chromosomes$region)) {
		stop("is.null(task.chromosomes$chromosome) && is.null(task.chromosomes$region)")
	}

	output <- ""

	# task.chromosomes$chromosome
	if(!is.null(task.chromosomes$chromosome)) {
		output <- paste(output, task.chromosomes$chromosome, sep = "")
	}

	# separator
	if(!is.null(task.chromosomes$chromosome) && !is.null(task.chromosomes$region)) {
		output <- paste(output, ":", sep = "")
	}

	# task.chromosomes$region
	if(!is.null(task.chromosomes$region)) {
		output <- paste(output, task.chromosomes$region$begin, sep = "")
		output <- paste(output, "-", sep = "")
		output <- paste(output, task.chromosomes$region$end, sep = "")
	}

	return(output)
}