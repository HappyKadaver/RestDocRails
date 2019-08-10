# desc "Explaining what the task does"
# task :rest_doc_rails do
#   # Task goes here
# end

require_relative '../rest_doc_rails/documentation_generator'

desc "Generate Api Documentation"
namespace "rest_doc_rails" do
  task documentation: :environment do
    generator = RestDocRails::DocumentationGenerator.new

    File.open Rails.root.join('api_doc.yml'), 'w' do |file|
      generator.write_documentation file
    end
  end
end