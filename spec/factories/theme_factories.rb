FactoryGirl.define do
  factory :my_theme, class: PublishMyData::Theme do
    initialize_with { new(uri) }
    label 'My Theme'
    description 'A test theme'

    ignore do
      uri { "http://#{PublishMyData.local_domain}/def/theme/my_theme" }
    end
  end
end