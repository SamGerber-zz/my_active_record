class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  validates :name, presence: true, uniqueness: true

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :cats, foreign_key: :owner_id
  belongs_to :house

  finalize!
end

class House < SQLObject
  has_many :humans

  finalize!
end
