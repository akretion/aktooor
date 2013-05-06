#module AktOoor
  module NavigationHelper

    def first_model(menu_item)
      if menu_item.associations["action"] && menu_item.action.res_model
        return menu_item.action.res_model.gsub(".", "-")
      else
        menu_item.child_id.each do |m|
          r = first_model(m)
          return r if r
        end
        return false
      end
    end

    def topmenu_items
      ids = IrUiMenu.search(['parent_id', '=', false])
      items = IrUiMenu.find(ids)
      items.map do |m|
      "<li>#{link_to m.name, "/aktooor/#{first_model(m)}?menu_id=#{m.id}"  }</li>"
      end.join().html_safe
    end

    def sidebar_items(selected=nil)
      unless selected
        @top_menu_id ||= params["menu_id"] || 75
        selected = IrUiMenu.find(@top_menu_id) #TODO use cache here too
      end
      block = ""
      selected.child_id.each do |submenu|
        if submenu.associations["action"] && submenu.action.res_model
          link = submenu.action.res_model.gsub(".", "-")
          block << "<li>#{link_to submenu.name, "/aktooor/#{link}?menu_id=#{@top_menu_id}" }</li>"
        else
        block << "<li class='nav-header'>#{submenu.name}</li>"
        submenu.child_id.each do |item|
          if item.child_id.empty?
            if item.associations["action"] && item.action.res_model
              link = item.action.res_model.gsub(".", "-")
            else
              link = "#"
            end
            block << "<li>#{link_to item.name, "/aktooor/#{link}?menu_id=#{@top_menu_id}" }</li>"
          else
            block << "<li class='nav-header'>#{submenu.name}<ul>"
            block << sidebar_items(item)
            block << "</ul></li>"
          end
        end
        end
      end
      return block.html_safe
    end

  end
#end

