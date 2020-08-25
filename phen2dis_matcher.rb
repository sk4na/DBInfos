#! /usr/bin/env ruby

require 'optparse'
require './ontology.rb'

############################################################################################
## METHODS
############################################################################################
def load_tabular_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def load_id_file(file)
  records = []
  File.open(file).each do |line|
    records << line.chomp
  end
 return records
end

def get_ids(relations)
  ids = []
  relations.each do |relation|
    ids << relation[0]
  end
  ids = ids.uniq
  return ids  
end  

def get_disease2phen(relations, diseaseID)
  disease2phenotypes = []
  relations.each do |relation|
    listed_disease_id, related_code = relation
    if listed_disease_id == diseaseID
      disease2phenotypes << relation
    end
  end
  return disease2phenotypes
end

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
      mim2matchnumber[mondo_id] = count  
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