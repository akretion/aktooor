require 'action_view'
require 'aktooor/engine'
require 'ooorest'
require 'ooorest/action_window_controller_base'
require 'nokogiri'
require 'aktooor/action_view_extensions/form_helper'
require 'aktooor/form_builder'
require 'simple_form'

module Aktooor
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FormBuilder
#    autoload :Inputs
  end

  module ViewAwareController
    def ooor_model_meta
      super
      ooor_view_meta unless [:json, :xml].index(params[:format])
    end

    def ooor_view_meta
      @view_type = params["view_type"] || {index: :tree, show: :form, edit: :form, new: :form, update: :form}[params["action"].to_sym] || :tree
      if params['view_id']
        @view_id = params["view_id"]
      elsif params['view_ref']
        @view_id = ooor_session.const_get('ir.ui.view').find(params['view_ref'], fields: ['id']).id
      else #TODO view_name
        @view_id = false
      end
      fvg = Ooor.cache.fetch("fgv-#{@model_name}-#{@view_id || @view_type}") do #TODO OE user cache wise? 
        @abstract_model.rpc_execute('fields_view_get', @view_id, @view_type)#, fvg_context, false, false, {context_index: 2})
      end
      @view = fvg['arch']
      @fields = {image_uid: {"selectable"=>true, "type"=>"char", "string"=>"Dragonfly Image uid", "size"=>128}}.merge(fvg['fields'])
#      @fields = fvg['fields']
      @abstract_model.columns_hash(@fields)
      ooor_partial
    end

    def ooor_xslt_content(view_type)
      @xsl_content ||= Ooor.cache.fetch("xslt-#{view_type}") do
        File.read(File.expand_path("../../app/views/xslt/#{@view_type}.xslt", __FILE__))
      end
    end

    def ooor_partial()
      res = Ooor.cache.fetch("partial-#{@model_path}-#{@view_id || @view_type}") do
        if @view
          xslt = Nokogiri::XSLT(ooor_xslt_content(@view_type))
          @view.gsub!("&quot;", "'")
          @view.gsub!("\"", '"')
          doc = Nokogiri::XML(@view)
          if @view_type == :tree
            @field_list = []
            doc.xpath('//field').each do |field|
              @field_list << ooor_table_field(field)
            end
            view_name = doc.xpath('//tree')[0]['string']
          else
            view_name = doc.xpath('//form')[0]['string']
          end
          ["#{xslt.transform(doc)}", @field_list, view_name]
        end
      end
      @oe_partial = res[0]
      @field_list = res[1]
      @form_name = res[2]
    end

    def ooor_table_field(field)
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
