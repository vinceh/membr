class EventsController < ApplicationController
  protect_from_forgery

  def stripe_event
    eventJSON = JSON.parse(request.body.read)

    id = eventJSON['id']
    if id
      event = Stripe::Event.retrieve(id)

      case event.type
        when 'invoice.payment_succeeded'
          member = Member.find_by_stripe_customer_id(event.data.object.customer)
          member.paid = true
          member.paid_time = Time.at(event.data.object.date)
          MemberMailer.invoice(member, member.membership).deliver
          member.save!
        when 'invoice.payment_failed'
          member = Member.find_by_stripe_customer_id(event.data.object.customer)
          member.paid = false
          member.paid_time = Time.at(event.data.object.date)
          member.save!
        when 'charge.succeeded'
          invoice = Invoice.new
          invoice.stripe_charge_id = event.data.object.id
          invoice.amount = event.data.object.amount
          invoice.stripe_fee = event.data.object.fee
          invoice.member = Member.find_by_stripe_customer_id(event.data.object.customer)
          invoice.save!
        when 'customer.updated'
          if ( event.data.previous_attributes.subscription )
            member = Member.find_by_stripe_customer_id(event.data.object.id)
            member.active = false
            member.save!
          end
      end
    end

    render :json => {:success => true}
  end

  def test_stripe
    id = 'evt_2CsdLAslp8drr3'

    event = Stripe::Event.retrieve(id)

    case event.type
      when 'charge.succeeded'
        invoice = Invoice.new
        invoice.stripe_charge_id = event.data.object.id
        invoice.amount = event.data.object.amount
        invoice.stripe_fee = event.data.object.fee
        invoice.member = Member.find_by_stripe_customer_id(event.data.object.customer)
        invoice.save!
    end

    render :json => JSON.pretty_generate(JSON.parse(event.to_json))
  end

  def test_stripe2
    id = 'cus_22cgwGgBa8J9zm'

    event = Stripe::Invoice.all(
      :customer => id,
      :count => 5
    )

    render :json => JSON.pretty_generate(JSON.parse(event.data.to_json))
  end
end
