require 'simple_form'
require 'simple_form/form_builder'

module Aktooor
  class FormBuilder < SimpleForm::FormBuilder

    def oe_form_label(attrs)
      @labels ||= {}
      @labels[attrs[:for]] = attrs[:string]
      return ""
    end

    def oe_form_button(attrs)
      block = <<-eos
      <button class="oe_button oe_form_button" type="#{attrs[:type]}" style="#{attrs[:style]}"}">
        <span>#{attrs[:string]}</span>
      </button>
      eos
      block.html_safe
    end

    def oe_image_field(name, attrs) #TODO
      block = <<-eos
<img src='data:image/png;base64,#{@object.send(name)}'/>
#{file_field :file}
      eos
      block.html_safe
    end

  def oe_form_field(attrs) #TODO other OE attrs!
    attrs.each {|k, v| attrs[k] = (v == "" ? nil : v)}
    name = attrs.delete(:name)

    options = {}.merge({style: attrs[:style] || {}}).merge({class: attrs[:class], placeholder: attrs[:placeholder]})
    options.delete(:width)
    options.delete('width')
    options.delete(:style).delete('width')

    if attrs[:widget] == 'image'
      return oe_image_field(name, attrs)
    end

    if @object.class.columns_hash[name] && ![:selection, :html].index(@object.class.columns_hash[name][:type]) && !attrs[:invisible]
      opts = {}
      opts[:as] = @object.class.columns_hash[name][:type]
      options[:class] = "#{options[:class]} span3" unless (opts[:as] == :boolean || opts[:as] == :text)
      opts[:input_html] = options #TODO more stuff
      opts[:disabled] = true if attrs[:readonly] || @object.class.columns_hash[name]['readonly']
      opts[:wrapper_html] = {class: "field"}

      if opts[:as] == :text
        opts[:wrapper_html] = {class: "field span6"}
      end

      if attrs[:nolabel]
        if @labels[name] #TODO study if we can do closer to OE
          opts[:label] = attrs[:string] || fields[name]['string']
          opts[:label_html] = {class: "span3"}
        else
          opts[:label] = false
        end
      else
        opts[:label] = attrs[:string] || fields[name]['string']
        opts[:label_html] = {class: "span3"}#unless opts[:as] == :text
      end

      opts[:placeholder] = attrs[:placeholder]
  #    opts[:hint] =  @abstract_model.columns_hash[name]['help'] || attrs[:help] #works but hugly -> do it with mouseover
      opts[:required] = @object.class.columns_hash[name]['required'] || attrs[:required]
      return input name, opts #as: @abstract_model.columns_hash[name][:type] if @abstract_model.columns_hash[name]
    end



    if (fields[name] && fields[name]['type'] == 'many2one')
#      if @object.attributes[fields[name]] #TODO
      rel_name = "#{name}_id"
      rel_id = @object.send(rel_name.to_sym)
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/aktooor/#{rel_path}.json"
      if rel_id
        rel_value = @object.send(name.to_sym).name
      else
        rel_value = ''
      end
      block = "<input type='hidden' id='#{name}' name='#{@object.class.name}[#{name}]' value='#{rel_id}' value-name='#{rel_value}'/>"

@template.content_for :js do
"
$(document).ready(function() {
  $('##{name}').select2({
    placeholder: '#{fields[name]['string']}',
    width: 300,
    minimumInputLength: 2,
    formatSelection: function(category) {
      return category.name;
    },
    initSelection: function (element, callback) {
      var elementText = $(element).attr('value-name');
      callback({name: elementText});
    },
    formatResult: function(item) {
      return item.name;
    },
    ajax: {
      url: '#{ajax_path}',
      quietMillis: 100,
      data: function (name, page) {
        return {
          q: name, // search term
          limit: 20,
          fields: ['name']
        }
      },
      dataType: 'json',
      results: function(data, page) {
        return { results: $.map( data, function(categ, i) {
          return categ;
        } ) }
      }
    }
  });
});
".html_safe
end

      return block.html_safe
    end

    if false #FIXME remove
      opts = {}#{context: @context}#{collection: content_type_options}
    #  return input name, opts
      reflection = @object.class.reflect_on_association(name)
    #  opts[:collection] = reflection.klass.all(reflection.options.slice(:conditions, :order).merge(context: @context))
      opts[:collection] = reflection.klass.find(:all, fields: ['name'], limit: 5, context: @ooor_context) #TODO domain + no limit
      opts[:wrapper_html] = {class: "field"}
      opts[:label_html] = {class: "span3"}
      return association name, opts
    end

    block = ""

    if fields[name]
      if attrs[:nolabel]
        label = false
      else
        label = true
      end

      if attrs[:invisible]
        block = hidden_field(name, options)
        label = false
      elsif attrs[:readonly]
        options['disabled'] = 'disabled'
      end

      case fields[name]['type']
      when 'char'
        if attrs['widget'] == 'password'
          block = password_field(name, options)
        else
          block = text_field(name, options)
#          block = form.input attrs[:name] #form.text_field(name, options)
        end
      when 'text'
        block = text_area(name, options)
      when 'boolean'
        block = check_box(name, options)
      when 'integer', 'float'
        block = number_field(name, options)
      when 'date'
        block = date_select(name, options)
      when 'datetime'
        block = datetime_select(name, options)
      when 'time'
        block = select_time(name, options)
#      when 'binary'
#        "<img src='data:image/jpeg;base64,<%=  @base_64_encoded_data %>'>"
      when 'selection'
        block = select(name, @template.options_for_select(fields[name]["selection"].map{|i|[i[1], i[0]]}), options)
      when 'many2one'
        rel = @object.class.const_get(fields[name]['relation'])
        op_ids = rel.search([], 0, 8, false, ooor_context) #TODO limit!
        opts = rel.read(op_ids, ['id', 'name'], ooor_context).map {|i| [i["name"], i["id"]]}
        if @object.associations[name]
          options.merge(:selected => @object.associations[name][0])
        end
        block = select(name, @template.options_for_select(opts), options.merge(:include_blank => true))
      when 'many2many'
        rel = @object.class.const_get(fields[name]['relation'])
        op_ids = rel.search([], 0, 8, false, ooor_context) #TODO limit!
        opts = rel.read(op_ids, ['id', 'name'], ooor_context).map {|i| [i["name"], i["id"]]}
        block = select(name, @template.options_for_select(opts), options.merge({:multiple => true, :class => "chzn-select", :style => "width:450px;", :include_blank => true }))
      else
#        block = "TODO", name, @fields["type"] #TODO
      end

      block = "<div class='input field'>#{label(name, (fields[name]['string'] || name), {class: 'control-label span3'})}#{block}</div>" # if label
      return block.html_safe
    end
  end

    private

      def fields
        @template.instance_variable_get('@fields')
      end

      def ooor_context
        @template.instance_variable_get('@ooor_context')
      end

  end
end
