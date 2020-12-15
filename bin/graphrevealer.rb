#! /usr/bin/env ruby

require 'optparse'
require 'ruby-graphviz'
require 'zlib'

############################################################################################
## METHODS
############################################################################################
def attribute_parser(attrib)
	if attrib.include?(":") && !attrib.include?("#")
		attrib = attrib.split(":").first
	elsif attrib.include?("#")
		attrib = attrib.split("#").last
	end
	return attrib			
end	

def check_headers(hash)
    attributes_count_grouped = {}
    hash.each do |file_path, attributes|
    	n_fields = attributes.keys.count
    	query = attributes_count_grouped[n_fields]
    	if query.nil? 
    		attributes_count_grouped[n_fields] = [file_path]
    	else
    		query << file_path
    	end
    end
    length = attributes_count_grouped.length
    if length != 1
    	puts "WARNING!! NOT ALL HEADERS HAVE EQUAL LENGTH:"
    	attributes_count_grouped.each do |n_fields, file_paths|
    		file_paths.each do |file_path|
    			puts "#{file_path}\t#{n_fields} attributes"
    		end
    	end
    else
    	puts "All headers have equal length"
    end		
end

def get_attributes(file_list)
	attributes = {}
	file_list.each do |file|
		header_fields = []
		header_values = {}
		Zlib::GzipReader.open(file) { |gz|
			check_header = true
			gz.each do |line|
				fields = line.chomp.split("\t")
				if check_header
					header_fields = fields		
					check_header = false
				else
					field_values = fields
					field_values.each_with_index do |value, i|
						value = attribute_parser(value)
						field = header_fields[i]	
						query = header_values[field] 
						if query.nil?
							if header_fields
							header_values[field] = [value]
							end
						else
							query << value #unless query.include?(value)
						end
					end
				end				
			end	
		}
		header_values.keys.each do |key|
			# puts "#{file}		#{key}		#{header_values[key].first}"
			if header_values[key].length > 10
				header_values[key] = "test"
			end	
		end	
		attributes[file] = header_values		
	end
	return attributes	
end

def load_value(hash_to_load, key, value)
	query = hash_to_load[key]
		if query.nil?
			hash_to_load[key] = value
		else
			query << value
		end	
end	

def attr_merger(files_hash, nodes, node_attributes)
	nodeX_attributes = {}
	nodes_attributes = {}
	nodes.each do |node|
		files_hash.each do |file_path, header_with_values|
			if file_path.include?(node)
				pair = File.basename(file_path, '.all.tsv.gz').split("_")
				nodeA, nodeB = pair
				node_attributes.each do |attribute|
					value = header_with_values[attribute]
					puts value
					if nodeA == node
						if attribute == "subject"
							load_value(nodeX_attributes, "id", value)
						elsif attribute == "subject_label"
							load_value(nodeX_attributes, "label", value)
						elsif attribute == "subject_taxon"
							load_value(nodeX_attributes, "taxon", value)
						elsif attribute == "subject_taxon_label"
							load_value(nodeX_attributes, "taxon_label", value)
						end
					elsif nodeB == node
						if attribute == "object"
							load_value(nodeX_attributes, "id", value)
						elsif attribute == "object_label"
							load_value(nodeX_attributes, "label", value)
						end	
					end
				end
			end
		end
	nodes_attributes[node] = nodeX_attributes	
	end	
	return nodes_attributes										
end	

def build_label_relation(relation, attributes, attribute_values)
	str = ""
	str << "{ #{relation.join('_')} | "
	attributes[relation].each_with_index do |attribute, i| 
		str << "{#{attribute}| #{attribute_values["#{attribute}"]}}"
		str << "|" unless i == attributes[relation].length - 1
	end
	str << "}"
	return str
end

def build_label_nodes(node, nodes_with_attributes)
	str = ""
	str << "{ #{node} | "
	nodes_with_attributes[node].keys.each_with_index do |attribute, i|
		str << "{#{attribute}| #{nodes_with_attributes[attribute]}}"
		str << "|" unless i == nodes_with_attributes[node].keys.length - 1
	end
	str << "}"
	return str
end		

def get_relations_attributes(headers)
	attributes = {}
	headers.each do |pair, header|
		attributes[pair] = header.reject {|attrib| attrib.include?("subject") || attrib.include?("object")}
	end
	return attributes
end

def get_nodes_attributes(headers)
	attributes = {}
	headers.each do |pair, header|
		nodeA, nodeB = pair
		if !attributes.keys.include?(nodeA)
			attributes[nodeA] = header.select {|attrib| attrib.include?("subject") || attrib.include?("object")}
		end	
		if !attributes.keys.include?(nodeB)
			attributes[nodeB] = header.select {|attrib| attrib.include?("subject") || attrib.include?("object")}
		end	
	end
	return attributes
end

def makegraph(files, arr_nodes, nodes_with_attributes, relation_attributes, attribute_values, output_path)
	## Creating graph and setting global attributes ##
	g = GraphViz.new( :G, :type => :digraph )
	g.node[:shape] = "record"
	g[:nodesep] = 0.3

	## Adding the nodes and setting up the structure of their attributes ##
	included_nodes = []
	arr_nodes.each_with_index do |nodeAnodeB, i|
		actual_file = nil
		files.each do |file|
			if file.include?("#{nodeAnodeB.join('_')}")
				actual_file = file
			end
		end		
		nodeA, nodeB = nodeAnodeB
		relation = g.add_nodes(nodeAnodeB.join('_'))
		relation[:label] = build_label_relation(nodeAnodeB, relation_attributes, attribute_values[actual_file])
		relation[:color] = "green"
		if !included_nodes.include?(nodeA)
			included_nodes << nodeA
			node_A = g.add_nodes(nodeA)
			node_A[:label] = build_label_nodes(nodeA, nodes_with_attributes)
		end
		if !included_nodes.include?(nodeB)
			included_nodes << nodeB
			node_B = g.add_nodes(nodeB)
			node_B[:label] = build_label_nodes(nodeB, nodes_with_attributes)
		end

		## Assigning the edges ##
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
attributes = get_attributes(files[0..1])
#check_headers(attributes)	

## Getting nodes and relations ##
pairs_with_field_data = {}
nodes = []
attributes.each do |file_path, field_and_values|
	pair = File.basename(file_path, '.all.tsv.gz').split("_")
	pair.each do |node|
		nodes << node
	end	
	pairs_with_field_data[pair] = field_and_values.keys
end
relations = pairs_with_field_data.keys


## Getting attributes for nodes and their relations ##
node_attributes = get_nodes_attributes(pairs_with_field_data)
relation_attributes = get_relations_attributes(pairs_with_field_data)

## Creating hash with node name and the values of their attributes, obtained from merging the values of all different files for each node ##
nodes_with_attributes = attr_merger(attributes, nodes, node_attributes)

# makegraph(files, relations, nodes_with_attributes, relation_attributes, attributes, options[:output])