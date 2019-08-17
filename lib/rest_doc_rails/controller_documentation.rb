require 'rest_doc_rails/model_documentation'
require 'rest_doc_rails/authentication_documentation'
require 'rack/utils'

module RestDocRails
  module ControllerDocumentation
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :extend, RestDocRails::AuthenticationDocumentation
    end

    module ClassMethods
      RESPONSE_TYPE_SYMBOLS = {
          json: 'application/json',
          xml: 'applicatoin/xml',
          html: 'text/html',
          plain: 'text/plain'
      }
      # any method placed here will apply to classes, like Hickwall
      # def acts_as_something
      #   send :include, InstanceMethods
      # end
      attr_accessor :doc_action
      attr_accessor :doc_action_response
      attr_accessor :doc_action_request
      attr_accessor :doc_action_parameters

      def doc_default_response_types
        @doc_default_response_types ||= superclass.try(:doc_default_response_types) || [:html]
      end

      def doc_default_response_types=(value)
        value = value.map do |v|
          RESPONSE_TYPE_SYMBOLS[v] if v.is_a? Symbol
        end
        @doc_default_response_types = value
      end

      def doc(action, description)
        self.doc_action ||= {}
        self.doc_action[action] = description
      end

      def doc_response(action, http_code, response_hash, description, response_types=doc_default_response_types)
        http_code = symbol_to_code http_code if http_code.is_a? Symbol
        openapi_response_hash = to_open_api_hash response_hash
        deep_filter_required! openapi_response_hash

        self.doc_action_response ||= {}
        self.doc_action_response[action] ||= {}
        self.doc_action_response[action][http_code] ||= {content: {}}

        response_types.each do |response_type|
          self.doc_action_response[action][http_code][:description] = description
          self.doc_action_response[action][http_code][:content][response_type] ||= {
              schema: openapi_response_hash
          }
        end
      end

      def doc_request(action, request_hash, description='', response_types=doc_default_response_types)
        open_api_request_hash = to_open_api_hash request_hash
        required = deep_filter_required! open_api_request_hash
        open_api_request_hash[:required] = required if required&.any?

        response_types.each do |response_type|
          self.doc_action_request ||= {}
          self.doc_action_request[action] = {content: {
              response_type => {}
          }}
          self.doc_action_request[action][:content][response_type] = {
              schema: open_api_request_hash
          }
        end
      end

      def doc_query_param(action, param_name, required, schema, description)
        open_api_schema = to_open_api_hash schema
        doc_param action, {
            in: :query,
            name: param_name,
            required: required,
            description: description,
            schema: open_api_schema
        }
      end

      def doc_path_param(action, param_name, schema, description)
        open_api_schema = to_open_api_hash schema
        doc_param action, {
            in: :path,
            required: true,
            name: param_name,
            description: description,
            schema: open_api_schema
        }
      end

      def doc_array_of(response_body)
        [response_body]
      end

      def doc_model_response_body(model=model_class, merge_hash={})
        return if model.nil?

        model_attribute_documentation(model).merge merge_hash
      end

      def doc_strong_parameters_request(request_hash={controller_name.to_sym => doc_model_response_body}, require_symbol=(controller_name.singularize.to_sym), strong_paramters)
        params = ::ActionController::Parameters
        params.require(require_symbol).permit(strong_paramters).to_h.with_indifferent_access
      end



      private
      def model_class
        controller_name.classify.safe_constantize
      end

      def doc_param(action, open_api_hash)
        self.doc_action_parameters ||= {}
        self.doc_action_parameters[action] ||= []
        self.doc_action_parameters[action] << open_api_hash
      end

      def model_attribute_documentation(model=model_class)
        return model.attribute_doc if model < RestDocRails::ModelDocumentation

        result = {}

        if model.respond_to? :columns_hash
          result = model.columns_hash.transform_values do |value|
            {
                type: value.type
            }
          end.with_indifferent_access
        elsif model.respond_to? :fields
          result = model.fields.transform_values do |value|
            {
                type: value.type
            }
          end.with_indifferent_access
        end

        result
      end

      def symbol_to_code(http_code_symbol)
        Rack::Utils::SYMBOL_TO_STATUS_CODE[http_code_symbol]
      end

      def to_open_api_hash(object)
        case object
        when Array
          return if object.empty?

          result = {
              type: 'array'
          }

          if object.count == 1
            result[:items] = to_open_api_hash object.first
          else
            result[:items] = {
                anyOf: object.map { |o| to_open_api_hash o }
            }
          end

          result
        when Hash
          return object if object.include? :type
          {
              type: 'object',
              properties: object.transform_values { |v| to_open_api_hash v}
          }
        when String
          {
              type: 'string'
          }
        when Integer
          {
              type: 'integer'
          }
        when Float
          {
              type: 'double'
          }
        when DateTime
          {
              type: 'string',
              format: 'date-time'
          }
        when Date
          {
              type: 'string',
              format: 'date'
          }
        else
          throw StandardError.new "unkown object type: #{object}"
        end
      end

      def deep_filter_required!(hash)
        r = []
        hash.each do |k, v|
          was_required = v.delete :required if v.is_a?(Hash) && v.include?(:required)
          r << k if was_required

          r.push *deep_filter_required!(v) if v.is_a? Hash
        end

        r
      end
    end

    # module InstanceMethods
    #   # any method placed here will apply to instaces, like @hickwall
    # end
  end
end