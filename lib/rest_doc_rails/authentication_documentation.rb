module RestDocRails
  module AuthenticationDocumentation

    def doc_action_authentication
      @doc_action_authentication ||= superclass.try(:doc_action_authentication) || {}
    end

    def doc_add_action_authentication(action, authentication_name=nil)
      throw "There is no Authentication with the name #{authentication_name}!" if authentication_name && doc_action_authentication[authentication_name]
      doc_action_authentication[action] ||= []
      doc_action_authentication[action] << { authentication_name => [] } if authentication_name
    end

    def doc_authentication_methods
      @doc_authentication_methods ||= superclass.try(:doc_authentication_methods) || {}
    end

    def doc_auth_basic(name)
      add_auth_method name, {
          type: 'http',
          scheme: 'basic'
      }
    end

    def doc_auth_bearer(name, bearerFormat=nil)
      add_auth_method name,{
          type: 'http',
          scheme: 'bearer'
      }

      @doc_authentication_methods[name][:bearerFormat] = bearerFormat if bearerFormat
    end

    ##
    #       flows:
    #         authorizationCode:
    #           authorizationUrl: https://example.com/oauth/authorize
    #           tokenUrl: https://example.com/oauth/token
    #           scopes:
    #             read: Grants read access
    #             write: Grants write access
    #             admin: Grants access to admin operations
    def doc_auth_oauth2(name, flows)
      add_auth_method name,{
          type: 'oauth2',
          flows: flows
      }
    end

    def doc_auth_api_key(name, header_field)
      add_auth_method name,{
          type: 'apiKey',
          in: 'header',
          name: header_field
      }
    end

    def doc_auth_open_id(name, openid_url)
      add_auth_method name,{
          type: 'openIdConnect',
          openIdConnectUrl: openid_url
      }
    end

    private
    def add_auth_method(name, auth_method)
      throw "authentication name already in use: #{name}" if doc_authentication_methods.include? name
      doc_authentication_methods[name] = auth_method
    end
  end
end