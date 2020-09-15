#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def get_gene2disease(file)
	gene2disease_arr = []
	file.each do |record|
    disease = record[4]
		if record[1].include?("NM_")
      gene = record[1].scan(/\w{3,6}/)[2]
		  gene2disease_arr << [gene,disease]
    elsif record[1].include?("NC_") && record[1].include?("(")
      pos1 = record[1].split("(").to_s.split(")").to_s.split("\"")[4]
      pos2 = record[1].split("(").to_s.split(")").to_s.split("\"")[8]
      gene2disease_arr << [pos1, pos2, disease]
    else
      gene = record[1].to_s.split(",")[0]
      gene2disease_arr << [gene,disease]
    end 
	end
	return gene2disease_arr
end

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:mondo_file] = nil
  opts.on("-m", "--mondo PATH", "Path to genetic variants to MONDO diseases file") do |item|
    options[:mondo_file] = item
  end

end.parse!

############################################################################################
## MAIN
############################################################################################
variants_2_diseases = load_tabular_file(options[:mondo_file])

g2d = get_gene2disease(variants_2_diseases)

g2d.each do |record|
  if record.length == 2
    puts "#{record[0]}    #{record[1]}"
  else
    puts "#{record[0]}-#{record[1]}   #{record[2]}"
  end
end