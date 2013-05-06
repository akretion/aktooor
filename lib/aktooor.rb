require "aktooor/engine"
require "ooorest"
require "nokogiri"

module Aktooor
end

Ooorest.class_eval do
  def self.get_partial(abstract_model, model_path, view, view_type, fields) #FIXME horrible extension
    if view
       view.gsub!("&quot;", "'").gsub!("\"", '"')
#      oe_partial = cache("form/#{model_path}/#{view_type}") do
p "BVVVVVVVVVVVVVVVVVVVV", view
#        view_type = 'form' if view_type == 'new'
        path = File.expand_path("../../app/views/xslt/#{view_type}.xslt", __FILE__)
        xslt = Nokogiri::XSLT(File.read(path))
        oe_partial = xslt.transform(Nokogiri::XML(view)).to_s
#      end
    end
    oe_partial
  end
end

require 'aktooor/railtie' if defined?(Rails)
