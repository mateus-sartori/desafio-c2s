class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string  :title, null: false
      t.integer :status, null: false, default: 0
      t.string  :url, null: false
      t.jsonb   :result
      t.text    :error_message
      t.bigint  :user_id, null: false

      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :tasks, :user_id
    add_index :tasks, :status
    add_index :tasks, :created_at
  end
end
