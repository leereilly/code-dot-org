require 'test_helper'

module Pd::Application
  class FacilitatorApplicationControllerTest < ::ActionController::TestCase
    test 'logged out users see the logged out message' do
      get :new
      assert_response :success
      assert_template :logged_out
      assert_select 'p', /To get started, you first need to be logged into your Code\.org account\./
    end

    test 'students see the not teacher message' do
      sign_in create(:student)
      get :new
      assert_response :success
      assert_template :not_teacher
      assert_select 'p', /You’re currently signed into a student account\./
    end

    test 'submitted is displayed when the teacher has already already submitted and application' do
      application = create :pd_facilitator1819_application
      sign_in application.user
      get :new
      assert_response :success
      assert_template :submitted
      assert_select 'h1', 'Thank you for your application.'
    end

    test 'application form is displayed for new teachers before Dec 1' do
      Timecop.freeze Time.zone.local(2017, 11, 30) do
        sign_in create(:teacher)
        get :new
        assert_response :success
        assert_template :new
        assert_select 'h1', '2018-2019 Code.org Facilitator Application'
      end
    end

    test 'after Dec 1 2017 applications are closed' do
      Timecop.freeze Time.zone.local(2017, 12, 1) do
        sign_in create(:teacher)
        get :new
        assert_response :success
        assert_template :closed
        assert_select 'p', /Applications to join the facilitator development program are no longer being accepted this year\./
      end
    end

    test 'submitted page displays regional partner when there is a match' do
      regional_partner = create :regional_partner
      application = create :pd_facilitator1819_application, regional_partner: regional_partner
      sign_in application.user
      get :new
      assert_response :success
      assert_select 'p', /Your Code.org Regional Partner is:\s#{regional_partner.name}/
    end

    test 'submitted page displays no partner message when there is no match' do
      application = create :pd_facilitator1819_application, regional_partner: nil
      sign_in application.user
      get :new
      assert_response :success
      assert_select 'p', /Your application is not yet matched to a Code\.org Regional Partner\./
    end
  end
end
