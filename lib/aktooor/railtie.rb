module Aktooor
  class Railtie < Rails::Railtie
    initializer "aktooor.view_helpers" do
      ActionView::Base.send :include, NavigationHelper
    end
  end
end
