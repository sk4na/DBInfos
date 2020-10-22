#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools'

############################################################################################
## METHODS
############################################################################################

def parse_tsv_content(file, keyword, col_dis, col_hpo)
  parsed = {}
  File.open(file).each do |line|
    fields = line.chomp.split("\t")
    if fields[col_dis].match(/#{keyword}/)
      disease_id = fields[col_dis]
      hpo_id = fields[col_hpo]    
      query = parsed[disease_id]
      if query.nil?
         parsed[disease_id] = [hpo_id]
      else
         parsed[disease_id] << hpo_id
      end
    end
  end
  return parsed
end        	

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:file] = nil
  opts.on("-f", "--file PATH", "Path to file containing the desired profiles") do |item|
    options[:file] = item
  end

  options[:type] = nil
  opts.on("-t", "--type STRING", "Type of the file that contains the desired profiles: obo, tsv") do |item|
    options[:type] = item
  end

  options[:keyword] = nil
  opts.on("-k", "--keywod STRING", "If type is 'obo', select the keyword that will be searched as targeted xref. If type is 'tsv', select the key diseaseID that will be selected for the profiles") do |item|
    options[:keyword] = item
  end

  options[:dis_col] = nil
  opts.on("-d", "--disease_col INT", "If type is 'tsv', select the col number containing the diseaseID") do |item|
    options[:dis_col] = item
  end

  options[:phen_col] = nil
  opts.on("-p", "--phenotype_col INT", "If type is 'tsv', select the col number containing the phenotype IDs") do |item|
    options[:phen_col] = item
  end


end.parse!

############################################################################################
## MAIN
############################################################################################
if options[:type] == 'obo'
	profiles = load_obo(options[:file], options[:keyword])
elsif options[:type] == 'tsv'
  profiles = parse_tsv_content(options[:file], options[:keyword], options[:dis_col].to_i, options[:phen_col].to_i)
end					
profiles.each do |key, values|
		puts "#{key}\t#{values.join(',')}"
end