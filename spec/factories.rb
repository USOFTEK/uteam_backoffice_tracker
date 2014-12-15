require "active_support/all"

FactoryGirl.define {
	sequence(:username) { |n| "#{["gena", "ruslan", "lesya", "leo", "test"].sample}-#{n}" }
	sequence(:date_interval) { |n| Time.now - n.to_i.day }
	sequence(:build_phone_number) { |n| "+380#{[34, 66, 95, 50, 67, 90].sample}#{[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].shuffle.join[0,7]}" }
	sequence(:uniq_name) { |n| "#{Faker::Lorem.word}-#{n}" }
	sequence(:id) { |n| n }
	sequence(:date) { |n| Faker::Date.backward(n.to_i + 1) }
	sequence(:amount) { |n| Faker::Commerce.price + n }

	factory(:user) {
		username { generate(:username) }
		ip { Faker::Internet.ip_v4_address }
		email { Faker::Internet.safe_email }
		initials { Faker::Name.name }
		address_street { Faker::Address.street_name }
		address_build { Faker::Address.building_number }
		address_flat { Faker::Number.digit }
		netmask { Faker::Internet.ip_v4_address }
		registration { Faker::Time.between(rand(366).day.ago, Time.now) }
		speed { "#{Faker::Number.number(3)} Mb/s" }
		bonus_percent { rand(10) }
		chat_notification(true)

		tariff

		group
		
		transient {
			phones_count 5
			network_activities_count 50
			bonus_pays_count 5
			friends_count 3

		}

		after(:create) { |user,evaluator|
			user.billing = create(:billing_with_statistics, user: user)
			# user.phones << create_list(:phone, evaluator.phones_count, user: user, is_mobile: [true, false].sample, is_main: [true, false].sample)
			user.mobile_phone = create(:phone, user: user, is_mobile: true, is_main: false)
			user.primary_phone = create(:phone, user: user, is_mobile: false, is_main: true)
			user.network_activities << create_list(:network_activity, evaluator.network_activities_count, user: user)
			user.bonus_pays << create_list(:bonus_pay, evaluator.bonus_pays_count, user: user)

		}

		trait(:with_team) {
			after(:create) { |user,evaluator|
				user.bonus_pays << create_list(:bonus_pay, evaluator.bonus_pays_count, user: user)
				user.friends << create_list(:user, evaluator.friends_count, password: "user_password" )
			}
		}

	}
	
	factory(:tariff) {
		name { generate(:username) }
		month_fee { Faker::Commerce.price }
		day_fee { Faker::Commerce.price }

		tv_package

		trait(:with_groups) {
			after(:create) { |tar|
				create_list :group, 5, tariffs: [tar]
			}
		}

	}

	factory(:phone) {
		number { generate(:build_phone_number) }
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

	factory(:tv_package) {
		name { generate(:uniq_name) }
		source { Faker::Internet.url }
		description { Faker::Lorem.sentence }
	}

	factory(:group) {
		id { generate(:id) }
		name { generate(:uniq_name) }
		description { Faker::Lorem.sentence }

		trait(:with_tariffs) {
			after(:create) { |gr|
				create_list :tariff, 5, groups: [gr]
			}
		}
	}

	factory(:abonement) {
		id { generate(:id) }
		name { generate(:uniq_name) }
		period { rand(99) }
		cost { Faker::Commerce.price }
		payment_type { [true, false].sample }
	}

	factory(:bonus_pay) {
		day { generate(:date) }
		amount { generate(:amount) }
		paid { false }
	}

}
