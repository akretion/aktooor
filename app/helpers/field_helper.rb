#module AktOoor
module FieldHelper

  def oe_field(obj, attrs)
    name = attrs[:name]
    if @fields[name]
      case @fields[name]['type']
      when 'many2one'
        obj.associations[name] && obj.associations[name][1]
      else
        obj.send(name.to_sym)
      end
    end
  end

end
#end
