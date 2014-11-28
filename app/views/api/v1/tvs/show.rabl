child(:object, object_root: false) {
	attributes(:id, :name)
}
child(:playlist, root: "playlist") {
	node { |n|
		n
	}
}