#! /usr/bin/env ruby

require 'optparse'
require 'ruby-graphviz'
require 'zlib'

############################################################################################
## METHODS
############################################################################################
def header_parser(str)
	arr = str.split("\t")
	arr.map! do |attr|
	    if attr == 'subject'
	        attr = 'id'
	    elsif attr.include?('subject_')
	        attr = attr.split('subject_')[1]
	    elsif attr == 'object'
	        attr = ""
	    elsif attr.include?('object_')
	        attr = attr.split('object_')[1]
	    else
	    	attr = attr    
	    end    
	end
	arr.reject!(&:empty?)    
end

def all_values_equal?(hash)
    values_count_grouped = hash.map {|k,v| [k, v.count]}.to_h.group_by{|k,v| v}
    size = values_count_grouped.values.size
    if size != 1
    	puts "WARNING!! NOT ALL HEADERS HAVE EQUAL LENGTH:"
    	size.times {|i| values_count_grouped.values[i].map{|file, args| puts "#{file} \t #{args} attributes"}}
    else
    	puts "All headers have equal length"
    end		
end

def get_headerNcompare(file_list)
	headers = {}
	file_list.each do |file|
		Zlib::GzipReader.open(file) { |gz|
			headers[file] = header_parser(gz.readlines[0].chomp)
		}	
	end
	all_values_equal?(headers)
	return headers		
end

def makegraph(arr_nodes, output_path, file_attributes)
	common_attr = file_attributes.values[0]
	diff_attr = file_attributes["/mnt/home/users/bio_267_uma/apareslar/projects/Db_documents/test/monarch_graph/tsv/all_associations/disease_phenotype.all.tsv.gz"]

	## Creating graph and setting global attributes ##
	g = GraphViz.new( :G, :type => :digraph )
	g.node[:shape] = "record"

	## Assigning the edges ##
	included_nodes = []
	arr_nodes.each_with_index do |nodeAnodeB, i|
		nodeA, nodeB = nodeAnodeB
		relation = g.add_nodes("relation_#{i}")
		relation[:color] = "green"
		relation[:label] = "{ #{nodeA}_#{nodeB} |{#{common_attr[5]}| #{common_attr[6]}| #{common_attr[7]}| #{common_attr[8]}| #{common_attr[9]}| #{common_attr[10]}| #{common_attr[11]}}}"
		if !included_nodes.include?(nodeA)
			included_nodes << nodeA
			node_A = g.add_nodes(nodeA)
			if nodeA != 'diesease'
				node_A[:label] = "{ #{nodeA} |{#{common_attr[0]}| #{common_attr[1]}| #{common_attr[2]}| #{common_attr[3]}| #{common_attr[4]}}}"
			else
				node_A[:label] = "{ #{nodeA} |{#{diff_attr[0]}| #{diff_attr[1]}| #{diff_attr[2]}| #{diff_attr[3]}| #{diff_attr[4]} #{diff_attr[12]}| #{diff_attr[13]}| #{diff_attr[14]}| #{diff_attr[15]}}}"
			end	
		end
		if !included_nodes.include?(nodeB)
			included_nodes << nodeB
			node_B= g.add_nodes(nodeB)
			node_B[:label] = "{ #{nodeB} |{#{common_attr[0]}| #{common_attr[1]}| #{common_attr[2]}| #{common_attr[3]}| #{common_attr[4]}}}"
		end
		g.add_edges(nodeA, relation)
		g.add_edges(relation, nodeB)
	end
	## Saving the final graph ##
	g.output(:png => "#{output_path}.png")
	puts "Graph succesfully created: #{output_path}.png"	
end

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:output] = nil
  opts.on("-o", "--output STRING", "Name of the outputted graph") do |item|
    options[:output] = item
  end

  options[:input_folder] = nil
  opts.on("-i", "--input_folder PATH", "Path to folder with Monarch data") do |item|
    options[:input_folder] = item
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
files = Dir.glob(File.join(options[:input_folder], '*.all.tsv.gz'))
all_nodes = []
files.each do |file_path|
	filename = File.basename(file_path, '.all.tsv.gz')
	array_nodes_file = filename.split("_")
	all_nodes << array_nodes_file
end

puts "Getting the headers and looking for differences..."
headers = get_headerNcompare(files)
put headers


makegraph(all_nodes, options[:output], headers)