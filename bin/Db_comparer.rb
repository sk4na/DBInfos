#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools.rb'

############################################################################################
## METHODS
############################################################################################
def get_equivalent_term(file, diseaseID)
  terms_info = file.to_s.split("[Term]")
  terms_info.each do |term_info|
    if term_info.include?(diseaseID)
      equivalent = termino.split(" ").grep(/OMIM:/)
    end
  end
  return equivalent
end

def db_comparer(d2p_1, d2p_2)
  d1 = options[:disease]
  d2 = omim_equivalent

  phenotypes_1 = []
  d2p_1.each do |d2p_pair|
    phenotypes_1 << d2p_pair[1]
  end

  phenotypes_2 = []
  d2p_2.each do |d2p_pair|
    phenotypes_2 << d2p_pair[3]
  end

  not_in_mondo = (phenotypes_2 - phenotypes_1)
  not_in_omim = (phenotypes_1 - phenotypes_2)

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
  opts.on("-r", "--relations PATH", "Path to ontology file with the MONDO-OMIM equivalent terms") do |item|
    options[:source_file] = item
  end

  options[:disease] = nil
  opts.on("-d", "--disease STRING", "The MONDO disease wanted to be compared with its OMIM equivalent") do |item|
    options[:disease] = item
  end

  options[:summary] = false
  opts.on("-s", "--summary BOOLEAN", "If set to true, creates a file with a summary of the results obtained from the search") do |item|
    options[:summary] = item
  end
  
end.parse!


############################################################################################
## MAIN
############################################################################################
mondo_obo = load_file([:relations_file])
mondo_d2p = load_file([:mondo_file])
omim_d2p = load_file([:omim_file])

omim_equivalent = get_equivalent_term(mondo_obo, options[:disease])

d2p_1 = get_disease2phen(mondo, options[:disease])
d2p_2 = get_disease2phen(omim, omim_equivalent)

db_comparer(d2p_1, d2p_2)
