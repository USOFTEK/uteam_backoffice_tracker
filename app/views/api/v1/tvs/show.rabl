child(:object, object_root: false) {
	attributes(:id, :name)
}
child(:playlist) {
	attributes(:name, :description, :stream)
}