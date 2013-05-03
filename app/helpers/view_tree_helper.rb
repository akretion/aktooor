#module AktOoor
  module ViewTreeHelper

    def table_header
      block = ""
      @fields.keys.each do |k|
        block << "<th>#{@fields[k]["string"]}</th>"
      end
      block.html_safe
    end

  end
#end

