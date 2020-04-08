#!/usr/bin/env ruby

require './spec/spec_helper'

describe 'Login' do
  before do
    @user = admin_session.create_test_user
  end

  after do
    admin_session.destroy_test_user(@user)
  end

  it 'should log in' do
    page.log_in_as(@user)
    page.assert_selector('nav .logged-in', wait: WAIT_LOAD)
    page.assert_selector('nav .logged-in strong', text: @user[:email])
  end
end
