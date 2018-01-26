MBI ROH
=======

Celem projektu jest stworzenie aplikacji w języku `R`, wykorzystującej framework `shiny`. Zadaniem aplikacji będzie udostępnianie interfejsu do wizualizacji i przeglądania wyników kilku algorytmów do wykrywania braku heterozygotyczności.

Instalacja:
----------
Do działania, konieczna jest instalacja (wystarczy zbudowanie):

- `samtools`:
  - `https://github.com/samtools/tabix`
  - `make` zgodnie z instrukcją
  - ustawienie ścieżki do `bgzip` i `tabix` w `samtools.R`
- `BCFTools`:
  - `git clone https://github.com/samtools/BCFtools`
  - `make` zgodnie z instrukcją
  - ustawienie ścieżki do `BCFTools/bcftools` w `bcftools.R`
- `Plink`:
  - Pobranie lub zbudowanie ze źródeł ze strony https://www.cog-genomics.org/plink2
  - Ustawienie ścieżki w `plink.R`

Wymagane biblioteki `R`:

 - RUnit ( `install.packages('RUnit')`)

Struktury danych:
-----------------
Opisane szczegółowo w pliku `roh.R`

Przykład uruchomienia algorytmów:
---------------------------------
`roh-example.R`