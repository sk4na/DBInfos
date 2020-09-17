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
    best_ids = {}
    profiles_B.each do |disease_id_B, phenotypes_B|
      count = (phenotypes_A & phenotypes_B).length
      if count >= best_count
        best_count = count
        best_ids[disease_id_B] = best_count
      end
    end
    real_best_ids = best_ids.select {|k,v| v == best_count}
    if best_count > 0
      percentages = get_percentages(best_count, real_best_ids.keys, profiles_B)
      max_percentages = percentages.max
      best_percentages = []
      percentages.each_with_index do |perc, i|
        if perc == max_percentages
          best_percentages << [real_best_ids.keys[i], perc]
        end
      end
      best_matches << [disease_id_A, best_percentages] 
    else
      best_matches << [disease_id_A, 'nil']
    end  
  end    
  best_matches.each do |disID_A, data|
    puts "#{disID_A}" + "\t" + "#{data.inspect}"
  end
end

def get_percentages(best_count, best_ids, profiles_B)
  percentages = []
  best_ids.each_with_index do |best_id|
    percentages << best_count.fdiv(profiles_B[best_id].length)
  end
  return percentages
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
mondo_profiles = load_profiles(options[:mondo_relations], 0, 1)
omim_profiles = load_profiles(options[:omim_relations], 0, 3)

phenotype_match(mondo_profiles, omim_profiles)