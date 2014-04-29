#require 'aktooor/form_transformer'

module Aktooor
  # a poor's man table component (OpenERP list view)
  class TableBuilder
    include FormTransformer

    def initialize(abstract_model, objects, template, options)
      @abstract_model, @objects, @template, @options = abstract_model, objects, template, options
    end

    def table_header
      block = ""
      field_list.each do |k|
        block << "<th>#{k}</th>"
      end
      block.html_safe
    end

    def oe_field(obj, attrs)
      name = attrs[:name]
      fields = fields_view_get_meta()[3]
      case fields[name]['type']
      when 'many2one'
        obj.associations[name] && obj.associations[name][1]
      else
        obj.send(name.to_sym)
      end
    end
   
  end
end
