require 'simple_form'
require 'simple_form/form_builder'

module Aktooor
  class FormBuilder < SimpleForm::FormBuilder

    def ooor_input(attribute_name, attrs={}, &block)
      attribute_name = attribute_name.to_s
      options = {}
      attrs.each { |k, v| options[k] = v if v && !v.blank? }
      options[:oe_type] = options[:widget] || fields[attribute_name]['type']
      options[:as] = Ooor::Base.to_rails_type(options[:oe_type])
      options[:hint] ||= fields[attribute_name]['help']
      options[:required] ||= fields[attribute_name]['required'] || false
      options[:style] ||= {}
      options.delete(:width)
      options.delete('width')
      options.delete(:style).delete('width')

      options[:disabled] = true if options.delete(:readonly) || fields[attribute_name]['readonly']
      options[:as] = 'hidden' if options[:invisible]
      adapt_label(attribute_name, options)
      dispatch_input(attribute_name, options)
    end

    def adapt_label(attribute_name, options)
      if options[:nolabel]
        if @labels[attribute_name] #TODO study if we can do closer to OE
          options[:label] ||= fields[attribute_name]['string']
          options[:label_html] = {class: "col-md-3"}
        else
          options[:label] = false
        end
      else
        options[:label] ||= fields[attribute_name]['string']
      end
    end

    def oe_form_label(attrs)
      @labels ||= {}
      @labels[attrs[:for]] = attrs[:label]
      return ""
    end

    def ooor_button(label, options)
      @template.link_to(label, options) do
        "<button type='button' class='btn btn-primary'>#{label}</button>".html_safe #todo Bootstrap icon?
      end
    end

    def ooor_image_field(name, options)
      self.multipart = true
      if fields[name]['type'] == 'char' # it's just an image URL, image binary shouldn't be posted to OpenERP!
        method = "ooor_special_file_#{name}"
        url = @object.attributes[name] || @object.send(name) || "http://www.placehold.it/180x180/EFEFEF/AAAAAA&text=#{I18n.t('No+Image', :default => 'No+Image')}"
        image_placeholder = "<img src='#{url}' />"
      else
        method = name
        image_placeholder = "<img src='data:image/png;base64,#{@object.send(name)}' />"
      end
"<div class='form-group input string field'/>#{label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])}<div class='controls'>
<div class='fileupload fileupload-new' data-provides='fileupload'>
  <div class='fileupload-new thumbnail' style='width: 200px; height: 150px;'>
#{image_placeholder}
  </div>
  <div class='fileupload-preview fileupload-exists thumbnail' style='max-width: 200px; max-height: 150px; line-height: 20px;'></div>
  <div>
    <span class='btn btn-file'>
      <span class='fileupload-new'>Select image</span>
      <span class='fileupload-exists'>Change</span>
#{file_field(method, options)}
    </span>
    <a href='#' class='btn fileupload-exists' data-dismiss='fileupload'>Remove</a>
  </div>
</div></div></div>".html_safe
    end

    def ooor_many2one_field(name, options)
      rel_name = "#{name}_id"
      if @object.associations[name]
        if @object.associations[name].is_a?(Array)
          rel_id = @object.associations[name][0]
          rel_value = @object.associations[name][1]
        else
          rel_id = @object.associations[name]
          rel_klass = @object.class.const_get(@object.class.all_fields[name]['relation'])
          rel_value = rel_klass.name_get([rel_id.to_i], ooor_context)[0][1]
        end
      else
        rel_id = @object.associations[name] || @object.send(rel_name.to_sym)
        if rel_id
          rel_klass = @object.class.const_get(@object.class.all_fields[name]['relation'])
          rel_value = rel_klass.name_get([rel_id.to_i], ooor_context)[0][1]
        else
          rel_value = ''
        end
      end

      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json"
      block = "<div class='form-group input string field'/>#{label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])}<div class='controls'><input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_id}' value-name='#{rel_value}'/></div></div>"

@template.content_for :js do
"
$(document).ready(function() {
  $('##{@object_name}_#{name}').select2({
    placeholder: '#{fields[name]['string']}',
    width: 'element',
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
if (#{options[:disabled] == true}) {
  $('##{@object_name}_#{name}').select2('readonly', true);
}
});
".html_safe
end

      return block.html_safe
    end

    def ooor_many2many_field(name, options)
      rel_name = "#{name}_ids"
      val = @object.send(rel_name.to_sym)
      val = [] if !val || val == ""
      if val.is_a?(String)
        val = val.split(",").map! {|i| i.to_i} #FIXME remove?
      end
      
      rel_ids = val.join(',')
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json" #TODO use URL generator
      if rel_ids
        objects = @object.send(name.to_sym)
        if objects && !objects.is_a?(Array)
          objects = [objects]
        end
        if objects
          rel_value = objects.map {|i| i.name}.join(',')
        else
          rel_value = ''
        end
      else
        rel_value = ''
      end
      block = "<div class='form-group input string field'/>#{label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])}<div class='controls'><input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_ids}' value-name='#{rel_value}'/></div></div>"

@template.content_for :js do
"
$(document).ready(function() {
  $('##{@object_name}_#{name}').select2({
    placeholder: '#{fields[name]['string']}',
    width: 'element',
    minimumInputLength: 2,
    multiple:true,
    maximumSelectionSize: 15,
    formatSelection: function(category) {
      return category.name;
    },
    initSelection : function (element, callback) {
        var data = [];
        var ids = $(element).attr('value').split(',')
        var c = 0;
        $($(element).attr('value-name').split(',')).each(function () {
            data.push({name: this, id: ids[c]});
            c += 1;
        });
        callback(data);
    },
    formatResult: function(item) {
      return item.name;
    },
    ajax: {
      url: '#{ajax_path}',
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

if (#{options[:disabled] == true}) {
  $('##{@object_name}_#{name}').select2('readonly', true);
}
});
".html_safe
end
      return block.html_safe
    end

    def dispatch_input(name, options={}) #TODO other OE attrs!
      case options[:oe_type]
      when 'image'
        ooor_image_field(name, options)
      when 'many2one'
        ooor_many2one_field(name, options)
      when 'many2many'
        ooor_many2many_field(name, options)
      when 'many2many_tags'
        ooor_many2many_field(name, options)
      when 'mail_followers'
        ooor_many2many_field(name, options)
      when 'html'
        text_area(name, options)
      when 'selection'
        selected = @object.send(name.to_sym)
        selected_value = selected.is_a?(Ooor::Base) ? selected.id : selected
        input name, options.merge(collection: fields[name]['selection'].map{|i|[i[1], i[0]]}, as: 'select', selected: selected_value)
      when 'statusbar'
        input name, options.merge(collection: fields[name]['selection'].map{|i|[i[1], i[0]]}, as: 'select')
      #simple_form from now on:
      when 'one2many'
         "TODO one2many #{name}"
#        collection(name, options)
      when 'mail_thread'
        "TODO mail_thread #{name}"
      else
        input(name, options)
      end
    end

    private

      def fields
        @template.instance_variable_get('@fields') || @object.class.all_fields
      end

      def ooor_context
        @template.instance_variable_get('@ooor_context')
      end

  end
end
