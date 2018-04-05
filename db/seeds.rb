User.create!(
  email: "admin@admin.com",
  password: "adminpass",
  password_confirmation: "adminpass",
  roles: "admin"
)

puts "1 Admin user created"

User.create!(
  email: "test@test.com",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
)

puts "1 regular user created"
