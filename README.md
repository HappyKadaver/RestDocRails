# RestDocRails
This plugin allows you to generate an openapi 3.0 documentation of your rest endpoints.
It tries to guess as much as it can while being as unintrusive as possible.
It still needs a lot of work as it was created in one week to document my master thesis and was a bit rushed.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'nokogiri', :git => 'https://github.com/HappyKadaver/RestDocRails.git'
```

And then execute:
```bash
$ bundle
```

## Usage
### Documenting your controller endpoints

```ruby
class ApplicationController < ActionController::Base
  include RestDocRails::ControllerDocumentation
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

class PetsController < ApplicationController
  self.doc_default_response_types = [:json]

  # doc is used to write a description for your action
  # doc <action_name>, <description> 
  doc :index, <<~DOC
  returns a list of all pets
  that are stored in the database
  DOC
  
  # doc_response is used to document the content of your responses
  # doc_response <action_name>, <http_status_code>, <response_body_example>, <description>, [array of response types]
  # http_status_code: may be the symbol representation as defined in Rack::Utils::SYMBOL_TO_STATUS_CODE or the integer number
  # array of response types: this is optional. If not set it will use the value set with self.doc_default_response_types=<value> or it will default to html
  
  # doc_model_response_body is a method that tries to guess a response/request body by looking at your model classes.
  # If the model class includes ModelDocumentation the result will use the documentation you defined in your model class. 
  # doc_model_response_body [model_class]
  # model_class: optional if not defined the class is quessed based on the controller name
  doc_response :index, 200, doc_array_of(doc_model_response_body), "json array of pets"
  
  # doc_query_param is used to document query parameters
  # doc_query_param <action_name>, <query parameter name>, <required>, <schema>, <description>
  # schema: example value that is processed into the openapi schema format  
  doc_query_param :index, :page, false, 1, "Page number for pagination"
  # GET /pets
  def index
    @pets = Pet.all
  end

  doc_response :show, :ok, doc_model_response_body, "json object representing the pet"
  # GET /pets/1
  def show
  end

  doc_response :new, :locked, {
      data: doc_model_response_body,
      other_stuff: {
          page: "current_page",
          some_more: "explain yourself"
      }
  }, "json object containing pet and pagination data"
  # GET /pets/new
  def new
    @pet = Pet.new
  end

  # doc_request is used to document your request body
  # doc_request <action_name>, <example request body>, [description=''], [request_types]
  # array of request types: possible content types for your request body. This is optional. If not set it will use the value set with self.doc_default_response_types=<value> or it will default to html
  doc_request :create, { pet: doc_model_response_body }
  # POST /pets
  def create
    # ...
  end
  
  # ...
end
```
### Documenting your model classes for data schemas
```ruby
class Pet < ApplicationRecord
  include RestDocRails::ModelDocumentation

  validates :age, presence: true
  validates :age, length: {minimum: 0, maximum: 20}
  validates :name, format: {with: /[\w\d]+/}

  # doc_attribute is used to document an attribute of your model class.
  # By default it will try to guess additional information by looking at your defined validators. 
  # doc_attribute(<attribute_name>, <description>, [skip_validators_attributes: false] 
  # skip_validators_attributes: pass true to skip looking at validators
  doc_attribute :age, "Age of Pet"
  doc_attribute :name, "name of pet"
end
```

## Contributing
Contribution directions go here.

## Development
May need to create symbolic link to run tests.

```bash
cd spec/dummy
ln -s ../../spec
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
