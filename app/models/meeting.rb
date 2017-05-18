
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless Meeting.where(time_slot: record.time_slot, date: record.date).count < 2
      record.errors[:time_slot] << 'can only have two requests for a given day'
    end

    if record.time_slot == "Discuss with Instructor" && !(record.date.friday? || record.date.saturday?)
      record.errors[:time_slot] << 'to discuss with instructor only available on Friday or Saturday'
    end

    if (record.date.friday? || record.date.saturday?) && record.time_slot != "Discuss with Instructor"
      record.errors[:time_slot] << 'can only be set on Friday and Saturday by discussing with instructor'
    end

    if record.date.sunday? && record.time_slot != "After Class"
      record.errors[:time_slot] << 'can only be set to After Class for Sundays'
    end
  end
end

class Meeting < ApplicationRecord
  include ActiveModel::Validations
  belongs_to :student, class_name: "User"
  belongs_to :teacher, class_name: "User", optional: true

  validates :time_slot, presence: true
  validates :date, presence: true

  validates :student_id, uniqueness: { scope: [:date], message: "should only sign up for one slot per day."}
  validates_with MyValidator, on: :create

  def self.suggested_grouped
    where(suggested: true).includes(:student).order(:date).select { |meeting| meeting.date >= Date.today }.group_by(&:date)
  end

  def self.scheduled_grouped
    where(suggested: false).includes(:student).order(:date).order(:date).select { |meeting| meeting.date >= Date.today }.group_by(&:date)
  end

  def self.available_dates
    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  end

  def self.available_time_slots
    ["5:15 - 5:45", "4:45 - 5:15", "4:15 - 4:45", "After Class", "Discuss with Instructor"]
  end

  def email_teachers_available
    if date.sunday?
      available_teachers = ["Jim", "Dan", "Joy", "Ben"]
    elsif date.monday?
      available_teachers = ["Dan", "Joy"]
    elsif date.tuesday?
      available_teachers = ["Joy", "Ben"]
    elsif date.wednesday?
      available_teachers = ["Dan", "Evan"]
    elsif date.thursday?
      available_teachers = ["Dan", "Evan"]
    else
      available_teachers = ["Jim", "Dan", "Joy", "Ben", "Evan"]
    end
    available_teachers.each do |teacher_name|
      RequiredMailer.ping_teacher_email(User.find_by(name: teacher_name, student: false),self).deliver_now 
    end
    true
  end
end
