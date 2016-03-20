module Aktooor
  # FormTransformer transforms OpenERP XML forms into Ruby markup using XSLT.
  # Fully functional transformation is rarely possible.
  # For instance forms transcoded from OpeERP only emulate 80% of the features today
  # but even if it's not perfect, it's good to test and showcase Aktooor features.
  module FormTransformer

    def oe_component(options={})
      partial = fields_view_get_meta(options)[0]
      locals = {f: self}.merge(options.fetch(:locals, {}))
      @template.render options.merge(locals: locals, inline: partial)
    end

    def fields_view_get_meta(options={})
      params = @template.params
      abstract_model = @abstract_model || @template.assigns['abstract_model'] # form_for and fields_for have an @object, not a table
      view_type = options[:view_type] || params["view_type"] || {index: :tree, show: :form, edit: :form, new: :form, update: :form}[params["action"].to_sym] || :tree
      if view_ref = options[:view_ref] || params['view_ref']
        view_id = ooor_session.const_get('ir.ui.view').find(params['view_ref'], fields: ['id']).id
      else
        view_id = options[:view_id] || params["view_id"]
      end
      fvg = Ooor.cache.fetch("fgv-#{abstract_model.openerp_model}-#{view_id || view_type}") do #TODO OE user cache wise?
        abstract_model.rpc_execute('fields_view_get', view_id, view_type)#, fvg_context, false, false, {context_index: 2})
      end
      view = fvg['arch']
      fields = abstract_model.all_fields().merge(fvg['fields'])
      abstract_model.columns_hash(fields)
      ooor_partial(view_type, view_id, view, fields)
    end

    def fields
      fields_view_get_meta()[3]
    end

    def ooor_context
      ctx = @template.instance_variable_get('@ooor_context')
      raise "no @ooor_context set from your controller. Did you call ooor_context or ooor_model_meta filter in the controller?" unless ctx
      ctx
    end

    def ooor_xslt_content(view_type)
      @xsl_content ||= Ooor.cache.fetch("xslt-#{view_type}") do
        File.read(File.expand_path("../../../app/views/xslt/#{view_type}.xslt", __FILE__))
      end
    end

    def ooor_partial(view_type, view_id, view, fields)
      model_path = @template.assigns['model_path']
      res = Ooor.cache.fetch("partial-#{model_path}-#{view_id || view_type}") do
        if view
          xslt = Nokogiri::XSLT(ooor_xslt_content(view_type))
          view.gsub!("&quot;", "'")
          view.gsub!("\"", '"')
          doc = Nokogiri::XML(view)
          if view_type == :tree
            field_list = []
            doc.xpath('//field').each do |field|
              field_list << ooor_table_field(fields, field)
            end
            view_name = doc.xpath('//tree')[0]['string']
          else
            view_name = doc.xpath('//form')[0]['string']
          end
          ["#{xslt.transform(doc)}", field_list, view_name]
        end
      end
      @field_list = res[1] # TODO avoid using template variables
      return res[0], res[1], res[2], fields #partial, field_list, form_name, fields
    end

    def field_list(options={})
      fields_view_get_meta(options={})[1]
    end

    def ooor_table_field(fields, field)
      abstract_model = @template.assigns['abstract_model']
      if field[:string] && field[:string] != ""
        field_name = field[:string]
      elsif fields[field[:name]]
        field_name = fields[field[:name]]['string']
      elsif abstract_model.fields[field[:name]]
        field_name = abstract_model.fields[field[:name]]['string']
      elsif abstract_model.columns_hash[field[:name]]
        field_name = abstract_model.columns_hash[field[:name]][:name]
      else
        field_name = field[:name]
      end
    end

  end
end
