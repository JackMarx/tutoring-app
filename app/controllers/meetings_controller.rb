class MeetingsController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_teacher!, only: [:edit, :update, :add_teacher]


  def index
    @meetings_suggested = Meeting.suggested_grouped
    @meetings_scheduled = Meeting.scheduled_grouped
    @available_dates = Meeting.available_dates
    @available_times = Meeting.available_time_slots
    @students = User.where(student: true).sort_by {|s| s.name}
    @time_now = Time.now
  end

  def create
    meeting = Meeting.new(
                      student_id: current_user.id,
                      date: date_of_next(params[:date]),
                      time_slot: params[:time_slot]
                      )
    if meeting.save
      meeting.email_available_teachers
      flash["success"] = "Time slot request submitted for review"
      redirect_to "/"
    else
      @meetings_suggested = Meeting.suggested_grouped
      @meetings_scheduled = Meeting.scheduled_grouped
      @available_dates = Meeting.available_dates
      @available_times = Meeting.available_time_slots
      @errors = meeting.errors.full_messages
      @students = User.where(student: true).sort_by {|s| s.name}
      @time_now = Time.now
      render "index.html.erb"
    end
  end

  def edit
    @meeting = Meeting.find(params[:id])
    @available_dates = Meeting.available_dates
    @available_times = Meeting.available_time_slots
    @teachers = User.where(student: false)
    @students = User.where(student: true)
  end

  def update
    meeting = Meeting.find(params[:id])
    meeting.update(
                   student_id: params[:student_id],
                   date: date_of_next(params[:date]),
                   time_slot: params[:time_slot],
                   teacher_id: params[:teacher_id],
                   suggested: (params[:teacher_id] == "")
                   )
    redirect_to "/"
  end

  def add_teacher
    meeting = Meeting.find(params[:id])
    meeting.update(
                   teacher_id: params[:teacher_id],
                   suggested: false
                   )
    student = meeting.student
    teacher = meeting.teacher
    student.update(required: false)
    RequiredMailer.meeting_email(student, teacher, meeting).deliver_now
    redirect_to "/"
  end

  def required
    @students = User.where(student: true)
    @students.each do |student|
      if !student.required && params[student.name]
        RequiredMailer.required_email(student).deliver_now
      end
      student.update(required: params[student.name])
    end
    redirect_to "/"
  end
end
