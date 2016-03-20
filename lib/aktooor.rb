require 'action_view'
require 'aktooor/engine'
require 'ooorest'
require 'nokogiri'
require 'aktooor/action_view_extensions/form_helper'
require 'aktooor/form_transformer'
require 'aktooor/form_builder'
require 'aktooor/table_builder'
require 'simple_form'

module Aktooor
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FormBuilder
#    autoload :Inputs
  end
end

require 'aktooor/railtie' if defined?(Rails)
