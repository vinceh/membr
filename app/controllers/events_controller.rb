class EventsController < ApplicationController
  protect_from_forgery

  def stripe_event
    eventJSON = JSON.parse(request.body)

    unless Event.find_by_token(eventJSON['id'])

      # to make sure this is actually coming from Stripe
      res = Stripe::Event.retrieve(eventJSON['id'])
    end
  end

  def test_stripe
    id = 'evt_22cgBIXzq48uVc'

    event = Stripe::Event.retrieve(id)

    case event.type
      when 'invoice.payment_succeeded'
        member = Member.find_by_stripe_customer_id(event.data.object.customer)
        member.paid = true
        member.paid_time = Time.at(event.data.object.date)
        member.save!
      when 'invoice.payment_failed'
        member = Member.find_by_stripe_customer_id(event.data.object.customer)
        member.paid = false
        member.paid_time = Time.at(event.data.object.date)
        member.save!
    end

    render :json => JSON.pretty_generate(JSON.parse(event.to_json))
  end
end
