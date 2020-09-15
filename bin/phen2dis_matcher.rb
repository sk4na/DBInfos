#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def phenotype_match(profiles_A, profiles_B)
  best_matches = []
  profiles_A.each do |disease_id_A, phenotypes_A|
    best_count = 0
    best_ids = []
    profiles_B.each do |disease_id_B, phenotypes_B|
      count = (phenotypes_A & phenotypes_B).length
      if count >= best_count
        best_count = count
        best_ids << disease_id_B
      end
    end
    if best_count > 0
      percentages = get_percentages(best_count, best_ids, profiles_B)
      max_percentages = percentages.max

      best_percentages = []
      percentages.each_with_index do |perc, i|
        if perc == max_percentages
          best_percentages << [best_ids[i], perc]
        end
      end
      best_matches << [disease_id_A, best_percentages] 
    end
  end    
  best_matches.each do |disID_A, data|
    puts disID_A
    puts data.inspect
  end
end

def get_percentages(best_count, best_ids, profiles_B)
  percentages = []
  best_ids.each_with_index do |best_id|
    percentages << best_count.fdiv(profiles_B[best_id].length)
  end
  return percentages
end

def load_profiles(file, col_disease_id, col_hpo_id)
  profiles = {}
  File.open(file).each do |line|
    fields = line.chomp.split("\t")
    disease_id = fields[col_disease_id]
    hpo_id = fields[col_hpo_id]
    
    query = profiles[disease_id]
    if query.nil?
      profiles[disease_id] = [hpo_id]
    else
      query << hpo_id
    end
  end
  return profiles
end

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:mondo_relations] = nil
  opts.on("-m", "--mondo PATH", "Path to mondo diseases to phenotypes file") do |item|
    options[:mondo_relations] = item
  end

  options[:omim_relations] = nil
  opts.on("-o", "--omim PATH", "Path to omim diseases to phenotypes file") do |item|
    options[:omim_relations] = item
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
#mondo_relations = load_tabular_file(options[:mondo_relations])
mondo_profiles = load_profiles(options[:mondo_relations], 0, 1)
#omim_relations = load_tabular_file(options[:omim_relations])
omim_profiles = load_profiles(options[:omim_relations], 0, 3)
#omim_ids = get_ids(omim_relations)
#mondo_ids = get_ids(mondo_relations)

phenotype_match(mondo_profiles, omim_profiles)