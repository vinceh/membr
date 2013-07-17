module ApplicationHelper

  def membership_options(memberships)
    options = ''

    memberships.each do |m|
      unless m.is_private
        options = options + "<option value=\"#{m.id}\" data-amount=\"#{m.display_fee}\" data-renewal=\"#{m.renewal_text}\">#{m.name} - #{m.display_fee}/#{m.renewal_text}</option>"
      end
    end

    raw options
  end

  def invoice_amount(invoices)
    fee = invoices.inject(0) { |sum, n| sum + n.amount-n.stripe_fee }
    "$#{sprintf("%5.2f", fee/100)}"
  end
end