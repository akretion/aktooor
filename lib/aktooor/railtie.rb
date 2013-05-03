module Aktooor
  class Railtie < Rails::Railtie
    initializer "aktooor.view_helpers" do
      ActionView::Base.send :include, NavigationHelper
      ActionView::Base.send :include, ViewTreeHelper
      ActionView::Base.send :include, FieldHelper
    end
  end
end
