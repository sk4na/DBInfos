#! /usr/bin/env ruby

require 'optparse'
require 'ruby-graphviz'
require 'zlib'
require 'fileutils'

############################################################################################
## METHODS
############################################################################################
def attribute_parser(attrib)
	if attrib.include?(":") && !attrib.include?("#") && !attrib.include?("/ttl/")
		attrib = attrib.split(":").first
	elsif attrib.include?("#")
		attrib = attrib.split("#").last
	elsif attrib.include?("/ttl/")
		attrib = attrib.split("/ttl/").last		
	end
	return attrib			
end

def parse_attribute(attrib)
	result = []
	if attrib.include?("|")
		result = attrib.split("|").map {|attr| attribute_parser(attr)}
	else	
		result = attribute_parser(attrib)
	end
	return result	
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

def load_tsv_gz_file(file_list, category = nil)
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
					fields.each_with_index do |value, i|
						field = header_fields[i]	
						query = header_values[field] 
						if query.nil?
							if header_fields
							header_values[field] = [value]
							end
						else
							query << value
						end
					end	
				end				
			end	
		}
		attributes[file] = header_values		
	end
	return attributes	
end

def parse_content_for_graph(files_hash)
	parsed_files_hash = {}
	files_hash.each do |file_path, header_with_values|
		parsed_header_with_values = {}
		header_with_values.each do |header, values| 
			parsed_header_with_values[header] = values.map {|attribute| parse_attribute(attribute)}.flatten.uniq
			query = parsed_header_with_values[header]
			if query.length > 10
				parsed_header_with_values[header] = query.first(10)
			end	
		end
		parsed_files_hash[file_path] = parsed_header_with_values	
	end
	return parsed_files_hash	
end		

def get_category_relations(files_hash, category)
	entity2category_relations = {}
	files_hash.each do |file_path, header_with_values|
		nodes = File.basename(file_path, '.all.tsv.gz').split("_")
		object2category_relations = {}
		subject2category_relations = {}
		header_with_values["subject"].each_with_index do |subjectID, i|
			load_value(object2category_relations, header_with_values["object"][i], subjectID) if subjectID.include?(category)
		end
		
		header_with_values["object"].each_with_index do |objectID, i|	
			load_value(subject2category_relations, header_with_values["subject"][i], objectID) if objectID.include?(category)
		end	

		load_hash_value(entity2category_relations, nodes.last, object2category_relations) unless object2category_relations.size < 1
		load_hash_value(entity2category_relations, nodes.first, subject2category_relations) unless subject2category_relations.size < 1
	end
	return entity2category_relations				
end	

def load_value(hash_to_load, key, value)
	query = hash_to_load[key]
	if query.nil?
		value = [value] if value.class != Array
		hash_to_load[key] = value
	else
		if value.class == Array
			query.concat(value)
		else
			query << value
		end
	end	
end

def load_hash_value(hash_to_load, key, value_hash)
	query = hash_to_load[key]
		if query.nil?
			hash_to_load[key] = value_hash
		else
			query.merge(value_hash) {|key, oldval, newval| oldval | newval}
		end
end	

def attr_merger(files_hash)
	nodes_attributes = {}
	files_hash.each do |file_path, header_with_values|
		nodeA, nodeB = File.basename(file_path, '.all.tsv.gz').split("_")
		nodeX_attributes = nodes_attributes[nodeA]
		if nodeX_attributes.nil?
			nodeX_attributes = {}
			nodes_attributes[nodeA] = nodeX_attributes
		end
		%w[subject subject_label subject_taxon subject_taxon_label].each do |attribute|
			value = header_with_values[attribute]
			if attribute == "subject"
				load_value(nodeX_attributes, "id", value)
			elsif attribute == "subject_taxon"
				load_value(nodeX_attributes, "taxon", value)
			end
		end

		nodeX_attributes = nodes_attributes[nodeB]
		if nodeX_attributes.nil?
			nodeX_attributes = {}
			nodes_attributes[nodeB] = nodeX_attributes
		end
		%w[object object_label].each do |attribute|
			value = header_with_values[attribute]
			if attribute == "object"
				load_value(nodeX_attributes, "id", value)
			end	
		end
	end
	nodes_attributes.keys.each do |key|
		nodes_attributes[key].values.map {|val| val.uniq.join(",").split(",").uniq!}
		nodes_attributes[key].values.each do |value|
			value.uniq!
		end	
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
	i = 0
	nodes_with_attributes[node].each do |attribute, attr_values|
		str << "{#{attribute}| #{attr_values}}"
		str << "|" unless i == nodes_with_attributes[node].keys.length - 1
		i = i + 1
	end
	str << "}"
	return str
