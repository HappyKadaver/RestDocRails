module RestDocRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/rest_doc_rails_tasks.rake'
    end
  end
end
