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

  def oe_form_button(form, attrs)
    block = <<-eos
    <button class="oe_button oe_form_button" type="#{attrs[:type]}" style="#{attrs[:style]}"}">
        <span>#{attrs[:string]}</span>
    </button>
    eos
    block.html_safe
  end

  def oe_image_field(form, name, attrs) #TODO
    block = <<-eos
<span class="oe_form_field oe_form_field_image oe_left oe_avatar">
<img border="1" name="image" src="http://localhost:8069/web/binary/image?model=res.partner&amp;id=6&amp;field=image_medium&amp;t=1367894577446&amp;session_id=4cc76635f8ab42f7957041d38956836e" style="max-width: 90px; max-height: 90px; margin-left: 0px; margin-top: 0px;"/>
</span>
    eos
    block.html_safe
  end

  def oe_form_label(form, attrs)
    @labels ||= {}
    @labels[attrs[:for]] = attrs[:string]
    return ""
  end

  def oe_form_field(form, attrs) #TODO other OE attrs!
p "************", attrs, @fields
    attrs.each {|k, v| attrs[k] = (v == "" ? nil : v)}
    name = attrs.delete(:name)

    options = {}.merge({style: attrs[:style] || {}}).merge({class: attrs[:class], placeholder: attrs[:placeholder]})
    options.delete(:width)
    options.delete('width')
    options.delete(:style).delete('width')

    if attrs[:widget] == 'image'
      return oe_image_field(form, name, attrs)
    end

    if @abstract_model.columns_hash[name] && ![:selection, :html].index(@abstract_model.columns_hash[name][:type]) && !attrs[:invisible]
      opts = {}
      opts[:as] = @abstract_model.columns_hash[name][:type]
      options[:class] = "#{options[:class]} span3" unless (opts[:as] == :boolean || opts[:as] == :text)
      opts[:input_html] = options #TODO more stuff
      opts[:disabled] = true if attrs[:readonly] || @abstract_model.columns_hash[name]['readonly']
      opts[:wrapper_html] = {class: "field"}
  
      if opts[:as] == :text
        opts[:wrapper_html] = {class: "field span6"}
      end
  
      if attrs[:nolabel]
        if @labels[name] #TODO study if we can do closer to OE
          opts[:label] = attrs[:string] || @fields[name]['string']
          opts[:label_html] = {class: "span3"}
        else
          opts[:label] = false
        end
      else
        opts[:label] = attrs[:string] || @fields[name]['string']
        opts[:label_html] = {class: "span3"}#unless opts[:as] == :text
      end
      
      opts[:placeholder] = attrs[:placeholder]
  #    opts[:hint] =  @abstract_model.columns_hash[name]['help'] || attrs[:help] #works but hugly -> do it with mouseover
      opts[:required] = @abstract_model.columns_hash[name]['required'] || attrs[:required]
      return form.input name, opts #as: @abstract_model.columns_hash[name][:type] if @abstract_model.columns_hash[name]
    end



    if (@fields[name] && @fields[name]['type'] == 'many2one')
      opts = {}#{context: @context}#{collection: content_type_options}
    #  return form.input name, opts
      reflection = @abstract_model.reflect_on_association(name)
    #  opts[:collection] = reflection.klass.all(reflection.options.slice(:conditions, :order).merge(context: @context))
      opts[:collection] = reflection.klass.find(:all, fields: ['name'], limit: 5, context: @ooor_context) #TODO domain + no limit
      opts[:wrapper_html] = {class: "field"}
      opts[:label_html] = {class: "span3"}
      return form.association name, opts
    end

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
#          block = form.input attrs[:name] #form.text_field(name, options)
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
        op_ids = rel.search([], 0, 8, false, @ooor_context) #TODO limit!
        opts = rel.read(op_ids, ['id', 'name'], @ooor_context).map {|i| [i["name"], i["id"]]}
        if @object.associations[name]
          options.merge(:selected => @object.associations[name][0])
        end
        block = form.select(name, options_for_select(opts), options.merge(:include_blank => true))
      when 'many2many'
        rel = @abstract_model.const_get(@fields[name]['relation'])
        op_ids = rel.search([], 0, 8, false, @ooor_context) #TODO limit!
        opts = rel.read(op_ids, ['id', 'name'], @ooor_context).map {|i| [i["name"], i["id"]]}
        block = form.select(name, options_for_select(opts), options.merge({:multiple => true, :class => "chzn-select", :style => "width:450px;", :include_blank => true }))
      else
#        block = "TODO", name, @fields["type"] #TODO
      end

      block = "<div class='input field'>#{form.label(name, (@fields[name]['string'] || name), {class: 'control-label span3'})}#{block}</div>" # if label
      return block.html_safe
    end
  end


end
#end
