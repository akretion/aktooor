require "aktooor/engine"
require "ooorest"
require "ooorest/action_window_controller_base"
require "nokogiri"

module Aktooor
  module ViewAwareController
    def get_model_meta
      super
      get_view_meta unless (['json', 'xml'].index(params[:format]) &&! params[:view_id])
    end

    def get_view_meta
      get_model
      @view_type = params["view_type"] || {index: :tree, show: :form, edit: :form, new: :form}[params["action"].to_sym] || :tree
      if params['view_id']
        @view_id = params["view_id"]
      elsif params['view_ref']
        @view_id = Ooor.connection(params).const_get('ir.ui.view').find(params['view_ref'], fields: ['id']).id
      else #TODO view_name
        @view_id = false
      end
      fvg = Ooor.cache.fetch("fgv-#{@model_name}-#{@view_id || @view_type}") do #TODO OE user cache wise? 
        @abstract_model.rpc_execute('fields_view_get', @view_id, @view_type)#, fvg_context, false, false, {context_index: 2})
      end
      @view = fvg['arch']
      @fields = fvg['fields']
      @abstract_model.set_columns_hash(@fields)
      get_partial
    end

    def get_xslt_content(view_type)
      @xsl_content ||= Ooor.cache.fetch("xslt-#{view_type}") do
        File.read(File.expand_path("../../app/views/xslt/#{@view_type}.xslt", __FILE__))
      end
    end

    def get_partial()
      res = Ooor.cache.fetch("partial-#{@model_path}-#{@view_id || @view_type}") do
        if @view
          xslt = Nokogiri::XSLT(get_xslt_content(@view_type))
          @view.gsub!("&quot;", "'").gsub!("\"", '"')
puts @view
          doc = Nokogiri::XML(@view)
          if @view_type == :tree
            @field_list = []
            doc.xpath('//field').each do |field|
              @field_list << oe_table_field(field)
            end
          end
          ["#{xslt.transform(doc)}", @field_list]
        end
      end
puts "******************", res[0]
      @oe_partial = res[0]
      @field_list = res[1]
    end

  def oe_table_field(field)
    if field[:string] && field[:string] != ""
      field_name = field[:string]
    elsif @fields[field[:name]]
      field_name = @fields[field[:name]]['string']
    elsif @abstract_model.fields[field[:name]]
      field_name = @abstract_model.fields[field[:name]]['string']
    elsif @abstract_model.columns_hash[field[:name]]
      field_name = @abstract_model.columns_hash[field[:name]][:name]
    else
      field_name = field[:name]
    end
  end

  end

  Ooorest::ActionWindowControllerBase.send :include, ViewAwareController
end


require 'aktooor/railtie' if defined?(Rails)
