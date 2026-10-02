# Sample data for class demos. Load it with:
#   docker compose run --rm web bin/rails db:seed
#
# find_or_create_by! only creates a record if it isn't there yet, so running
# this file twice does NOT duplicate anything (the file is "idempotent").

# --- Departments -------------------------------------------------------------
dpwh = Department.find_or_create_by!(name: "Department of Public Works and Highways") do |d|
  d.location = "Bonifacio Drive, Port Area, Manila"
end
doe = Department.find_or_create_by!(name: "Department of Energy") do |d|
  d.location = "Energy Center, Rizal Drive, BGC, Taguig"
end

# --- Teachers (4 per department) ---------------------------------------------
teachers = {
  "Robert Downey Jr."  => [ "Iron Man",        dpwh ],
  "Chris Evans"        => [ "Captain America", dpwh ],
  "Mark Ruffalo"       => [ "Hulk",            dpwh ],
  "Jeremy Renner"      => [ "Hawkeye",         dpwh ],
  "Chris Hemsworth"    => [ "Thor",            doe ],
  "Scarlett Johansson" => [ "Black Widow",     doe ],
  "Samuel L. Jackson"  => [ "Nick Fury",       doe ],
  "Tom Holland"        => [ "Spider-Man",      doe ]
}.to_h do |name, (hero, department)|
  teacher = Teacher.find_or_create_by!(name: name) do |t|
    t.specialization = hero
    t.email = "#{name.parameterize}@example.com"
    t.department = department
  end
  [ name, teacher ]
end

# --- Subjects (2 per department, taught by that department's teachers) -------
subjects = [
  Subject.find_or_create_by!(name: "FloodControl101") { |s| s.teacher = teachers["Robert Downey Jr."] },
  Subject.find_or_create_by!(name: "Graft101")        { |s| s.teacher = teachers["Mark Ruffalo"] },
  Subject.find_or_create_by!(name: "Bisaya101")       { |s| s.teacher = teachers["Chris Hemsworth"] },
  Subject.find_or_create_by!(name: "Peñafrancia101")  { |s| s.teacher = teachers["Tom Holland"] }
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
  "Sara Duterte", "Robin Padilla", "Vico Sotto", "Leni Robredo", "Raffy Tulfo",
  "Imee Marcos", "Risa Hontiveros", "Bam Aquino", "Kiko Pangilinan", "Isko Moreno",
  "Manny Pacquiao", "Carlos Yulo", "Hidilyn Diaz", "EJ Obiena", "Alex Eala",
  "Kai Sotto", "Nesthy Petecio", "Aira Villegas", "Bong Go", "Bato dela Rosa"
]
second_years = [
  "Kathryn Bernardo", "Daniel Padilla", "Vice Ganda", "Alden Richards", "Marian Rivera",
  "Dingdong Dantes", "Anne Curtis", "Coco Martin", "Sarah Geronimo", "Catriona Gray",
  "Pia Wurtzbach", "Heart Evangelista", "Kim Chiu", "Paulo Avelino", "Maine Mendoza",
  "Michelle Dee", "Nadine Lustre", "Joshua Garcia", "Julia Barretto", "Bea Alonzo"
]

{ "GO11" => [ 1, first_years ], "GO21" => [ 2, second_years ] }.each do |block, (year, names)|
  names.each_with_index do |name, i|
    student = Student.find_or_create_by!(name: name) do |s|
      s.year_level = year
      s.program = "BS Computer Engineering"
      s.department = i.even? ? dpwh : doe # alternate departments
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
