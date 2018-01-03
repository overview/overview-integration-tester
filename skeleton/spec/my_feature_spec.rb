#!/usr/bin/env ruby

require './spec/spec_helper'

describe 'My Feature' do
  before do
    @user = admin_session.create_test_user
    page.log_in_as(@user)
    page.create_document_set_from_pdfs_in_folder('files/my-feature-spec')
  end

  after do
    admin_session.destroy_test_user(@user)
  end

  it 'should show the document set' do
    page.assert_selector('h2', text: 'files/my-feature-spec')
  end
end
