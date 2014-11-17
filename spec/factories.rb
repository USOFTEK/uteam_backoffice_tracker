FactoryGirl.define {
	sequence(:username) { |n| "#{Faker::Internet.user_name}_#{n}" }
	sequence(:date_interval) { |n| Time.now - n.to_i.day }

	factory(:user) {
		username { "#{["gena", "ruslan", "lesya", "leo", "test"].sample}#{Random.rand(100)}" }
		ip { Faker::Internet.ip_v4_address }
		email { Faker::Internet.safe_email }
		initials { Faker::Name.name }
		address_street { Faker::Address.street_name }
		address_build { Faker::Address.building_number }
		address_flat { Faker::Number.digit }
		netmask { Faker::Internet.ip_v4_address }
		registration { Faker::Time.between(rand(366).day.ago, Time.now) }
		speed { "#{Faker::Number.number(3)} Mb/s" }

		tariff

		transient {
			phones_count 5
			network_activities_count 50

		}

		after(:create) { |user,evaluator|
			user.billing = create(:billing_with_statistics, user: user)
			# user.phones << create_list(:phone, evaluator.phones_count, user: user, is_mobile: [true, false].sample, is_main: [true, false].sample)
			user.mobile_phone = create(:phone, user: user, is_mobile: true, is_main: false)
			user.primary_phone = create(:phone, user: user, is_mobile: false, is_main: true)
			user.network_activities << create_list(:network_activity, evaluator.network_activities_count, user: user)
		}

	}
	
	factory(:tariff) {
		name { generate(:username) }
		month_fee { Faker::Commerce.price }
		day_fee { Faker::Commerce.price }

	}

	factory(:phone) {
		number { Faker::PhoneNumber.cell_phone }
		is_mobile(true)
		is_main(true)

		user

	}

	factory(:billing) {
		deposit { Faker::Commerce.price }

		user

		factory(:billing_with_statistics) {
			transient {
				payments_count 5
				fees_count 5
				
			}

			after(:create) { |billing, evaluator|
        create_list(:payment, evaluator.payments_count, billing: billing)
        create_list(:fee, evaluator.fees_count, billing: billing)

      }

		}

	}

	factory(:payment) {
		amount { Faker::Commerce.price }
		description { Faker::Lorem.sentence }
		ip { Faker::Internet.ip_v4_address }

		billing

	}

	factory(:fee) {
		amount { Faker::Commerce.price }
		description { Faker::Lorem.sentence }
		ip { Faker::Internet.ip_v4_address }

		billing

	}

	factory(:network_activity) {
		sent { Faker::Number.number(6) }
		received { Faker::Number.number(6) }
		per { generate(:date_interval) }

		user

	}

}
