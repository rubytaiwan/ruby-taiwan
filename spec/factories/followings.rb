# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :following do
    followable nil
    user nil
  end
end
