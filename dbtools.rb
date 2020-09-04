def load_obo(file)
  records = {}
  mondo_code = nil
  omim_related = nil
  File.open(file).each do |line|
    line.chomp!
    tag, value = line.split(": ", 2)
    if tag == "[Term]"
        if !mondo_code.nil?
          records[mondo_code] = omim_related
        end
    elsif tag == 'id'
      mondo_code = value
    elsif tag == 'xref'
      xcode, xmetadata = value.split(' ')
      if xcode.include?('OMIM')
        omim_related = xcode
      end
    end
    records[mondo_code] = omim_related
  end
  return records
end

def load_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def load_tabular_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def load_id_file(file)
  records = []
  File.open(file).each do |line|
    records << line.chomp
  end
 return records
end

def get_ids(relations)
  ids = []
  relations.each do |relation|
    ids << relation[0]
  end
  ids = ids.uniq
  return ids  
end  

def get_disease2phen(relations, diseaseID)
  disease2phenotypes = []
  relations.each do |relation|
    listed_disease_id, related_code = relation
    if listed_disease_id == diseaseID
      disease2phenotypes << relation
    end
  end
  return disease2phenotypes
end