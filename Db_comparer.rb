require 'optparse'

############################################################################################
## METHODS
############################################################################################
def load_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def get_equivalent_term(file, diseaseID)
  equivalent = []
  terms_info = file.to_s.split("[Term]")
  terms_info.each do |term_info|
    if term_info.include?("id: #{diseaseID}")
      equivalent = term_info.scan(/OMIM......./).last
    end
  end
  return equivalent
end

def get_disease2phen(file, diseaseID)
  disease2phenotypes = []
  file.each do |line|
    if line.include?(diseaseID)
      disease2phenotypes << line
    end
  end
  return disease2phenotypes
end

def db_comparer(d2p_1, d2p_2, mondo_disease, omim_equivalent)
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

  if omim_equivalent == nil
    puts "#{mondo_disease} no tiene término equivalente en OMIM" 
  elsif not_in_mondo.length == 0 && not_in_omim.length == 0
    puts "No se encontraron diferencias en los fenotipos asociados a #{mondo_disease} y su equivalente #{omim_equivalent}"
  elsif not_in_mondo.length != 0 && not_in_omim.length != 0
    puts "#{mondo_disease} contiene el/los fenotipo/s #{not_in_omim}, no encontrados en OMIM, y #{omim_equivalent} contiene el/los fenotipo/s #{not_in_mondo}, no encontrados en #{mondo_disease}"  
  elsif not_in_mondo.length == 0 && not_in_omim.length != 0
    puts "#{mondo_disease} contiene el/los fenotipo/s #{not_in_omim}, no encontrados en #{omim_equivalent}"
  else not_in_mondo.length != 0 && not_in_omim.length == 0
    puts "#{omim_equivalent} contiene el/los fenotipo/s #{not_in_mondo}, no encontrados en MONDO"  
  end
end

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:mondo_file] = nil
  opts.on("-m", "--mondo PATH", "Path to mondo diseases to phenotypes file") do |item|
    options[:mondo_file] = item
  end

  options[:omim_file] = nil
  opts.on("-o", "--omim PATH", "Path to omim diseases to phenotypes file") do |item|
    options[:omim_file] = item
  end

  options[:source_file] = nil
  opts.on("-s", "--source PATH", "Path to source file of the MONDO-OMIM equivalent terms") do |item|
    options[:source_file] = item
  end

  options[:disease] = nil
  opts.on("-d", "--disease STRING", "The MONDO disease wanted to be compared with its OMIM equivalent") do |item|
    options[:disease] = item
  end
  
  options[:from_file] = nil
  opts.on("-f", "--from PATH", "Path to file with the MONDO diseases wanted to be compared with their OMIM equivalents") do |item|
    options[:from_file] = item
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
mondo_obo = load_file(options[:source_file])
mondo_d2p = load_file(options[:mondo_file])
omim_d2p = load_file(options[:omim_file])

if options[:from_file]
  mondo_diseases = load_file(options[:from_file])
  mondo_diseases.each do |mondo_disease|
    omim_equivalent = get_equivalent_term(mondo_obo, mondo_disease)
    d2p_1 = get_disease2phen(mondo_d2p, mondo_disease)
    d2p_2 = get_disease2phen(omim_d2p, omim_equivalent)
    db_comparer(d2p_1, d2p_2, mondo_disease, omim_equivalent)
  end
else
  omim_equivalent = get_equivalent_term(mondo_obo, options[:disease])
  d2p_1 = get_disease2phen(mondo_d2p, options[:disease])
  d2p_2 = get_disease2phen(omim_d2p, omim_equivalent) 
  db_comparer(d2p_1, d2p_2, options[:disease], omim_equivalent)
end

  

