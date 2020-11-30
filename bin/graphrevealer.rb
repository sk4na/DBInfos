#! /usr/bin/env ruby

require 'optparse'
require 'ruby-graphviz'
require 'zlib'

############################################################################################
## METHODS
############################################################################################
def attr_parser(arr)
	arr.map! do |attrib|
	    if attrib == 'subject'
	        attrib = 'id'
	    elsif attrib.include?('subject_')
	        attrib = attrib.split('subject_')[1]
	    elsif attrib == 'object'
	        attrib = ""
	    elsif attrib.include?('object_')
	        attrib = attrib.split('object_')[1]
	    else
	    	attrib = attrib    
	    end    
	end
	arr.reject!(&:empty?)
	return arr.uniq    
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
			headers[file] = gz.readline.chomp.split("\t")
		}	
	end
	all_values_equal?(headers)
	return headers		
end

def get_relations_attributes(headers)
	attributes = {}
	headers.each do |filepath, header|
		relation = File.basename(filepath, '.all.tsv.gz')
		attributes[relation] = attr_parser(header.reject {|attrib| attrib.include?("subject") || attrib.include?("object")})
	end
	return attributes
end

def get_nodes_attributes(headers)
	attributes = {}
	headers.each do |filepath, header|
		nodes = File.basename(filepath, '.all.tsv.gz').split("_")
		if !attributes.keys.include?(nodes[0])
			attributes[nodes[0]] = attr_parser(header.select {|attrib| attrib.include?("subject") || attrib.include?("object")})
		end	
		if !attributes.keys.include?(nodes[1])
			attributes[nodes[1]] = attr_parser(header.select {|attrib| attrib.include?("subject") || attrib.include?("object")})
		end	
	end
	return attributes
end

def makegraph(headers, output_path)
	## Creating graph and setting global attributes ##
	g = GraphViz.new( :G, :type => :digraph )
	g.node[:shape] = "record"

	## Getting nodes ##
	arr_nodes = []
	headers.keys.each do |file_path|
		array_nodes_file = File.basename(file_path, '.all.tsv.gz').split("_")
		arr_nodes << array_nodes_file
	end
	
	## Getting attributes for nodes and their relations ##
	node_attributes = get_nodes_attributes(headers)
	relation_attributes = get_relations_attributes(headers)

	## Assigning the edges ##
	included_nodes = []
	arr_nodes.each_with_index do |nodeAnodeB, i|
		nodeA, nodeB = nodeAnodeB
		relation = g.add_nodes("#{nodeA}_#{nodeB}")
		relation[:color] = "green"
		relation[:label] = "{ #{nodeA}_#{nodeB} |{#{relation_attributes["#{nodeA}_#{nodeB}"].join("| ")}}}"
		if !included_nodes.include?(nodeA)
			included_nodes << nodeA
			node_A = g.add_nodes(nodeA)
			node_A[:label] = "{ #{nodeA} |{#{node_attributes["#{nodeA}"].join("| ")}}}"
		end
		if !included_nodes.include?(nodeB)
			included_nodes << nodeB
			node_B= g.add_nodes(nodeB)
			node_B[:label] = "{ #{nodeB} |{#{node_attributes["#{nodeB}"].join("| ")}}}"
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

puts "Getting the headers and looking for differences..."
headers = get_headerNcompare(files)


makegraph(headers, options[:output])