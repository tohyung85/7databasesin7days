import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'

def jbytes (*args)
  args.map { |arg| arg.to_s.to_java_bytes } 
end

def put_many(table_name, row, column_values)
  table = HTable.new(@hbase.configuration, table_name)
  p = Put.new(*jbytes(row))
  column_values.each do |key, val| 
    key_arr = key.split(":")    
    family = key_arr[0]
    qualifier = key_arr[1].nil? ? "" : key_arr[1]
    print family + " " + qualifier
    p.add(*jbytes(family, qualifier, val))
  end

  table.put(p)

  return "ok"
end

# Input data
# put_many 'wiki', 'Some title', {
#      "text:" => "some article text",
#      "revision:author" => "jschmoe",
#      "revision:comment" => "no comment" }