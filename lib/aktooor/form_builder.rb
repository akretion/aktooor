require 'simple_form'
require 'simple_form/form_builder'

module Aktooor
  class FormBuilder < SimpleForm::FormBuilder
    include FormTransformer

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

      if options.delete(:readonly)
        options[:disabled] = true
      elsif fields[attribute_name]['readonly']
        status = @object.attributes['state'] || 'draft'
        if fields[attribute_name]['states'] && fields[attribute_name]['states'][status] && x=fields[attribute_name]['states'][status][0]
          options[:disabled] = x[0] if x[0] = 'readonly'
        else
          options[:disabled] = fields[attribute_name]['readonly']
        end
      end
      options[:as] = 'hidden' if options[:invisible]
      adapt_label(attribute_name, options)
      capture_on_change(attribute_name, options) if options[:on_change_js]
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
        image_placeholder = "<img src='#{url}'/>"
      else
        method = name
        image_placeholder = "<img src='data:image/png;base64,#{@object.send(name)}'/>"
      end
      html = <<-EOS
<div class='form-group input string field'/>#{label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])}<div>
<div class='fileupload fileupload-new' data-provides='fileupload'>
  <div class='fileupload-new img-thumbnail'>
#{image_placeholder}
  </div>
  <div class="fileupload-preview thumbnail" data-trigger="fileupload" style="width: 200px; height: 150px;"></div>
  <div>
    <span class='btn btn-file'>
      <span class='fileupload-new'>Select image</span>
      <span class='fileupload-exists'>Change</span>
#{file_field(method, options)}
    </span>
    <a href='#' class='btn fileupload-exists' data-dismiss='fileupload'>Remove</a>
  </div>
</div></div></div>
      EOS
      html.html_safe
    end

    def ooor_many2one_field(name, options) #TODO make work if reference
      rel_name = "#{name}_id"

      if @object.class.polymorphic_m2o_associations.keys.index(name)
        options[:disabled] = true # TODO edition of reference field not supported yet by Aktooor
        if @object.associations[name]
          rel_id = @object.associations[name].split(',')[1]
          rel_key = @object.associations[name].split(',')[0]
          rel_path = (rel_key).gsub('.', '-')
          rel_klass = @object.class.const_get(rel_key)
          rel_value = rel_klass.name_get([rel_id.to_i], ooor_context)[0][1]
        else
          rel_value = ""
          rel_path = ""
        end
      else
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
      end

      ajax_path = "/ooorest/#{rel_path}.json"
      opts = {label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required]}
      opts[:label_html] = opts.except(:label, :required, :as)
the_label = SimpleForm::Inputs::Base.new(self, name, nil, nil, opts).label

      block = <<-EOS
<div class='form-group input string field'/>#{the_label}<div><input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_id}' value-name='#{rel_value}'/></div></div>
       EOS

      capture_association_js(name, options)
      return block.html_safe
    end

    def ooor_many2many_field(name, options)
      rel_name = "#{name}_ids"
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json" #TODO use URL generator
      val = @object.send(rel_name.to_sym)
      if !val || val.is_a?(String) && val.is_blank? || val.is_a?(Array) && val.empty?
        val = []
        rel_ids_string = ""
        rel_value = ''
      else
        val = val.split(",") if val.is_a?(String)
        rel_ids = val.map! {|i| i.is_a?(Ooor::Base) ? i.id : i.to_i}
        rel_ids = [rel_ids] if rel_ids && !rel_ids.is_a?(Array)
        rel_ids_string = rel_ids.join(",")
        rel_klass = @object.class.const_get(fields[name]['relation']) #@object.class.reflect_on_association(:categ_id).klass
        objects = rel_klass.name_get(rel_ids)
        if objects
          rel_value = objects.map {|i| i[1]}.join(',')
        else
          rel_value = ''
        end
      end

      block = <<-EOS
<div class='form-group input string field'/>#{label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])}<div><input type='hidden' id='#{@object_name}_#{name}' name='#{@object_name}[#{name}]' value='#{rel_ids_string}' value-name='#{rel_value}'/></div></div>
      EOS

      capture_association_js(name, options)
      return block.html_safe
    end

    def capture_on_change(name, options)
      @template.content_for :js do
        javascript = <<-EOS
