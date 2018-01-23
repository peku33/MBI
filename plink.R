# Na podstawie https://www.cog-genomics.org/plink/1.9/ibd

# Buduje wiersz parametrów wywołania programu plink
#
# task - task (task.R)
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
	if(!is.null(task$sample)) {
		stop("No support for sample filtering in plink. Sorry. Use filtered file and set task$sample to NULL")
	}

	# task$chromosomes
	if(!is.null(task$chromosomes)) {

		# Albo chromosom albo region albo jedno i drugie, ale samo nie ma sensu
		if(is.null(task$chromosomes$chromosome) && is.null(task$chromosomes$region)) {
			stop("is.null(task$chromosomes$chromosome) && is.null(task$chromosomes$region)")
		}

		params <- paste(params, "--chr ")

		# task$chromosomes$chromosome
		if(!is.null(task$chromosomes$chromosome)) {
			params <- paste(params, task$chromosomes$chromosome, sep = "")
		}

		# separator
		if(!is.null(task$chromosomes$chromosome) && !is.null(task$chromosomes$region)) {
			params <- paste(params, ":", sep = "")
		}

		# task$chromosomes$region
		if(!is.null(task$chromosomes$region)) {
			params <- paste(params, task$chromosomes$region$begin, sep = "")
			params <- paste(params, "-", sep = "")
			params <- paste(params, task$chromosomes$region$end, sep = "")
		}
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