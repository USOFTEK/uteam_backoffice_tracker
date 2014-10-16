attributes(:id, :username, :ip, :email, :netmask, :speed, :registration, :initials, :created_at, :updated_at)

child(:tariff) { attributes(:id, :name, :month_fee, :day_fee) }

child(:billing) { attributes(:id, :deposit) }

child(:phones) { attributes(:id, :number, :is_mobile, :is_main) }