class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.string :body

      t.belongs_to :post, null: false, foreign_key: true

      t.belongs_to :user, null: true, foreign_key: true

      t.boolean :anonymous, null: false, default: true

      t.timestamps
    end
  end
end
