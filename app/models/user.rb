class User < ApplicationRecord
  has_secure_password
  has_many :meetings, foreign_key: "student_id"
  has_many :meetings, foreign_key: "teacher_id"

  def teacher?
    !self.student
  end

  def student?
    self.student
  end
end