end		

def get_relations_attributes(headers)
	attributes = {}
	headers.each do |pair, header|
		attributes[pair] = header.reject {|attrib| attrib.include?("subject") || attrib.include?("object") || attrib.include?("label")}
	end
	return attributes
end

def makegraph(files, arr_nodes, nodes_with_attributes, relation_attributes, attribute_values, output_path, simplify)
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
		relation[:label] = build_label_relation(nodeAnodeB, relation_attributes, attribute_values[actual_file]) unless simplify
		relation[:color] = "green"
		if !included_nodes.include?(nodeA)
			included_nodes << nodeA
			node_A = g.add_nodes(nodeA)
			node_A[:label] = build_label_nodes(nodeA, nodes_with_attributes) unless simplify
		end
		if !included_nodes.include?(nodeB)
			included_nodes << nodeB
			node_B = g.add_nodes(nodeB)
			node_B[:label] = build_label_nodes(nodeB, nodes_with_attributes) unless simplify
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

  options[:input_folder] = nil
  opts.on("-i", "--input_folder PATH", "Path to folder with Monarch data") do |item|
    options[:input_folder] = item
  end

  options[:category] = nil
  opts.on("-c", "--category STRING", "Name of the category wanted to be searched through the files") do |item|
    options[:category] = item
  end

  options[:output] = 'monarch_output_data'
  opts.on("-o", "--output_path PATH", "Name of the folder that will recieve the output from category matches") do |item|
  	options[:output] = item
  end	

  options[:graph] = nil
  opts.on("-g", "--graph PATH", "If a graph is desired, write output path here") do |item|
    options[:graph] = item
  end

  options[:simplify] = false
  opts.on("-s", "--simplify", "If true, the outputted graph will be simplified to display only the connections between entities") do
    options[:simplify] = true
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
files = Dir.glob(File.absolute_path(File.join(options[:input_folder], '*.all.tsv.gz')))
files_content = load_tsv_gz_file(files)
if options[:graph]
	puts "Getting the headers and looking for differences..."
	attributes = parse_content_for_graph(files_content)

	#check_headers(attributes)	

	## Getting nodes and relations ##

	pairs_with_field_data = {}
	attributes.each do |file_path, field_and_values|
		pair = File.basename(file_path, '.all.tsv.gz').split("_")
		pairs_with_field_data[pair] = field_and_values.keys
	end
	relations = pairs_with_field_data.keys

	relation_attributes = get_relations_attributes(pairs_with_field_data)

	## Creating hash with node name and the values of their attributes, obtained from merging the values of all different files for each node ##
	nodes_with_attributes = attr_merger(attributes)

	makegraph(files, relations, nodes_with_attributes, relation_attributes, attributes, options[:graph], options[:simplify])
end
if options[:category]
	puts "Looking for matches with #{options[:category]}"
	FileUtils.mkdir_p "#{options[:output]}"
	category_relations = get_category_relations(files_content, options[:category])
	category_relations.each do |entity, ids_to_category_matches|
		ids_to_category_matches.each do |id, category_match|
			File.open("#{options[:output]}/#{entity}_#{options[:category]}.txt", 'a') { |file| file.write("#{id}\t#{category_match.join(",")}\n") }
		end		
	end	
end	
