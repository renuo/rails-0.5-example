module CoinHelper
  def self.append_features(controller) #:nodoc:
    controller.ancestors.include?(ActionController::Base) ? controller.add_template_helper(self) : super
  end
end
