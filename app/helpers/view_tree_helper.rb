#module AktOoor
  module ViewTreeHelper

    def table_header
      block = ""
      @field_list.each do |k|
        block << "<th>#{k}</th>"
      end
      block.html_safe
    end

  end
#end

