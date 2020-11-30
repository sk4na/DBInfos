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

def check_headers(hash)
    values_count_grouped = {}
    hash.each do |k, v|
    	n_fields = v.count
    	query = values_count_grouped[n_fields]
    	if query.nil? 
    		values_count_grouped[n_fields] = [k]
    	else
    		query << k
    	end
    end
    length = values_count_grouped.length
    if length != 1
    	puts "WARNING!! NOT ALL HEADERS HAVE EQUAL LENGTH:"
    	values_count_grouped.each do |n_fields, file_paths|
    		file_paths.each do |file_path|
    			puts "#{file_path}\t#{n_fields} attributes"
    		end
    	end
    else
    	puts "All headers have equal length"
    end		
end

def get_headers(file_list)
	headers = {}
	file_list.each do |file|
		Zlib::GzipReader.open(file) { |gz|
			headers[file] = gz.readline.chomp.split("\t")
		}	
	end
	return headers		
end

def get_relations_attributes(headers)
	attributes = {}
	headers.each do |pair, header|
		attributes[pair] = attr_parser(header.reject {|attrib| attrib.include?("subject") || attrib.include?("object")})
	end
	return attributes
end

def get_nodes_attributes(headers)
	attributes = {}
	headers.each do |pair, header|
		nodeA, nodeB = pair
		if !attributes.keys.include?(nodeA)
			attributes[nodeA] = attr_parser(header.select {|attrib| attrib.include?("subject") || attrib.include?("object")})
		end	
		if !attributes.keys.include?(nodeB)
			attributes[nodeB] = attr_parser(header.select {|attrib| attrib.include?("subject") || attrib.include?("object")})
		end	
	end
	return attributes
end

def makegraph(arr_nodes, node_attributes, relation_attributes, output_path)
	## Creating graph and setting global attributes ##
	g = GraphViz.new( :G, :type => :digraph )
	g.node[:shape] = "record"

	## Assigning the edges ##
	included_nodes = []
	arr_nodes.each_with_index do |nodeAnodeB, i|
		nodeA, nodeB = nodeAnodeB
		relation = g.add_nodes(nodeAnodeB.join('_'))
		relation[:label] = "{ #{nodeAnodeB.join('_')} |{#{relation_attributes[nodeAnodeB].join("| ")}}}"
		relation[:color] = "green"
		if !included_nodes.include?(nodeA)
			included_nodes << nodeA
			node_A = g.add_nodes(nodeA)
			node_A[:label] = "{ #{nodeA} |{#{node_attributes[nodeA].join("| ")}}}"
		end
		if !included_nodes.include?(nodeB)
			included_nodes << nodeB
			node_B= g.add_nodes(nodeB)
			node_B[:label] = "{ #{nodeB} |{#{node_attributes[nodeB].join("| ")}}}"
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
headers = get_headers(files)
check_headers(headers)

pairs_with_field_data = {}
headers.each do |file_path, fields|
	pair =File.basename(file_path, '.all.tsv.gz').split("_")
	pairs_with_field_data[ pair] = fields
end

## Getting nodes ##
relations = pairs_with_field_data.keys

## Getting attributes for nodes and their relations ##
node_attributes = get_nodes_attributes(pairs_with_field_data)
relation_attributes = get_relations_attributes(pairs_with_field_data)

makegraph(relations, node_attributes, relation_attributes, options[:output])