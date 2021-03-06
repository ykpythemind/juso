class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps
    end

    create_table :posts do |t|
      t.string :title

      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
