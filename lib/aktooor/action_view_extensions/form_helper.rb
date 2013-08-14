module Aktooor
  module ActionViewExtensions
    module FormHelper

      def ooor_form_for(record, options={}, &block)
        options[:builder] = Aktooor::FormBuilder
        simple_form_for(record, options, &block)
      end

    end
  end
end

ActionView::Base.send :include, Aktooor::ActionViewExtensions::FormHelper
