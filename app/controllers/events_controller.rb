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
          if Member.find_by_stripe_customer_id(event.data.object.customer)
            invoice = Invoice.new
            invoice.stripe_charge_id = event.data.object.id
            invoice.amount = event.data.object.amount
            invoice.stripe_fee = event.data.object.fee
            invoice.member = Member.find_by_stripe_customer_id(event.data.object.customer)
            invoice.save!
          else
            charge = Usercharge.new
            charge.user = User.find_by_stripe_customer_id(event.data.object.customer)
            charge.stripe_charge_id = event.data.object.id
            charge.amount = event.data.object.amount
            charge.stripe_fee = event.data.object.fee
            charge.number_of_members = charge.amount/ENV['MONTHLY_MEMBER_FEE'].to_i
            charge.save!
          end
        when 'customer.subscription.deleted'
          member = Member.find_by_stripe_customer_id(event.data.object.customer)
          member.active = false
          member.save!
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
