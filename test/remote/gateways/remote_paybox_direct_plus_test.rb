require 'test_helper'

class RemotePayboxDirectPlusTest < Test::Unit::TestCase
  
  def setup
    @gateway = PayboxDirectPlusGateway.new(fixtures(:paybox_direct_plus))
    
    @amount = 100
    @credit_card = credit_card('1111222233334444')
    @declined_card = credit_card('1111222233334445')
    
    @options = { 
      :order_id => "REF#{Time.now.usec}",
      :user_reference => "USER#{Time.now.usec}"
    }
  end
  
  def test_create_profile
    assert response = @gateway.create_payment_profile(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'The transaction was approved', response.message
  end
  
  def test_create_profile_and_capture
    assert response = @gateway.create_payment_profile(@amount, @credit_card, @options)
    assert_success response
    
    credit_card_reference = response.params["credit_card_reference"]
    assert_not_nil credit_card_reference
    
    @credit_card.number = nil
    
    assert capture = @gateway.capture(@amount, response.params["authorization"], @options)
    assert_success capture
  end
  
  def test_create_profile_and_purchase
    assert response = @gateway.create_payment_profile(@amount, @credit_card, @options)
    assert_success response
    
    credit_card_reference = response.params["credit_card_reference"]
    assert_not_nil credit_card_reference
    
    @credit_card.number = nil
    
    assert_response = @gateway.purchase(@amount, @credit_card, @options.merge({ :credit_card_reference => credit_card_reference }))
    assert_success response
    assert_equal 'The transaction was approved', response.message
  end
end

