use kse;








-- calculate each student's average grade
with  student_avg as(
	select s.id, s.name, s.program_id, avg(e.grade) as student_avg 
    from students s 
    right join enrollments e on s.id=e.student_id 
    group by s.id )
 (   
 -- program statistics: average grade per program
select 
    p.name as program_name, 
    count(st_avg.id) as students_count, 
    AVG(st_avg.student_avg) as avg_program_grade,
    null as proffesor_name,
    null as failed_courses_count
from programs p 
left join student_avg as st_avg on p.id=st_avg.program_id 
group by p.code, p.name 
having count(st_avg.id)>1 
order by AVG(st_avg.student_avg)
)
UNION ALL
-- -- For each program and professor, count how many failed courses students had (ordered by highest fail count)
(
select p.name, null as students_count, null as avg_program_grade, pr.name, count(bad_st.id) as faild_course_count 
from courses c 
left join professors pr on c.professor_id=pr.id 
right join( 
	-- Select all failed enrollments (grade < 60) with their course and program ids
	select e.id, e.course_id, s.program_id 
	from enrollments e 
	left join students s on s.id=e.student_id 
	where e.grade<60 
) as bad_st on c.id=bad_st.course_id 
left join programs p on p.id=bad_st.program_id 
group by p.code, p.name, pr.name 
order by count(bad_st.id) desc 
)
limit 10;






-- how it looked before i tried to use union and combine these two queries... 
-- as you can see it is quite difficalt to union it but i tried....
with student_avg as( 
	select s.id, s.name, s.program_id, avg(e.grade) as student_avg 
	from students s 
	right join enrollments e on s.id=e.student_id 
	group by s.id ) 
select p.code, p.name, count(st_avg.id), AVG(st_avg.student_avg) 
from programs p 
left join student_avg as st_avg on p.id=st_avg.program_id 
group by p.code, p.name having count(st_avg.id)>1 
order by AVG(st_avg.student_avg) 
limit 1 ; 

select p.id, p.name, count(bad_st.id) as faild_course_count 
from professors p 
left join courses c on c.professor_id=p.id 
left join( 
	select e.id, e.course_id 
    from enrollments e 
    where e.grade<60 ) as bad_st on c.id=bad_st.course_id 
group by p.id, p.name 
order by count(bad_st.id) desc 
limit 1;



