class Student:
    def __init__(self, email, names):
        self.email = email
        self.names = names
        self.courses_registered = []
        self.GPA = 0.0

    def calculate_GPA(self):
        if not self.courses_registered:
            return 0.0
        total_points = sum(course.grade_points for course in self.courses_registered)
        total_credits = sum(course.credits for course in self.courses_registered)
        self.GPA = total_points / total_credits if total_credits > 0 else 0.0
        return self.GPA

    def register_for_course(self, course, grade_points):
        course.grade_points = grade_points
        self.courses_registered.append(course)
class Course:
    def __init__(self, name, trimester, credits):
        self.name = name
        self.trimester = trimester
        self.credits = credits
        self.grade_points = 0.0  # To store the grade points for the course
class GradeBook:
    def __init__(self):
        self.student_list = []
        self.course_list = []

    def add_student(self, email, names):
        student = Student(email, names)
        self.student_list.append(student)

    def add_course(self, name, trimester, credits):
        course = Course(name, trimester, credits)
        self.course_list.append(course)

    def register_student_for_course(self, student_email, course_name, grade_points):
        student = next((s for s in self.student_list if s.email == student_email), None)
        course = next((c for c in self.course_list if c.name == course_name), None)
        if student and course:
            student.register_for_course(course, grade_points)

    def calculate_GPA(self):
        for student in self.student_list:
            student.calculate_GPA()

    def calculate_ranking(self):
        self.student_list.sort(key=lambda s: s.GPA, reverse=True)
        return [(student.names, student.GPA) for student in self.student_list]

    def search_by_grade(self, course_name, grade):
        students_with_grade = []
        for student in self.student_list:
            for course in student.courses_registered:
                if course.name == course_name and course.grade_points == grade:
                    students_with_grade.append(student)
        return students_with_grade

    def generate_transcript(self, student_email):
        student = next((s for s in self.student_list if s.email == student_email), None)
        if not student:
            return None
        transcript = f"Transcript for {student.names}:\n"
        transcript += f"GPA: {student.GPA}\n"
        transcript += "Courses:\n"
        for course in student.courses_registered:
            transcript += f"{course.name} (Trimester: {course.trimester}, Credits: {course.credits}, Grade Points: {course.grade_points})\n"
        return transcript
def main():
    gradebook = GradeBook()

    while True:
        print("Grade Book Application")
        print("1. Add Student")
        print("2. Add Course")
        print("3. Register Student for Course")
        print("4. Calculate Ranking")
        print("5. Search by Grade")
        print("6. Generate Transcript")
        print("7. Exit")

        choice = input("Choose an action: ")

        if choice == '1':
            email = input("Enter student email: ")
            names = input("Enter student names: ")
            gradebook.add_student(email, names)
        elif choice == '2':
            name = input("Enter course name: ")
            trimester = input("Enter course trimester: ")
            credits = int(input("Enter course credits: "))
            gradebook.add_course(name, trimester, credits)
        elif choice == '3':
            email = input("Enter student email: ")
            course_name = input("Enter course name: ")
            grade_points = float(input("Enter grade points: "))
            gradebook.register_student_for_course(email, course_name, grade_points)
        elif choice == '4':
            ranking = gradebook.calculate_ranking()
            print("Student Rankings:")
            for rank, (name, gpa) in enumerate(ranking, 1):
                print(f"{rank}. {name} - GPA: {gpa}")
        elif choice == '5':
            course_name = input("Enter course name: ")
            grade = float(input("Enter grade points: "))
            students = gradebook.search_by_grade(course_name, grade)
            print(f"Students with grade {grade} in {course_name}:")
            for student in students:
                print(f"{student.names} - Email: {student.email}")
        elif choice == '6':
            email = input("Enter student email: ")
            transcript = gradebook.generate_transcript(email)
            if transcript:
                print(transcript)
            else:
                print("Student not found.")
        elif choice == '7':
            print("Exiting the application. Goodbye!")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()
