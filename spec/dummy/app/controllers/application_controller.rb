class ApplicationController < ActionController::Base
  include RestDocRails::ControllerDocumentation
  self.doc_default_response_types = [:xml]
  self.doc_default_response_types = [:json, 'text/html']

  # for more details about the authentication methods see https://swagger.io/docs/specification/authentication/
  # doc_auth_basic <name>: describe basic authentication
  self.doc_auth_basic :basic_auth
  # doc_auth_bearer <name>, [bearerFormat=nil]: define authentication with bearer token
  self.doc_auth_bearer :json_web_token, :jwt
  # doc_auth_oauth2 <name>, <flow>: define oauth2 authentication
  # self.doc_auth_oauth2 :oauth2, {} # for more details how the second paramter should look see https://swagger.io/docs/specification/authentication/oauth2/
  # doc_auth_api_key <name>, <header field name>: define api key authentication
  self.doc_auth_api_key :api_key, "API_KEY_HEADER"
  # doc_auth_open_id <name>, <openidConnectUrl>
  self.doc_auth_open_id :open_id, 'https://example.com/.well-known/openid-configuration'

  # add json_web_token authentication requirement to action
  # :all is used for all actions
  # if you want to add exceptions just use doc_add_action_authentication without the second parameter
  self.doc_add_action_authentication :all, :json_web_token
  self.doc_add_action_authentication :index
end
