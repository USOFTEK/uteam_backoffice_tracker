attributes(:id, :username, :disable, :ip, :email, :address_street, :address_build, :chat_notification, 
						:address_flat, :netmask, :speed, :registered, :initials, :credit, :created, :updated)

child(:tariff) { attributes(:id, :name, :month_fee, :day_fee) }

child(:billing) { attributes(:id, :deposit) }

child(:mobile_phone => :mobile_phone) { attributes(:number) }

child(:primary_phone => :primary_phone) { attributes(:number) }