FactoryBot.define do
  factory :user do
    email { "user@test.com" }
    password { BCrypt::Password.create("password") }
  end
end
