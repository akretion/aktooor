module Aktooor
  class Engine < ::Rails::Engine
    isolate_namespace Aktooor

    initializer :add_cells_view_paths do
      paths.add "app/cells"
      views = paths["app/cells"].existent
      unless views.empty?
        ActiveSupport.on_load(:action_controller){ prepend_view_path(views) }
        ActiveSupport.on_load(:action_mailer){ prepend_view_path(views) }
      end
    end

  end
end
