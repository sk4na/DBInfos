def load_obo(file, keyword)
  records = {}
  disease_code = nil
  keyword_related = []
  File.open(file).each do |line|
    line.chomp!
    tag, value = line.split(": ", 2)
    if tag == "[Term]"
        if !disease_code.nil?
          records[disease_code] = keyword_related
        end
        keyword_related = []
    elsif tag == 'id'
      disease_code = value
    elsif tag == 'xref'
      xcode, xmetadata = value.split(' ')     
      keyword_related << xcode if xcode.include?(keyword)
    end
  end
  records[disease_code] = keyword_related ## Esta linea hace falta para guardar el caso final  
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