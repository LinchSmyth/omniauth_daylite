require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    # @example Basic Usage
    #     use OmniAuth::Strategies::Daylite, 'APP ID', 'APP Secret'
    #
    class Daylite < OmniAuth::Strategies::OAuth2

      option :name, 'daylite'

      option :client_options, {
        site:          'https://www.marketcircle.com/',
        authorize_url: 'account/oauth/authorize',
        token_url:     'account/oauth/token'
      }

      option :redirect_url, nil

      uid { raw_info['uid'] if create_uid? }

      # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      info do
        raw_information = raw_info

        {
          :name        => "#{raw_information['first_name']} #{raw_information['last_name']}".strip,
          :email       => raw_information['login'],
          :first_name  => raw_information['first_name'],
          :last_name   => raw_information['last_name']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        fetch_user_data
      end

      def callback_url
        custom_callback || full_host + script_name + callback_path
      end


      protected


      def build_access_token
        ###                        code, params, options
        client.auth_code.get_token(
          request.params["code"],
          { redirect_uri: callback_url }.merge(token_params.to_hash(:symbolize_keys => true)),
          deep_symbolize(options.auth_token_params)
        )
      end

      def fetch_user_data
        return {} if only_token?

        authorization = "Bearer #{access_token.to_hash[:access_token]}"

        conn = Faraday.new(:url => resource_url('/v1/info'))
        user_data = JSON.parse(conn.get { |req| req.headers["Authorization"] = authorization }.body)

        # get ":id" from "/v1/users/:id"
        user_data['uid'] = user_data['user'].split('/').last if create_uid?

        conn = Faraday.new(:url => resource_url(user_data['user']))
        user_data2 = JSON.parse(conn.get { |req| req.headers["Authorization"] = authorization }.body)

        conn = Faraday.new(:url => resource_url(user_data2['contact']))
        user_data3 = JSON.parse(conn.get { |req| req.headers["Authorization"] = authorization }.body)

        user_data.merge(user_data2).merge(user_data3).reject { |k,_v| filter_fields.include?(k) }
      end

      def resource_url(endpoint)
        "https://api.marketcircle.net#{endpoint}"
      end

      def create_uid?
        options[:create_uid].present? ? options[:create_uid] : true
      end

      def only_token?
        options[:only_token].present? ? options[:only_token] : false
      end

      def filter_fields
        options[:filter] || %w(self owner creator contact user)
      end

      def custom_callback
        options[:custom_callback] || nil
      end
    end
  end
end
