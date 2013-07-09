class ActionWindowCell < Cell::Rails

  include Ooorest::ActionWindowController
  include Ooorest::RequestHelper #FIXME not very clean as already included in ActionWindowController
  include Aktooor::ViewAwareController

  helper NavigationHelper
  helper ViewTreeHelper
  helper FieldHelper

  before_filter :get_model_meta, :except => [:dashboard]
  before_filter :get_object, :only => [:show, :edit, :delete, :update, :show_in_app]

#  before_filter :_authenticate!
  before_filter :_authorize!

  def render_state(state, *args)
    @args = args[0].merge({"action" => state}) #FIXME brittle?
    super
  end

  def params
    @cell_params ||= request.parameters.merge(@args)
  end

  def respond_to(&block)
    render
  end

end
