class RequiredMailer < ApplicationMailer
  default from: ENV['gmail_username']

  def required_email(user)
    @user = user
    mail(to: user.email, subject: "Sign up for a tutoring session")
  end

  def meeting_email(student, teacher, meeting)
    @student = student
    @teacher = teacher
    @meeting = meeting
    mail(to: student.email, subject: "Tutoring with #{teacher.name}")
  end
end
