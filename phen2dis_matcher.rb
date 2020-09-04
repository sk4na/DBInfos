#! /usr/bin/env ruby

require 'optparse'
require './dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def phenotype_match(omim_ids, omim_relations, mondo_ids, mondo_relations)
  mondo_phenotypes = []
  best_matches = []
  mim2matchnumber = {}
  omim_ids.each do |omim_id|
    omim_d2p = get_disease2phen(omim_relations, omim_id)
    omim_phenotypes = omim_d2p.map{|record| record[3]}
    mondo_ids.each do |mondo_id|
      count = 0
      mondo_phenotypes = get_disease2phen(mondo_relations, mondo_id).map{|record| record[1]}
      omim_phenotypes.each do |phenotype|
        if mondo_phenotypes.include?(phenotype)
          count += 1
        end
      end
      mim2matchnumber[mondo_id] = "#{count} of #{omim_phenotypes.length}"  
    end
    best_matches << mim2matchnumber.sort_by {|k,v| v}.reverse[0]
  end    
  puts best_matches
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
mondo_relations = load_tabular_file(options[:mondo_relations])
omim_relations = load_tabular_file(options[:omim_relations])
omim_ids = get_ids(omim_relations)
mondo_ids = get_ids(mondo_relations)

phenotype_match(omim_ids, omim_relations, mondo_ids, mondo_relations)