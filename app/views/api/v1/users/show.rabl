attributes(:id, :username, :disable, :ip, :email, :address_street, :address_build, :address_flat, :netmask, :speed, :registered, :initials, :credit, :created, :updated)

child(:tariff) { attributes(:id, :name, :month_fee, :day_fee) }

child(:billing) { attributes(:id, :deposit) }

child(:phones) { attributes(:id, :number, :is_mobile, :is_main) }