use kse;

INSERT INTO programs (name, code, ad_id) VALUES
('Artifiacial Inteligence', 'AI', 1),
('Software Engineering',  'SE', 2),
('Applied Maths', 'AM', 3),
('Economics nd Big Data', 'BE', 4),
('Psycology', 'PS', 5) ;


INSERT INTO professors( name, email ) values
	('Oleksandra', 'okonopatska@kse.org.ua'),
    ('Artem', 'akorotenko@kse.org.ua'),
    ('Eugenia', 'ekochubinska@kse.org.ua'),
    ('Halyna', 'hmakhova@kse.org.ua'),
    ('Valeriia', 'vpalii@kse.org.ua'),
	('Angelina', 'ashynkarenko@kse.org.ua'),
    ('Ihor', 'imiroshnychenko@kse.org.ua'),
    ('Olha', 'oskrypak@kse.org.ua'),
    ('Tetiana Proshchenko', 'tproshchenko@kse.org.ua');

TRUNCATE TABLE students;
INSERT INTO students (name, email, end_year, program_id) VALUES
	('Alice', 'alice@kse.org.ua', 28, 1),
	('Bob',  'bob@kse.org.ua', 28, 4),
    ('Anna', 'anna.org.ua', 28, 1),
    ('Maria', 'maria@kse.org.ua', 28, 2),
    ('Oleg', 'oleg@kse.org.ua', 27, 2),
    ('Lesya', 'lesya@kse.org.ua', 27, 4),
    ('Alona', 'alona@kse.org.ua', 28, 1),
    ('Oksana', 'oksana@kse.org.ua', 26, 3),
    ('Kateryna', 'kateryna@kse.org.ua', 26, 5);
   
   
INSERT INTO courses(code, name,term, professor_id) values
	('CS310','Databases',1, 6),
    ('STAT150', 'R for Data Science',1, 7),
    ('ENG121', 'English',2, 8),
    ('MATH252', 'Applied Linear Algebra',1, 9),
    ('MATH211', 'Essential Multivariate Calculus',3, 9),
    ('MATH111', 'Introduction to Calculus',2, 9);
    
TRUNCATE TABLE enrollments;

INSERT INTO enrollments (student_id, course_id, grade) VALUES
	(1, 1, 98),
	(1,  2, 100),
    (1, 3, 100),
    (1, 4, 92),
    (1, 5, 100),
    (1,6,97),
    (2, 1, 100),
	(2,  2, 80),
    (2, 3, 69),
    (2, 4, 32),
    (2, 5, 78),
    (2,6,97),
    (3, 1, 34),
	(3,  2, 100),
    (3, 3, 81),
    (3, 4, 91),
    (3, 5, 98),
    (3,6,76),
    (4, 1, 34),
	(4,  2, 87),
    (4, 3, 80),
    (4, 4, 76),
    (4, 5, 60),
    (4,6,56),
    (5, 1, 100),
	(5,  2, 90),
    (5, 3, 70),
    (5, 4, 92),
    (5, 5, 98),
    (5,6,99),
    (6, 1, 45),
	(6,  2, 67),
    (6, 3, 87),
    (6, 4, 98),
    (6, 5, 76),
    (6,6,97),
    (7, 1, 70),
	(7,  2, 60),
    (7, 3, 80),
    (7, 4, 42),
    (7, 5, 68),
    (7,6,69),
    (8, 1, 87),
	(8,  2, 50),
    (8, 3, 78),
    (8, 4, 76),
    (8, 5, 67),
    (8,6,98),
    (5, 1, 100),
	(5,  2, 70),
    (5, 3, 50),
    (5, 4, 72),
    (5, 5, 68),
    (5,6,59);
    


