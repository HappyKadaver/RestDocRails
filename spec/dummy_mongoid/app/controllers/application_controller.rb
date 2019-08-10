class ApplicationController < ActionController::Base
  include RestDocRails::ControllerDocumentation
  self.doc_default_response_types = [:xml]
  self.doc_auth_bearer :JWT, :jwt

  self.doc_add_action_authentication :all, :JWT
end
