require 'rails_helper'

describe 'ControllerDocumentation' do
  context 'dummy PetsController' do
    it 'should have a documentation for the index route' do
      expect(PetsController.doc_action).to include(:index)
    end
  end

  context 'dummy PetsController' do
    it 'should have no documentation on any routes' do
      expect(OwnersController.doc_action).to be_nil.or(be_empty)
    end
  end
end