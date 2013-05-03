class ActionWindowCell < Cell::Rails

  include Ooorest::ActionWindowController

  helper NavigationHelper
  helper ViewTreeHelper
  helper FieldHelper

#  before_filter :get_model, :except => Ooorest::Config::Actions.all(:root).map(&:action_name)
#  before_filter :get_object, :only => Ooorest::Config::Actions.all(:member).map(&:action_name)

  def respond_to(&block)
    render
  end

  def forward(args)
p "*******", args, @object
#    render 
  end
end
