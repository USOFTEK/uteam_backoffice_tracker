collection @object, root: "tariffs"
attributes(:id, :name, :month_fee, :day_fee, :created_at)
child(:tv_package) {
	attributes(:id, :name)
}