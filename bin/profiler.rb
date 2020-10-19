#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools'

############################################################################################
## METHODS
############################################################################################

def load_tabular_file(file, keyword)
	# col_dis = 0
	# col_hpo = 0
	# File.open(file).first.chomp.split("\t").each_with_index do |field, i|
	#   if field.include?(keyword)
	#     col_dis = i
	#   elsif field.include?("HP:")
	#     col_hpo = i  
	#   end
	# end
	# File.open(file).each do |line|
 #    	fields = line.chomp.split("\t")
 #    	if fields[col_dis].match(/#{keyword}/)
 #        	disease_id = fields[col_dis]
 #        	hpo_id = fields[col_hpo]    
 #        	puts "#{disease_id}\t#{hpo_id}"
 #        end
 #    end
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

end.parse!

############################################################################################
## MAIN
############################################################################################
if options[:type] == 'obo'
	profiles = load_obo(options[:file], options[:keyword])
elsif options[:type] == 'tsv'
	tsv_content = load_tabular_file(options[:file])
  profiles = parse_tsv_content(tsv_content, options[:keyword])
end					
profiles.each do |key, values|
		puts "#{key}\t#{values.join(',')}"
end