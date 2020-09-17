#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def phenotype_match(profiles_A, profiles_B)
  best_matches = []
  profiles_A.each do |disease_id_A, phenotypes_A|
    matches = []
    best_count = 0
    profiles_B.each do |disease_id_B, phenotypes_B|
      count = (phenotypes_A & phenotypes_B).length
      if count >= best_count
        matches << [disease_id_B, count]
        best_count = count
      end
    end
    if matches.length > 0
      best_id_matches = matches.select{|k| k.last == best_count}.map{|k| f.first}
      percentages = get_percentages(best_count, best_id_matches, profiles_B)
      max_percentages = percentages.max
      best_percentages = []
      percentages.each_with_index do |perc, i|
        if perc == max_percentages
          best_percentages << [best_id_matches[i], perc]
        end
      end
      best_matches << [disease_id_A, best_percentages] 
    else
      best_matches << [disease_id_A, []]
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