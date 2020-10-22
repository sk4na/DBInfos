#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR OBTAINING METRICS FROM .PROF FILES #######################
../bin/profile_metrics.rb -p ../processed_data/mondo.prof,../processed_data/omim.prof > ../output_data/mondo_vs_omim_metrics
../bin/profile_metrics.rb -p ../processed_data/mondo.prof,../processed_data/omim_hpoa.prof > ../output_data/mondo_vs_hpoa_metrics