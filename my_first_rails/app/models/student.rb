class Student < User
  has_many :section_students
  has_many :sections, through: :section_students
end
