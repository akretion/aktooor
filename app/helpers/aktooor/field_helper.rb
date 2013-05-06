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

  def oe_form_field(form, attrs) #TODO other OE attrs!
    attrs.each {|k, v| attrs[k] = (v == "" ? nil : v)}
    name = attrs[:name]
    options = {}.merge({style: attrs[:style]}).merge({class: attrs[:class], placeholder: attrs[:placeholder]})
    block = ""

    if @fields[name]
      if attrs[:nolabel]
        label = false
      else
        label = true
      end

      if attrs[:invisible]
        block = form.hidden_field(name, options)
        label = false
      elsif attrs[:readonly]
        options['disabled'] = 'disabled'
      end

      case @fields[name]['type']
      when 'char'
        if attrs['widget'] == 'password'
          block = form.password_field(name, options)
        else
          block = form.text_field(name, options)
        end
      when 'text'
        block = form.text_area(name, options)
      when 'boolean'
        block = form.check_box(name, options)
      when 'integer', 'float'
        block = form.number_field(name, options)
      when 'date'
        block = form.date_select(name, options)
      when 'datetime'
        block = form.datetime_select(name, options)
      when 'time'
        block = form.select_time(name, options)
#      when 'binary'
#        "<img src='data:image/jpeg;base64,<%=  @base_64_encoded_data %>'>"
      when 'selection'
        block = form.select(name, options_for_select(@fields[name]["selection"].map{|i|[i[1], i[0]]}), options)
      when 'many2one'
        rel = @abstract_model.const_get(@fields[name]['relation'])
        op_ids = rel.search #TODO limit!
        opts = rel.read(op_ids, ['id', 'name']).map {|i| [i["name"], i["id"]]}
        block = form.select(name, options_for_select(opts), options.merge(:include_blank => true))
      when 'many2many'
        rel = @abstract_model.const_get(@fields[name]['relation'])
        op_ids = rel.search #TODO limit!
        opts = rel.read(op_ids, ['id', 'name']).map {|i| [i["name"], i["id"]]}
        block = form.select(name, options_for_select(opts), options.merge({:multiple => true, :class => "chzn-select", :style => "width:450px;", :include_blank => true }))
      else
#        block = "TODO", name, @fields["type"] #TODO
      end

      block = "#{form.label(name, @fields[name]['string'] || name, class: 'control-label span2')}#{block}" if label
      return block.html_safe
    end
  end


  end
#end

