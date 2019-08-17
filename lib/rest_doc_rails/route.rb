module RestDocRails
  class Route < Struct.new(:verb, :path, :controller, :action, :formats, :route_parts)
    # attr_reader :verb
    # attr_reader :path
    # attr_reader :controller
    # attr_reader :action
    # attr_reader :formats
    #
    # def initialize(verb, path, controller, action, format)
    #   @verb = verb
    #   @path = path
    #   @controller = controller
    #   @action = action
    #   @format = format
    # end
    #
    # def ==(other)
    #   return false unless @verb == other.verb
    #   return false unless @path == other.path
    #   return false unless @controller == other.controller
    #   return false unless @action == other.action
    #   return false unless @format == other.format
    #
    #   true
    # end
  end
end