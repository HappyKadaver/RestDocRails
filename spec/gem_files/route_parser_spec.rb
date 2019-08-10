require 'rails_helper'
require 'rest_doc_rails/parser/RouteParser'

RSpec.describe "RouteParser" do
  let(:route_parser) { RestDocRails::Parser::RouteParser.new Rails.application.routes.routes }

  describe 'can list available routes' do
    it("should include expected routes") { expect(route_parser.routes).to include(RestDocRails::Route.new :GET, "/pets", PetsController, :index, []) }
  end
end
