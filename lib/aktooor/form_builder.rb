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
      options[:required] ||= fields[attribute_name]['required']
      options[:style] ||= {}
      options.delete(:width)
      options.delete('width')
      options.delete(:style).delete('width')

      options[:class] = "#{options[:class]} span3" unless (options[:as] == :boolean || options[:as] == :text)
      options[:input_html] = {class: options[:class]}
      options[:disabled] = true if options.delete(:readonly) || fields[attribute_name]['readonly']
      options[:as] = 'hidden' if options[:invisible]

      if options[:as] == :text
        options[:wrapper_html] = {class: "field span6"}
      else
        options[:wrapper_html] = {class: "field"}
      end

      adapt_label(attribute_name, options)
      dispatch_input(attribute_name, options)
    end

    def adapt_label(attribute_name, options)
      if options[:nolabel]
        if @labels[attribute_name] #TODO study if we can do closer to OE
          options[:label] ||= fields[attribute_name]['string']
          options[:label_html] = {class: "span3"}
        else
          options[:label] = false
        end
      else
        options[:label] ||= fields[attribute_name]['string']
        options[:label_html] = {class: "span3"}#unless opts[:as] == :text
      end
    end

    def oe_form_label(attrs)
      @labels ||= {}
      @labels[attrs[:for]] = attrs[:label]
      return ""
    end

    def ooor_button(label, options)
      @template.link_to(label || name, options)
    end

    def ooor_image_field(name, options)
      "<img src='data:image/png;base64,#{@object.send(name)}'/>".html_safe
    end

    def ooor_many2one_field(name, options)
      rel_name = "#{name}_id"
      rel_id = @object.send(rel_name.to_sym)
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json"
      if rel_id
        rel_value = @object.send(name.to_sym).name #TODO optimize: -1 RPC call
      else
        rel_value = ''
      end
      block = "<div class='input string field'/>#{label(name, options.delete('string') || fields[name]['string'], {class: 'string required span3'})}<input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_id}' value-name='#{rel_value}'/></div>"

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
});
".html_safe
end

      return block.html_safe
    end

    def ooor_many2many_field(name, options)
      rel_name = "#{name}_ids"
      rel_ids = @object.send(rel_name.to_sym).join(',')
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json" #TODO use URL generator
      if rel_ids
        rel_value = @object.send(name.to_sym).map {|i| i.name}.join(',')
      else
        rel_value = ''
      end
      block = "<div class='input string field'/>#{label(name, options.delete('string') || fields[name]['string'], {class: 'string required span3'})}<input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_ids}' value-name='#{rel_value}'/>"

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

});
".html_safe
end
      return block.html_safe
    end

    def dispatch_input(name, options={}) #TODO other OE attrs!
      attrs = options #TODO remove

#      if attrs[:nolabel]
#        label = false
#      else
#        label = true
#      end

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
        select(name, @template.options_for_select(fields[name]["selection"].map{|i|[i[1], i[0]]}), options)
      when 'statusbar'
        select(name, @template.options_for_select(fields[name]["selection"].map{|i|[i[1], i[0]]}), options)
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
