module RestDocRails
  module ModelDocumentation
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      # any method placed here will apply to classes, like Hickwall
      # def acts_as_something
      #   send :include, InstanceMethods
      # end
      attr_accessor :attribute_doc

      def doc_attribute(attribute, description, skip_validators_attributes: false)
        self.attribute_doc ||= model_attribute_documentation
        self.attribute_doc[attribute][:description] = description

        unless skip_validators_attributes
          validators_attributes = generate_validators_attributes validators_on(attribute)

          if [:string].include? self.attribute_doc[attribute][:type]
            value = validators_attributes.delete :minimum
            validators_attributes[:minLength] = value if value
            value = validators_attributes.delete :maximum
            validators_attributes[:maxLength] = value if value
          end

          self.attribute_doc[attribute].merge! validators_attributes
        end
      end

      def model_attribute_documentation
        result = {}

        if self.respond_to? :columns_hash
          result = self.columns_hash.transform_values do |value|
            {
                type: value.type
            }
          end.with_indifferent_access
        elsif self.respond_to? :fields
          result = self.fields.transform_values do |value|
            {
                type: value.type
            }
          end.with_indifferent_access
        end
        result
      end

      private
      def generate_validators_attributes(validators)
        result = {}

        validators.each do |validator|
          case validator
          when ::ActiveModel::Validations::PresenceValidator
            result[:required] = true
          when ::ActiveModel::Validations::LengthValidator
            result.merge! validator.options
          when ::ActiveModel::Validations::FormatValidator
            result[:pattern] = validator.options[:with]&.source
          end
        end

        result
      end
    end

    # module InstanceMethods
    #   # any method placed here will apply to instaces, like @hickwall
    # end
  end
end