$('##{@object_name}_#{name}').change(function() {
  #{options[:on_change_js]};
});
        EOS
        javascript.html_safe
      end
    end

    def capture_association_js(name, options)
      rel_path = fields[name]['relation'].gsub('.', '-')
      ajax_path = "/ooorest/#{rel_path}.json"
      if ['many2many_tags', 'many2many'].index(options[:oe_type]) #multiple
        multiple = "true"
        init_selection = <<-EOS
initSelection: function (element, callback) {
        var data = [];
        var ids = $(element).attr('value').split(',')
        var c = 0;
        $($(element).attr('value-name').split(',')).each(function () {
            data.push({name: this, id: ids[c]});
            c += 1;
        });
        callback(data);
    },
EOS
        maximum_selection_size = "maximumSelectionSize: #{options[:maximum_selection_size] || 15},"
      else
        multiple = "false"
        init_selection = <<-EOS
initSelection: function (element, callback) {
      var elementText = $(element).attr('value-name');
      callback({name: elementText});
    },
EOS
        maximum_selection_size = ""
      end

      @template.content_for :js do
        javascript = <<-EOS
$(document).ready(function() {
  $('##{@object_name}_#{name}').select2({
    placeholder: '#{fields[name]['string']}',
    width: 'element',
    minimumInputLength: #{options[:mininum_input_length] || 2},
    multiple: #{multiple},
    #{maximum_selection_size}
    formatSelection: function(category) {
      return category.name;
    },
    #{init_selection}
    formatResult: function(item) {
      return item.name;
    },
    ajax: {
      url: '#{ajax_path}',
      data: function (name, page) {
        return {
          q: name, // search term
          limit: 20,
          fields: ['name'],
          domain: eval(#{options[:domain_js] || '[]'}),
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
        EOS
        javascript.html_safe
      end
    end

    def dispatch_input(name, options={}) #TODO other OE attrs!
      case options[:oe_type]
      when 'image'
        ooor_image_field(name, options)
      when 'many2one'
        ooor_many2one_field(name, options)
      when 'reference'
        ooor_many2one_field(name, options)
      when 'many2many'
        ooor_many2many_field(name, options)
      when 'many2many_tags'
        ooor_many2many_field(name, options)
      when 'mail_followers'
        options[:disabled] = true
        ooor_many2many_field(name, options)
      when 'html'
        text_area(name, options)
      when 'selection'
        if @object.associations[name].is_a?(Array)
          selected_value = @object.associations[name][0]
        elsif @object.associations[name]
          selected_value = @object.associations[name]
        else
          selected = @object.send(name.to_sym)
          selected_value = selected.is_a?(Ooor::Base) ? selected.id : selected
        end
        if options[:collection]
          collection = options[:collection]
        elsif fields[name]['type'] == 'many2one' # it's a many2one with a selection widget
          rel_klass = @object.class.const_get(fields[name]['relation'])
          if options[:domain_rb]
            collection_ids = rel_klass.search(options[:domain_rb])
            collection = rel_klass.name_get(collection_ids).map {|i| [i[1], i[0]]}
          else
            collection = rel_klass.name_search("%").map {|i| [i[1], i[0]]}
          end
          collection = [['-', '']] + collection unless fields[name]['required']
        else
          collection = fields[name]['selection'].map {|i| [i[1], i[0]]}
        end
        input name, options.merge(collection: collection, as: 'select', selected: selected_value)
      when 'statusbar'
        input name, options.merge(collection: fields[name]['selection'].map{|i|[i[1], i[0]]}, as: 'select')
      #simple_form from now on:
      when 'one2many'
        html = label(name, label: (options[:label] || options.delete('string') || fields[name]['string']), class: 'string control-label', required: options[:required])
        html << "<div>".html_safe
        html << (simple_fields_for name.to_sym do |item|
          @template.render 'nested_form', :f => item
        end)
        html << @template.link_to_add_association(self, name.to_sym, {:partial => 'nested_form'}) do #TODO if block given use it instead
"  <div class='clearfix'>
    <button type='button' class='btn btn-success btn-lg'><i class='fa fa-picture-o'></i> Add <i class='icon-picture icon-white'></i></button>
  </div>".html_safe
        end
        html << "</div>".html_safe
        html.html_safe
      when 'mail_thread' #TODO this is only a poor demo fallback:
        options[:disabled] = true
        ooor_many2many_field(name, options)
      else
        input(name, options)
      end
    end

  end
end
