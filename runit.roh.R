library('RUnit')

source('roh.R')

# Jeśli podamy NULL'owy chromosom - spodziewamy się otrzymać NULL
test.task.chromosomes.to.string.1 <- function() {
	checkEquals(
		task.chromosomes.to.string(NULL),
		NULL
	)
}

# Jeśli podamy wyszukiwanie ale nie wyspecyfikujemy żadnego kryterium - błąd
test.task.chromosomes.to.string.2 <- function() {
	task.chromosomes <- list()
	checkException(task.chromosomes.to.string(task.chromosomes))
}

# Jeśli podamy sam chromosom - spodziewamy się go jako liczby na wyjściu
test.task.chromosomes.to.string.3 <- function() {
	task.chromosomes <- list()
	task.chromosomes$chromosome <- 10

	checkEquals(
		task.chromosomes.to.string(task.chromosomes),
		"10"
	)
}

# Jeśli podamy sam zakres - spodziewamy się go jako liczby na wyjściu
test.task.chromosomes.to.string.4 <- function() {
	task.chromosomes <- list()
	task.chromosomes$region <- list()
	task.chromosomes$region$begin <- 123
	task.chromosomes$region$end <- 456

	checkEquals(
		task.chromosomes.to.string(task.chromosomes),
		"123-456"
	)
}

# Jeśli podamy jedno i drugie - otrzymamy połączone
test.task.chromosomes.to.string.5 <- function() {
	task.chromosomes <- list()
	task.chromosomes$chromosome <- 789
	task.chromosomes$region <- list()
	task.chromosomes$region$begin <- 123
	task.chromosomes$region$end <- 456

	checkEquals(
		task.chromosomes.to.string(task.chromosomes),
		"789:123-456"
	)
}