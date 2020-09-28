#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def db_comparer(mondo_d2p, omim_d2p)
  mondo_to_omim.each do |mondo_dis, equivalent_omim|
    phenotypes_mondo = mondo_d2p[mondo_dis]
    phenotypes_omim = omim_d2p[equivalent_omim]

    not_in_mondo = (phenotypes_omim - phenotypes_mondo)
    not_in_omim = (phenotypes_mondo - phenotypes_omim)

    if not_in_mondo.length == 0 && not_in_omim.length == 0
      puts "No se encontraron diferencias en los fenotipos asociados a #{d1} y su equivalente #{d2}"
    elsif not_in_mondo.length != 0 && not_in_omim.length != 0
      puts "#{d1} contiene el/los fenotipo/s #{not_in_omim}, no encontrados en OMIM, y #{d2} contiene el/los fenotipo/s #{not_in_mondo}, no encontrados en MONDO"  
    elsif not_in_mondo.length == 0 && not_in_omim.length != 0
      puts "#{d1} contiene el/los fenotipo/s #{not_in_omim}, no encontrados en OMIM"
    else not_in_mondo.length != 0 && not_in_omim.length == 0
      puts "#{d2} contiene el/los fenotipo/s #{not_in_mondo}, no encontrados en MONDO"  
    end
  end  
end

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:mondo_file] = nil
  opts.on("-m", "--mondo PATH", "Path to mondo file") do |item|
    options[:mondo_file] = item
  end

  options[:omim_file] = nil
  opts.on("-o", "--omim PATH", "Path to omim file") do |item|
    options[:omim_file] = item
  end

  options[:relations_file] = nil
  opts.on("-r", "--relations PATH", "Path to ontology file containing the equivalent terms") do |item|
    options[:relations_file] = item
  end

  options[:disease] = nil
  opts.on("-d", "--disease STRING", "The MONDO disease wanted to be compared with its OMIM equivalent") do |item|
    options[:disease] = item
  end

  options[:from_list] = nil
  opts.on("-l", "--list PATH", "Path to file containing a list of MONDOIDs used as input (optional)") do |item|
    options[:from_list] = item
  end  

  options[:summary] = false
  opts.on("-s", "--summary BOOLEAN", "If set to true, creates a file with a summary of the results obtained from the search") do |item|
    options[:summary] = item
  end

  options[:verbose] = false
  opts.on("-v", "--verbose BOOLEAN", "If set to true, displays more information about the comparison between databases") do |item|
    options[:verbose] = item
  end
  
end.parse!


############################################################################################
## MAIN
############################################################################################
mondo_to_omim = load_obo(options[:relations_file])
mondo_d2p = load_profiles(options[:mondo_file], 0, 1)
omim_d2p = load_profiles(options[:omim_file], 0, 3)


if options[:verbose]
  db_comparer(mondo_d2p, omim_d2p)
elsif options[:from_list]
  mondos_from_list = load_tabular_file(options[:from_list])
  mondos_from_list.each do |mondo_from_list|
    puts "#{mondo_from_list[0]}" + "\t" + "#{mondo_to_omim[mondo_from_list[0]]}"
  end 
else   
  mondo_d2p.keys.each do |diseaseid|
    puts "#{diseaseid}" + "\t" + "#{mondo_to_omim[diseaseid]}"
  end  
end    
