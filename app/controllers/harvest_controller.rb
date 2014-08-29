class HarvestController < ApplicationController

  def start
    authorize! :update, current_user
    redirect_url = flow.start()
    redirect_to redirect_url
  end

  def activate
    authorize! :update, current_user
    begin
      access_token, refresh_token, expiry_date = flow.finish(params)

      current_user.harvest_token = access_token
      current_user.harvest_refresh_token = refresh_token
      current_user.harvest_token_expiry_date = expiry_date
      current_user.save

      redirect_to edit_user_registration_path, notice: I18n.t(:"messages.harvest.activate.success")
    rescue StandardError => e
      puts e
      redirect_to edit_user_registration_path, alert: I18n.t(:"messages.harvest.activate.failure")
    end
  end

  def deactivate
    authorize! :update, current_user
    current_user.harvest_token = nil
    current_user.harvest_token_expiry_date = nil
    current_user.save

    redirect_to edit_user_registration_path, notice: I18n.t(:"messages.harvest.deactivate.success")
  end

  def full_import
    authorize! :update, current_user
    redirect_to edit_user_registration_path, alert: I18n.t(:"messages.harvest.full_import.failure")
  end

  private

  def flow
    @flow ||= HarvestOAuth2Flow.new(
      Rails.application.secrets[:harvest_key],
      Rails.application.secrets[:harvest_secret],
      activate_harvest_url,
      session[:_csrf_token]
    )
  end

  class HarvestOAuth2Flow
    require 'net/http'
    require 'uri'

    def initialize(client_id, client_secret, redirect_url, csrf_token)
      unless client_id.is_a?(String)
        raise ArgumentError.new("ClientId has to be a String, got #{client_id}")
      end
      unless client_secret.is_a?(String)
        raise ArgumentError.new("ClientSecret has to be a String, got #{client_secret}")
      end
      unless redirect_url.is_a?(String)
        raise ArgumentError.new("RedirectUrl has to be a String, got #{redirect_url}")
      end
      unless csrf_token.is_a?(String)
        raise ArgumentError.new("csrf_token has to be a String, got #{csrf_token}")
      end
      @client_id = client_id
      @client_secret = client_secret
      @redirect_url = redirect_url
      @csrf_token = csrf_token
    end

    def start
      "https://api.harvestapp.com/oauth2/authorize?client_id=#{@client_id}&redirect_uri=#{@redirect_url}&state=#{@csrf_token}&response_type=code"
    end

    def finish(request_params)
      auth_code = request_params[:code]
      payload = {
        "code" =>          auth_code,
        "client_id" =>     @client_id,
        "client_secret" => @client_secret,
        "redirect_uri" =>  @redirect_url,
        "grant_type" =>    "authorization_code"
      }
      uri = URI('https://api.harvestapp.com/oauth2/token')
      response = JSON.parse(Net::HTTP.post_form(uri, payload).body)
      access_token = response["access_token"]
      refresh_token = response["refresh_token"]
      expires_in = response["expires_in"]
      now = Time.now.utc
      expiry_date = now + expires_in
      return access_token, refresh_token, expiry_date
    end

  end

end
