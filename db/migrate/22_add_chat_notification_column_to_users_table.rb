class AddChatNotificationColumnToUsersTable < ActiveRecord::Migration
  def up
    add_column(:users, :chat_notification, :boolean, default: true)
    add_index(:users, :chat_notification)
  end
  def down
  	remove_index(:users, :chat_notification)
    remove_column(:users, :chat_notification)
  end
end