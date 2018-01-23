# Obiekt task
# task <- list()
#	task$vcf_file_name = string # Ścieżka do pliku .vcf lub .vcf.gz
#	task$sample <- string / NULL # Próbka dla której zostaną odfiltrowane wyniki z .vcf lub NULL aby pominąć filtrowanie
#	task$chromosomes <- list() / NULL # Ustawienia filtra chromosomów. Kolekcja opisana niżej albo NULL dla braku filtrowania
#		task$chromosomes$chromosome <- int / NULL # Numer chromosomu lub NULL dla braku filtrowania
#		task$chromosomes$region <- list() / NULL # Ustawienie zakresu lub NULL dla braku filtrowania
#			task$chromosomes$region$begin <- int # Początek zakresu
#			task$chromosomes$region$end <- int # Koniez zakresu