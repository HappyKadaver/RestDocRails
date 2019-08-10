require_relative '../route'

module RestDocRails
  module Parser
    class RouteParser
      GET    = :GET
      POST   = :POST
      PUT    = :PUT
      PATCH  = :PATCH
      DELETE = :DELETE

      attr_reader :routes

      def initialize(routes=(Rails.application.routes.routes))
        @routes = parse_routes routes
      end

      def each(&block)
        @routes.each &block
      end

      private
      def parse_routes(routes)
        result = []

        routes.each do |route|
          verb = route.verb.downcase.to_sym
          path = route.format({id: 1})
          controller = route.defaults[:controller]

          next if controller.nil?
          next if path.empty?
          next if path.start_with? '/rails'

          controller = (controller + "_controller").classify.constantize
          action = route.defaults[:action].to_sym
          formats = []


          result << Route.new(verb, path, controller, action, formats)
        end

        result
      end
    end
  end
end