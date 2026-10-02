class HomeController < ApplicationController
  def index
    @student_count = Student.count
    @teacher_count = Teacher.count
    @department_count = Department.count
    @subject_count = Subject.count
    @section_count = Section.count
    @classlist_count = Classlist.count

    # includes(:department) loads every teacher's department in ONE extra
    # query, instead of one query per card (the "N+1" problem).
    @teachers = Teacher.includes(:department).order(:name).limit(3)
  end
end
