class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses do |t|
      # participant — тот, кто заплатил за трату
      t.references :participant, null: false, foreign_key: true
      t.string :title, null: false
      # decimal, а не float: деньги нельзя хранить с погрешностью
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
