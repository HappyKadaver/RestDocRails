require_relative 'parser/RouteParser'

module RestDocRails
  class DocumentationGenerator
    def initialize
      @route_parser = Parser::RouteParser.new
      @openapi = {
          openapi: "3.0.0",
          info: {
              title: 'Sample API',
              description: 'Optional multiline or single-line description in [CommonMark](http://commonmark.org/help/) or HTML.',
              version: '0.1.9',
          }
      }

      @data_type_mapping = {
          date: {
              type: 'string',
              format: 'date'
          },
          datetime: {
              type: 'string',
              format: 'date-time'
          },
          float: {
              type: 'double'
          },
          text: {
              type: 'string'
          },
          time: {
              type: 'string',
              format: 'timestamp'
          }
      }

      if defined? Mongoid::Document
        @data_type_mapping.merge!({
            Array => {
                type: 'array'
            },
            BigDecimal => {
                type: 'integer'
            },
            Boolean => {
                type: 'boolean'
            },
            Date => {
                type: 'string',
                format: 'date'
            },
            DateTime => {
                type: 'string',
                format: 'date-time'
            },
            Float => {
                type: 'double'
            },
            Hash => {
                type: 'object'
            },
            Integer => {
                type: 'integer'
            },
            BSON::ObjectId => {
                type: 'string',
                format: 'uuid'
            },
            Regexp => {
                type: 'string',
                format: 'regex'
            },
            String => {
                type: 'string'
            },
            Symbol => {
                type: 'string',
                format: 'symbol'
            },
            Time => {
                type: 'string',
                format: 'time'
            }
        })
      end
    end

    def write_documentation(file)
      if defined? ::ApplicationController
        action_authentication = ::ApplicationController.try(:doc_action_authentication)
        authentications = action_authentication[:all] if action_authentication
        @openapi[:security] = authentications if authentications
      end

      @route_parser.each do |route|
        add_authentication_method route.controller
        add_action route
      end

      @openapi = @openapi.deep_stringify_keys
      @openapi = deep_map_activerecord_types_to_openapi @openapi
      @openapi = deep_symbol_to_string @openapi

      file.write @openapi.deep_stringify_keys.to_yaml
    end

    private

    def add_action(route)
      action_doc = route.controller.try(:doc_action) || {}
      response_doc = route.controller.try(:doc_action_response) || {}
      request_doc = route.controller.try(:doc_action_request) || {}

      action_authentication = route.controller.try(:doc_action_authentication)
      authentications = action_authentication[route.action] if action_authentication

      @openapi[:paths] ||= {}
      @openapi[:paths][route.path] ||= {}
      @openapi[:paths][route.path][route.verb] ||= {}
      @openapi[:paths][route.path][route.verb][:description] = action_doc[route.action] || "#{route.controller.controller_name} #{route.action.to_s}"
      @openapi[:paths][route.path][route.verb][:responses] = response_doc[route.action] || default_response(route.controller.try :doc_default_response_types)
      @openapi[:paths][route.path][route.verb][:requestBody] = request_doc[route.action] if request_doc[route.action]
      @openapi[:paths][route.path][route.verb][:security] = authentications if authentications
    end

    def add_root_authentication(controller)
      action_authentication = controller.try(:doc_action_authentication)
      authentications = action_authentication[:all] if action_authentication
      @openapi[:security] = authentications if authentications
    end

    def add_authentication_method(controller)
      authentication_methods = controller.try(:doc_authentication_methods)
      return unless authentication_methods

      @openapi[:components] ||= {}
      @openapi[:components][:securitySchemes] ||= {}
      @openapi[:components][:securitySchemes].merge! authentication_methods
    end

    def default_response(response_types)
      response_types ||= ['text/html']
      result = {
          200 => {
              description: "success",
              content: {}
          }
      }
      response_types.each do |response_type|
        result[200][:content][response_type] = {}
      end

      result
    end

    def deep_map_activerecord_types_to_openapi(hash)
      result = {}

      hash.each do |k, v|
        if k == :type || k == 'type'
          result.merge!(@data_type_mapping[v] || {k => v})
        else
          v = deep_map_activerecord_types_to_openapi v if v.is_a? Hash
          result[k] = v
        end
      end

      result
    end

    def deep_symbol_to_string(hash)
      hash.transform_values do |v|
        next deep_symbol_to_string v if v.is_a? Hash
        next v.to_s if v.is_a? Symbol

        if v.is_a? Array
          next v.map do |v|
            next deep_symbol_to_string v if v.is_a? Hash
            next v.to_s if v.is_a? Symbol
            v
          end
        end

        v
      end
    end
  end
end