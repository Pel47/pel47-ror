# Sample data for class demos. Load it with:
#   docker compose run --rm web bin/rails db:seed
#
# find_or_create_by! only creates a record if it isn't there yet, so running
# this file twice does NOT duplicate anything (the file is "idempotent").

# --- Departments -------------------------------------------------------------
cpe = Department.find_or_create_by!(name: "Computer Engineering") do |d|
  d.location = "Engineering Building, 3rd Floor"
end
ece = Department.find_or_create_by!(name: "Electronics Engineering") do |d|
  d.location = "Engineering Building, 2nd Floor"
end

# --- Teachers (4 per department) ---------------------------------------------
teachers = {
  "Maria Santos"      => [ "Web Development",       cpe ],
  "Jose Reyes"        => [ "Database Systems",      cpe ],
  "Angela Cruz"       => [ "Computer Networks",     cpe ],
  "Mark Bautista"     => [ "Software Engineering",  cpe ],
  "Patricia Garcia"   => [ "Digital Electronics",   ece ],
  "John Mendoza"      => [ "Embedded Systems",      ece ],
  "Kristine Ramos"    => [ "Signals and Systems",   ece ],
  "Daniel Villanueva" => [ "Circuit Analysis",      ece ]
}.to_h do |name, (specialization, department)|
  teacher = Teacher.find_or_create_by!(name: name) do |t|
    t.specialization = specialization
    t.email = "#{name.parameterize}@example.com"
    t.department = department
  end
  [ name, teacher ]
end

# --- Subjects (2 per department, taught by that department's teachers) -------
subjects = [
  Subject.find_or_create_by!(name: "Web Development 1")      { |s| s.teacher = teachers["Maria Santos"] },
  Subject.find_or_create_by!(name: "Database Management 1")  { |s| s.teacher = teachers["Jose Reyes"] },
  Subject.find_or_create_by!(name: "Digital Logic Design")   { |s| s.teacher = teachers["Patricia Garcia"] },
  Subject.find_or_create_by!(name: "Microcontrollers")       { |s| s.teacher = teachers["John Mendoza"] }
]

# --- Sections ----------------------------------------------------------------
# A section belongs to ONE subject, so each block (GO11, GO21) needs one
# section per subject: 4 subjects x 2 blocks = 8 sections.
# GOxy: x = year level, y = section number (GO11 = 1st year, section 1).
blocks = {
  "GO11" => [ "Mon/Wed 8:00-9:30 AM", "Room 101" ],
  "GO21" => [ "Tue/Thu 1:00-2:30 PM", "Room 201" ]
}

sections = blocks.to_h do |block, (timeslot, room)|
  block_sections = subjects.map do |subject|
    Section.find_or_create_by!(name: block, subject: subject) do |s|
      s.timeslot = timeslot
      s.room = room
    end
  end
  [ block, block_sections ]
end

# --- Students (20 first years in GO11, 20 second years in GO21) --------------
first_years = [
  "Juan Dela Cruz", "Maria Clara Reyes", "Paolo Santos", "Andrea Mae Garcia", "Joshua Ramos",
  "Nicole Bautista", "Carlo Mendoza", "Bea Villanueva", "Miguel Torres", "Kimberly Aquino",
  "Rafael Navarro", "Hannah Castillo", "Gabriel Flores", "Trisha Domingo", "Christian Lopez",
  "Janelle Rivera", "Adrian Pascual", "Samantha Gonzales", "Kevin Salazar", "Erika Manalo"
]
second_years = [
  "Mark Anthony Cruz", "Princess Dizon", "John Paul Morales", "Angelica Ferrer", "Jerome Valdez",
  "Kathleen Soriano", "Ryan Mercado", "Denise Javier", "Aaron Galang", "Michelle Tan",
  "Bryan Sison", "Clarisse Ocampo", "Nathaniel Robles", "Jasmine Del Rosario", "Patrick Lim",
  "Sofia Agustin", "Emmanuel De Guzman", "Rachel Medina", "Vincent Yap", "Lorraine Cabrera"
]

{ "GO11" => [ 1, first_years ], "GO21" => [ 2, second_years ] }.each do |block, (year, names)|
  names.each_with_index do |name, i|
    student = Student.find_or_create_by!(name: name) do |s|
      s.year_level = year
      s.program = "BS Computer Engineering"
      s.department = i.even? ? cpe : ece # alternate departments
    end

    # --- Class lists: enroll the student in every section of their block -----
    # Creating a Classlist fires its callbacks, which update the student's
    # subjects_count, number_of_units and tuition_fee, and the section's
    # student_count.
    sections[block].each do |section|
      Classlist.find_or_create_by!(student: student, section: section)
    end
  end
end

puts "Seeded: #{Department.count} departments, #{Teacher.count} teachers, " \
     "#{Subject.count} subjects, #{Section.count} sections, " \
     "#{Student.count} students, #{Classlist.count} class lists"
