module Aktooor
  class Railtie < Rails::Railtie
    initializer "aktooor.view_helpers" do
      ActionView::Base.send :include, NavigationHelper
      require 'ooorest/action_window_controller_base'
    end
  end
end
