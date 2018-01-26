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
#	position - (int) index próbki
#	homozygosity - (logical <bool>) czy próbka znajduje się w regionie homozygotyczności
#	score - (optional, float 0.0 - 100.0) ocena pewności



task.chromosomes.to.string <- function(task.chromosomes) {

	# Dla wartości NULL zwracamy NULL
	if(is.null(task.chromosomes)) {
		return(NULL)
	}

	output <- ""

	# Chromosom musi być zawsze ustawiony
	if(is.null(task.chromosomes$chromosome)) {
		stop("is.null(task.chromosomes$chromosome)")
	}

	# task.chromosomes$chromosome
	output <- paste(output, task.chromosomes$chromosome, sep = "")

	# task.chromosomes$region
	if(!is.null(task.chromosomes$region)) {

		# Początek i koniec nie mogą być nullami
		if(is.null(task$chromosomes$region$begin) || is.null(task$chromosomes$region$end))
			stop("is.null(task$chromosomes$region$begin) || is.null(task$chromosomes$region$end)")

		output <- paste(output, ":", sep = "")
		output <- paste(output, format(task.chromosomes$region$begin, scientific=F), sep = "")
		output <- paste(output, "-", sep = "")
		output <- paste(output, format(task.chromosomes$region$end, scientific=F), sep = "")
	}

	return(output)
}