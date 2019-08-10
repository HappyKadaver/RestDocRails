class Pet < ApplicationRecord
  include RestDocRails::ModelDocumentation

  validates :age, presence: true
  validates :age, length: {minimum: 0, maximum: 20}
  validates :name, format: {with: /[\w\d]+/}

  field :age, type: Integer
  field :name, type: String

  doc_attribute :age, "Age of Pet"
  doc_attribute :name, "name of pet"
end
