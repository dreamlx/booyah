require 'net/http'
require 'uri'

module TextingHelper

  def send_order_success_sms(order, receiver)
    message = 
      "Hello #{order.user.first_name}, " +
      "your image has been received and it will be shipped to #{receiver.formatted_name} shortly! " +
      "Order total: $#{order.user_cost}."
    send_sms(order.user.cell, message)
  end

  def send_failed_order(user)
    message = 
      "Hello #{user.first_name}, " +
      "We are sorry, something went wrong and we could not complete your order!"
    send_sms(user.cell, message)
  end

  def send_contact_list_message(user)
    message = 
      "Hello #{user.first_name}, " +
      "Here is the list of contacts: #{user.get_all_contacts}"
    send_sms(user.cell, message)
  end

  def send_could_not_recognize_receiver_message(user)
    message = 
      "Hello #{user.first_name}, " +
      "We are sorry, we could not recognize the receiver for this picture! Reply with 'people' to get a list."
    send_sms(user.cell, message)
  end

  def send_order_success_with_credits_sms(order, receiver)
    message = 
      "Hello #{order.user.first_name}, " +
      "your image has been received and it will be shipped to #{receiver.formatted_name} shortly! " +
      "You used one credit."
    send_sms(order.user.cell, message)
  end

  def send_paypal_failed_message(user)
    message = 
      "Hello #{user.first_name}, " +
      "We are sorry, paypal will not allow us to complete your order. Please check your paypal account and contact us!"
    send_sms(user.cell, message)
  end

  def send_account_incomplete_message(user)
    message = 
      "Hello #{user.first_name}, " +
      "Your account is not active. Please go to booyahbooyah.com to finish activating it!"
    send_sms(user.cell, message)
  end

  def send_no_user_message(cell)
    message = 
      "Hello! This number is not registered with Booyah. " +
      "Please go to booyahbooyah.com to begin getting prints!"
    send_sms(cell, message)
  end

  def send_no_image_response(user)
    message = 
      "Hello #{user.first_name}, " +
      "It appears there was no image attached to that message!"
    send_sms(user.cell, message)
  end

  def send_welcome_message(user)
    message = 
      "Hello #{user.first_name}, welcome to Booyah! " +
      "Send a picture along with the text 'booyah' to this number to place print orders!"
    send_sms(user.cell, message)
  end

  def send_sms(to, message)
    url = URI.parse(
      "https://api.mogreet.com/moms/transaction.send?" +
      "client_id=4824" +
      "&token=8b229bb3e0a15ea0b5406ddc6d55be6f" +
      "&campaign_id=49137" +
      "&to=#{URI::encode(to)}" +
      "&message=#{URI::encode(message)}" +
      "&format=json"
    )
    if !Rails.env.test?
      response = Net::HTTP.start(url.host, use_ssl: true, ssl_version: 'SSLv3', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get url.request_uri
      end
    else
      raise message
    end
  end

  def send_mms(message, media)

  end
end