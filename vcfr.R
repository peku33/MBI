library('vcfR')
library('stringr')

# Konwertuje parę genotypów na wartość BAF
vcfr.baf.from.genotype <- function(a, b) {

	# is.integer hack
	# https://stackoverflow.com/questions/3476782/check-if-the-number-is-integer
	if(!all.equal(a, as.integer(a)) || !all.equal(b, as.integer(b)))
		stop('!is.integer(a) || !is.integer(b)')

	# 0/0 -> 0.0
	if(a == b && a == 0)
		return(0.0)

	# 1/1 -> 1.0
	if(a == b && a == 1)
		return(1.0)

	# Pozostałe: 0.5
	return(0.5)
}

# Konwertuje listę napisów w postaci:
# x|y lub x/y lub x\y
# Na listę BAF
vcfr.baf.from.genotypes <- function(genotypes) {

	# Puste wejście = puste wyjście
	if(is.null(genotypes))
		return(NULL)

	matches <- str_match(genotypes, "(\\d+)[\\|\\\\/](\\d+)")
	output <- apply(matches, 1, function(row)
		{
			a = as.integer(row[[2]])
			b = as.integer(row[[3]])

			return(vcfr.baf.from.genotype(a, b))
		}
	)
	return(output)
}

# Konwertuje strukturę vcf (wyjście z read.vcfR()) na data-frame:
#	position - (int) index próbki
#	baf - (float 0.0 - 1.0) - wartość BAF
vcfr.baf.from.struct <- function(vcfr.baf.struct) {

	# Sprawdź, czy istnieje tylko jeden chromosom w zbiorze danych
	chromosomes <- getCHROM(vcfr.baf.struct)
	chromosomes.unique <- unique(chromosomes)
	chromosomes.unique.count <- length(chromosomes.unique)

	if(chromosomes.unique.count > 1)
		stop('chromosomes.unique.count > 1')

	# Pobierz indeksy
	positions <- getPOS(vcfr.baf.struct)
	positions <- as.integer(positions)

	# Pobierz genotypy
	genotypes <- extract.gt(vcfr.baf.struct, IDtoRowNames = FALSE)

	# Sprawdź, czy liczba się zgadza
	if(length(positions) != length(genotypes))
		stop('length(positions) != length(genotypes)')

	# Genotypy -> BAF
	bafs <- data.frame(positions, vcfr.baf.from.genotypes(genotypes))
	colnames(bafs) <- c("position", "baf")
	return(bafs)
}

# Pomocnicza metoda, wykonująca vcfr.baf.from.struct na pliku o ścieżce podanej w parametrze
vcfr.baf.from.file <- function(vcfr.baf.file) {
	return(
		vcfr.baf.from.struct(
			read.vcfR(vcfr.baf.file)
		)
	)
}