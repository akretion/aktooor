require 'aktooor/form_transformer'

module Aktooor
  module ActionViewExtensions
    module FormHelper

      def ooor_form_for(record, options={}, &block)
        options[:builder] = Aktooor::FormBuilder
        simple_form_for(record, options, &block)
      end

      def ooor_table_for(abstract_model, records, options={}, &block)
        builder = TableBuilder.new(abstract_model, records, self, options)
        output  = capture(builder, &block)
      end

    end
  end
end

ActionView::Base.send :include, Aktooor::ActionViewExtensions::FormHelper
