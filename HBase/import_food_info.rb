import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'
import 'javax.xml.stream.XMLStreamConstants'

def jbytes( *args )
  args.map { |arg| arg.to_s.to_java_bytes }
end

factory = javax.xml.stream.XMLInputFactory.newInstance
reader = factory.createXMLStreamReader(java.lang.System.in)

document = nil
buffer = nil
count = 0

table = HTable.new(@hbase.configuration, 'foods')
table.setAutoFlush(false)

while reader.has_next
  type = reader.next

  if type == XMLStreamConstants::START_ELEMENT
    case reader.local_name
    when 'Food_Display_Row' then
      document = {}
    when /Portion_Display_Name/ then
      buffer = buffer
    when /Display_Name|Portion_Amount|Calories|Saturated_Fats/ then
      buffer =[]
    end
  elsif type == XMLStreamConstants::CHARACTERS
    buffer << reader.text unless buffer.nil?
  elsif type == XMLStreamConstants::END_ELEMENT
    case reader.local_name
    when 'Portion_Display_Name' then
      document['Portion'] = buffer.join      
    when /Display_Name|Calories|Saturated_Fats/ then
      document[reader.local_name] = buffer.join
    when 'Food_Display_Row' then
      key = document['Display_Name'].to_java_bytes
      p = Put.new(key)

      p.add(*jbytes("info", "calories",document['Calories']))
      p.add(*jbytes("info", "saturated fats", document['Saturated_Fats']))
      p.add(*jbytes("info", "portion", document['Portion']))

      table.put(p)

      count += 1
      table.flushCommits() if count % 10 ==0
      if count % 500 == 0
        puts "#{count} records inserted (#{document['Display_Name']})"
      end
    end
  end
end

table.flushCommits()

exit

# to pipe file to script
# curl file:///usr/local/Cellar/hbase/1.1.5_1/libexec/bin/Food_Display_Table.xml |cat| /usr/local/Cellar/hbase/1.1.5_1/libexec/bin/hbase shell import_food_info.rb