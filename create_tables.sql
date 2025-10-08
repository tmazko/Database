drop database if exists kse;
create database kse;
use kse;

create table programs(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(40) NOT NULL,
    ad_id int not null,
    code varchar(4) not null
);

create table professors(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(40) NOT NULL,
	email VARCHAR(50) not null
  );
  
  create table students(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(40) NOT NULL,
	email VARCHAR(50) not null,
    end_year int not null, 
    program_id int not null
  );
  
  create table courses(
	id INT PRIMARY KEY AUTO_INCREMENT,
	code VARCHAR(10) NOT NULL,
	name VARCHAR(50) NOT NULL,
	term int not null, 
	professor_id int not null
  );
  
create table enrollments(
	id INT PRIMARY KEY AUTO_INCREMENT,
    student_id int not null,
    course_id INT not null,
    grade NUMERIC(5,2) CHECK (grade >= 0.00 AND grade <= 100.00)
);