class CreateScrapeTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :scrape_tasks do |t|
      t.bigint  :task_id, null: false
      t.integer :status, null: false, default: 0
      t.string  :url, null: false

      t.jsonb   :result
      t.text    :error_message

      t.integer :retry_count, default: 0
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :scrape_tasks, :task_id
    add_index :scrape_tasks, :status
  end
end
