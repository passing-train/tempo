class Project < CDQManagedObject

  def customer_name
    customer = Customer.where(:customer_id).eq(customer_id).first if customer_id
    if customer
      customer.name
    else
      ''
    end
  end

end
