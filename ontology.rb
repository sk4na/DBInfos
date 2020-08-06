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
    records << fields 
  end
  records[mondo_code] = omim_related
  return records
end