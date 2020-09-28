#! /usr/bin/env bash

../bin/phen2dis_matcher.rb -m Hs_disease_phenotype_SAMPLE.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt > mondo_to_omim_with_match_percentages
../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_with_match_percentages | cut -f 2 > omim_equivalents_from_obo
paste mondo_to_omim_with_match_percentages omim_equivalents_from_obo > final_result
../bin/xygraph.R -d final_result -o 'graph' -x 2 -y 4
