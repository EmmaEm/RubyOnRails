class Section < ApplicationRecord
  has_many :section_students
  has_many :students, through :section_students
end
