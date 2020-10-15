#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools'
require '../lib/profiletools'

############################################################################################
## METHODS
############################################################################################
def phenotype_match(profiles_A, profiles_B)
  best_matches = []
  percentages_A = {}
  profiles_A.each do |disease_id_A, phenotypes_A|
    matches = []
    best_count = 0
    profiles_B.each do |disease_id_B, phenotypes_B|
      count = (phenotypes_A & phenotypes_B).length
      if count >= best_count && count != 0
        matches << [disease_id_B, count]
        best_count = count
      end
    end
    percentages_A[disease_id_A] = best_count.fdiv(profiles_A[disease_id_A].length)
    if matches.length > 0
      best_id_matches = matches.select{|k| k.last == best_count}.map{|k| k.first}
      percentages_B = get_percentages(best_count, best_id_matches, profiles_B)
      max_percentages = percentages_B.max

      best_percentages = []
      percentages_B.each_with_index do |perc, i|
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
    data.each do |related_disBID_and_perc|
    puts "#{disID_A}" + "\t" + "#{percentages_A[disID_A]}" + "\t" + "#{related_disBID_and_perc.first}" + "\t" + "#{related_disBID_and_perc.last}"
    end
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

  options[:mondo_profiles] = nil
  opts.on("-m", "--mondo PATH", "Path to .prof file containing MONDO disease IDs to phenotypes") do |item|
    options[:mondo_profiles] = item
  end

  options[:target_profiles] = nil
  opts.on("-t", "--target PATH", "Path to .prof file containing the target disease to phenotype relationships") do |item|
    options[:target_profiles] = item
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
mondo_profiles = load_profiles(options[:mondo_profiles], 0, 1)
target_profiles = load_profiles(options[:target_profiles], 0, 1)    

mondo_prof_avg_size = prof_avg_size(mondo_profiles)
target_prof_avg_size = prof_avg_size(target_profiles)

if target_prof_avg_size <= mondo_prof_avg_size
  phenotype_match(target_profiles, mondo_profiles)
else
  phenotype_match(mondo_profiles, target_profiles)
end

