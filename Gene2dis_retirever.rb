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

def get_gene2disease(file)
	g2d_arr = []
	file.each do |record|
		if record[1].include?("NM_")
      gene = record[1].to_s.split("(")[1].to_s.split(")")[0]
		  disease = record[4]
		  g2d_arr << [gene,disease]
    elsif record[1].include?("NC_") && record[1].include?("(")
      pos1 = record[1].split("(").to_s.split(")").to_s.split("\"")[4]
      pos2 = record[1].split("(").to_s.split(")").to_s.split("\"")[8]
      disease = record[4]
      g2d_arr << [pos1, pos2, disease]
    else record[1].include?(",")
      gene = record[1].to_s.split(",")[0]
      disease = record[4]
      g2d_arr << [gene,disease]
    end 
	end
	return g2d_arr
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
variants_2_diseases = load_file(options[:mondo_file])

g2d = get_gene2disease(variants_2_diseases)

g2d.each do |record|
  if record.length == 2
    puts "#{record[0]}    #{record[1]}"
  else
    puts "#{record[0]}-#{record[1]}   #{record[2]}"
  end
end