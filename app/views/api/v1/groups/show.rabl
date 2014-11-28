attributes(:id, :name, :description)
child(:tariffs) {
	attributes(:id, :name, :month_fee, :day_fee, :created_at)
}