class Api::V1::Census::CensusController < ApplicationController
  include SchoolInfoDeduplicator
  skip_before_action :verify_authenticity_token

  CENSUS_FIELDS = [
    :school_year,
    :submitter_email_address,
    :submitter_name,
    :submitter_role,
    :how_many_do_hoc,
    :how_many_after_school,
    :how_many_10_hours,
    :how_many_20_hours,
    :other_classes_under_20_hours,
    :topic_blocks,
    :topic_text,
    :topic_robots,
    :topic_internet,
    :topic_security,
    :topic_data,
    :topic_web_design,
    :topic_game_design,
    :topic_other,
    :topic_other_description,
    :topic_do_not_know,
    :class_frequency,
    :tell_us_more,
    :pledged,
    :share_with_regional_partners
  ].freeze

  CHECKBOX_FIELDS = [
    :other_classes_under_20_hours,
    :topic_blocks,
    :topic_text,
    :topic_robots,
    :topic_internet,
    :topic_security,
    :topic_data,
    :topic_web_design,
    :topic_game_design,
    :topic_other,
    :topic_do_not_know,
    :pledged
  ].freeze

  # POST /dashboardapi/v1/census/<form_version>
  def new_submission
    errors = {}

    school_id = params[:nces_school_s]
    begin
      # '-1' is the indicator that the user couldn't find the school in the dropdown
      school = School.find(school_id) if school_id.presence && school_id != '-1'
    rescue ActiveRecord::RecordNotFound
      errors[:nces_school_s] = "School id not found"
    end

    if school
      attrs = {school_id: school.id}
    else
      attrs = {
        country: params[:country_s],
        school_type: params[:school_type_s],
        state: params[:school_state_s],
        zip: params[:school_zip_s],
        school_name: params[:school_name_s],
        full_address: params[:school_location],
        validation_type: SchoolInfo::VALIDATION_NONE
      }
    end

    school_info = get_duplicate_school_info(attrs)
    unless school_info
      school_info = SchoolInfo.new attrs
      errors.merge!(school_info.errors) unless school_info.valid?
    end

    census_params = params.slice(*CENSUS_FIELDS).permit(*CENSUS_FIELDS)

    # Checkboxes don't get submitted if they aren't checked.
    # Set them to false if they are nil
    CHECKBOX_FIELDS.map do |field|
      census_params[field] = false unless census_params[field]
    end
    census_params[:school_infos] = [school_info]

    case params[:form_version]
    when 'CensusYourSchool2017v5'
      submission = ::Census::CensusYourSchool2017v5.new census_params
      template = 'census_form_receipt'
    when 'CensusYourSchool2017v4'
      submission = ::Census::CensusYourSchool2017v4.new census_params
      template = 'census_form_receipt'
    when 'CensusHoc2017v3'
      submission = ::Census::CensusHoc2017v3.new census_params
      template = 'hoc_census_2017_pledge_receipt' if submission.pledged
    else
      errors[:form_version] = "Invalid form_version"
    end

    errors.merge!(submission.errors) unless submission.nil? || submission.valid?

    if errors.empty?
      ActiveRecord::Base.transaction do
        school_info.save
        submission.save
      end
      if template
        recipient = Poste2.create_recipient(submission.submitter_email_address,
          name: submission.submitter_name,
          ip_address: request.remote_ip
        )
        Poste2.send_message(template, recipient)
      end
      render json: {census_submission_id: submission.id}, status: :created
    else
      render json: errors, status: :bad_request
    end
  end
end
