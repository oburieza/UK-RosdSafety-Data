# To discover the Total Casualties by severity

select sum(Number_of_Casualties ) as totalcasualties, sum(Did_Police_Officer_Attend_Scene_of_Accident ) as policeattendance, sum(Number_of_Vehicles) as totalvehicles
from ukroadsafety.accidents_2015 a 
where Accident_Severity = 3 or Accident_Severity = 2 or Accident_Severity = 1


# Accidents due to extreme Weather conditions

select sum(Number_of_Casualties) as totalcasualties,  sum(Number_of_Vehicles) as totalvehicles
from ukroadsafety.accidents_2015 a 
where Weather_Conditions = 4 and Accident_Severity = 3 or Accident_Severity = 2 or Accident_Severity = 1



# Accidents due to excess speed

select Speed_limit , sum(Number_of_Casualties) as totalcasualties ,
	case when Speed_limit = 50 then 'extreme'
		 when Speed_limit = 40 then 'medium'
		 when Speed_limit = 30 then 'slow medium'
		 when Speed_limit = 20 then 'slow'
		 else 'extremely slow' end as speedcategories
from ukroadsafety.accidents_2015 a 
group by 1
order by 1 desc 


# Accidents by Road Conditions

select byrd.ttlcasualty, byrd.Road_Type, byrd.Road_Surface_Conditions
from
(select sum(Number_of_Casualties) ttlcasualty , Road_Type , Road_Surface_Conditions 
from ukroadsafety.accidents_2015 a 
group by 2, 3) as byrd


# Accident Casualty based on Age and Sex of the drivers

select a.Number_of_Casualties as casualty , a.Accident_Severity as severrity ,v.Age_of_Driver as driverage , v.Sex_of_Driver as driversex 
from ukroadsafety.vehicles v 
join ukroadsafety.accidents_2015 a 
on v.Accident_Index = a.Accident_Index 
where Number_of_Casualties is not null 
order by 1 desc


# Accident Casualty based on Age of Vehicle

with vehicle_casualty as  (select a.Number_of_Casualties ttlcaslty, v.Age_of_Driver driverage
	  					   from ukroadsafety.vehicles v 
	  					   join ukroadsafety.accidents_2015 a 
	  					   on v.Accident_Index = a.Accident_Index
	  					   order by 1 desc)
				select max(vehicle_casualty.ttlcaslty) as maxcas
				from vehicle_casualty
				where vehicle_casualty.driverage > 30 and vehicle_casualty.driverage < 90
				
				
				
# Casualties based on Day, Week and Month				
				
select right(a.`Date`,4 ) as yr, substring(a.`Date`,4,2) as mnth, substring(a.`Date`,1,2) as dy,
sum(a.Number_of_Casualties) as ttlcaslty 
from ukroadsafety.accidents_2015 a 
group by 3, 2, 1
order by 4 desc;

# Average Age and Casualties by Severity

select avg(t1.ttlcaslty) over (partition by t1.svrty) as avgtt,
	   avg(t1.drvrage) over (partition by t1.svrty) as avgage	
from
	(select a.Number_of_Casualties as ttlcaslty, v.Age_of_Driver as drvrage, a.Accident_Severity as svrty
	from ukroadsafety.accidents_2015 a 
	join ukroadsafety.vehicles v 
	on a.Accident_Index = v.Accident_Index) as t1

# Ranking by Severity
	
	select 
		Accident_Severity ,
		Speed_limit ,
		row_number () over (partition by Accident_Severity order by Speed_limit desc) as rowsev;
		from ukroadsafety.accidents_2015 a 
		
		
# dense_rank
	  select Accident_Severity,
	  		 Speed_limit ,
			dense_rank () over (partition by Accident_Severity order by Speed_limit) as densernk
			from ukroadsafety.accidents_2015 a;
			
select 
	Accident_Severity ,
	Speed_limit ,
	rank () over (partition by Accident_Severity order by Speed_limit) as rnk
	from ukroadsafety.accidents_2015 a ;
	
# Grouping Accident severity in quarters by Speed limit

select Accident_Severity ,
		Speed_limit, 
		ntile(4) over (partition by Accident_Severity order by Speed_limit) as quatile
		from ukroadsafety.accidents_2015 a 