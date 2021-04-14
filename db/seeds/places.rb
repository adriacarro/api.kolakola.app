if Place.none?
  address = Address.create(name: 'Turris Plaça Molina', code: '', street_1: 'Plaça Molina 2', street_2: '', city: 'Barcelona', state: 'Barcelona', zip_code: '08006', country_code: 'ES')
  billing_address = Address.create(name: 'Turris S.L.', code: 'V19237475', street_1: 'Plaça Molina 2', street_2: '', city: 'Barcelona', state: 'Barcelona', zip_code: '08006', country_code: 'ES')

  Place.create(name: 'Turris', category_id: Category.first.id, address_id: address.id, billing_address_id: billing_address.id)
end