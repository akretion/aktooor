#module AktOoor
  module NavigationHelper

    def top_menu_id
      @top_menu_id ||= params["menu_id"] || menu_obj.search(name: 'Messaging')[0]
    end

    def first_model(menu_item)
      if menu_item.action && menu_item.action.res_model
        return menu_item.action.res_model.gsub(".", "-")
      elsif menu_item.associations['child_id']
        children = menu_obj.find(menu_item.associations['child_id'], fields: ['action', 'child_id'])
        children.each do |m|
          r = first_model(m)
          return r if r && r!= 'board-board'
        end
        return false
      else
        return false
      end
    end

    def menu_obj
      @abstract_model.const_get('ir.ui.menu')
    end

    def topmenu_items
      return unless @abstract_model
      ids = menu_obj.search(['parent_id', '=', false], 0, 1000, false, ooor_context)
      items = menu_obj.find(ids, context: ooor_context, fields: ['action', 'child_id'])
      items.map do |m|
      "<li>#{link_to m.name, "/ooorest/#{first_model(m)}?menu_id=#{m.id}"  }</li>"
      end.join().html_safe
    end

    def sidebar_items(selected=nil)
      return unless @abstract_model
      selected ||= menu_obj.find(top_menu_id, context: ooor_context)
      block = ""
      submenus = menu_obj.find(selected.associations['child_id'], fields: ['action', 'child_id'])
      submenus.each do |submenu|
        if submenu.associations["action"] && submenu.action.res_model
          link = submenu.action.res_model.gsub(".", "-")
          block << "<li>#{link_to submenu.name, "/ooorest/#{link}?menu_id=#{top_menu_id}" }</li>"
        else
        block << "<li class='nav-header'>#{submenu.name}</li>"
        subsubmenus = menu_obj.find(submenu.associations['child_id'], fields: ['action', 'child_id'])
        subsubmenus.each do |item|
          if item.child_id.empty?
            if item.associations["action"] && item.action.res_model
              link = item.action.res_model.gsub(".", "-")
            else
              link = "#"
            end
            block << "<li>#{link_to item.name, "/ooorest/#{link}?menu_id=#{top_menu_id}" }</li>"
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

