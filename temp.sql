/*
1.3번 행, 열 합 추가
2.3.1번 시간 구간 나누기
2.3.1번 subquery 내용 csv 파일 export
*/


      --0. Setting
			  --0.1. create table
			  create table air_user
			  (id  varchar2(50),
			   date_account_created  date,
			   timestamp_first_active  number,
			   date_first_booking   varchar2(50),
			   gender  varchar2(50),
			   age    number(10),
			   signup_method  varchar2(50),
			   signup_flow  number(10),
			   language  varchar(10),
			   affiliate_channel  varchar2(50),
			   affiliate_provider   varchar2(50),
			   first_affiliate_tracked  varchar2(50),
			   signup_app  varchar2(50),
			   first_device_type  varchar2(50),
			   first_browser  varchar2(50),
			   country_destination varchar2(10));
			   
			   commit ;
		 
		 
			-- 0.2. 데이터 확인
			
			   -- Data의 회원id는 중복되지 않은 회원id입니다.
					select count(distinct id), count(*)  -- 213451, 213451
					  from air_user;
			
			   -- 이상치 확인: 마이너스 값 제거해야함 ("예약일 - 계정생성일" 은 항상 양수! 이어야 하나, 음수 값 존재)
					select count(*)
					from
					(
					 select id, date_first_booking, date_account_created, (to_date(date_first_booking, 'YYYY-MM-DD') - date_account_created) as day_diff
						from air_user
						where date_first_booking is not null
					)
					where day_diff < 0
					;
			
			
				-- 이상치 제거 필요!!!
 

 
 	--1. Conversion rate analysis
        	
				-- 1.1. conversion rate(0.42%) : conversion rate(전환률) 란 Airbnb를 이용한 과거의 경험이 없던 구매예정자가 첫 예약을 통해 실질구매자로 전환된 비율
				  select 여행목적지,  round( (국가별예약자수 / (select count(*) from air_user)), 2) as "국가별전환률" -- 국가별전환률 = conversion rate
				   from
				   (
					  select country_destination as "여행목적지", count(*) as "국가별예약자수" -- 여행목적지 : Airbnb 첫 이용 시 여행한 국가, 국가별예약자수 : Airbnb 첫 이용 시 국가별 여행자 수
						from air_user
						where date_first_booking is not null and gender not in ('OTHER')   -- and gender not in ('OTHER')  어떤 의미? --re : 성별을 알 수 없는 값이라 임의로 제거했었어요 의미가 있을 것 같다면 복원해둘까요?  
						group by country_destination
				   )
				   order by 국가별전환률 desc;


				 -- 1.2. conversion rate dependent on country and gender
				 select *
				 from
				 (
				   select a.여행목적지, a.gender, round( ( a.cnt_book / b.country_total ),2 ) as booking_ratio  --> booking_ratio : 첫 예약자의 여행목적지별 성별 전환율 (비율> 전환율로 수정)
				   from
				   (
					  select country_destination as "여행목적지", gender, count(*) as cnt_book   --> cnt_book : Airbnb 첫 예약자의 여행목적지별, 성별 예약자 수
						from air_user
						where date_first_booking is not null and gender not in ('OTHER')   
						group by country_destination, gender
				   ) a
				   inner join
				   (
					select country_destination as "여행목적지", count(country_destination) as country_total  --> country_total : Airbnb 첫 예약자의 여행목적지별 예약자 수
					  from air_user
					  group by country_destination
				   ) b
				   on a.여행목적지 = b.여행목적지     --> inner join 했을 때의 데이터 구조는? >> 합쳐진 테이블의 모습을 말씀하시는걸까요! 데이터의 구조란 말을 제가 명확히 모르겠어요.
				 )
				 pivot( sum(booking_ratio) for gender in ('MALE' as "남자",'FEMALE' as "여자",'-unknown-' as "알수없음"));


			  -- 1.3. booking rate by destination and marketing channel
			
			select 여행목적지, 마케팅채널,
					round( (cnt_book / (select count(*) from air_user))*100, 2) as "book_ratio (%)"     --> book_ratio : Airbnb 첫 예약자의 여행목적지별 마케팅채널별 예약률
					from
					(
					   select country_destination as 여행목적지, affiliate_channel as 마케팅채널, count(*) as cnt_book    --> cnt_book : Airbnb 첫 예약자의 여행목적지별 마캐팅채널별 예약자 수
					   from air_user
					   where date_first_booking is not null
					   -- and country_destination = 'AU'
					   group by country_destination, affiliate_channel
					 )
					 order by 1, 2 desc ;

   
	 



	--2. Time difference Analysis
    
				-- 2.1. Max Time
				   select max(timestamp_first_active)
					from air_user;


				-- 2.2. 첫 방문 후 가입까지 소요 평균 일 수 ( 0.232일 )  = 계정생성일 - 홈피첫방문일
				  select round( avg(day_diff) , 3) as avg_book
					from
					(
					 select (date_account_created - to_date(substr(timestamp_first_active, 1,8), 'YYYYMMDD')) as day_diff
						from air_user
					) ;
					--group by time_diff; 오타?


				 -- 2.2.1. AirBnB 유져들의 방문 후 가입까지 소요 일 수 분포
					select dd as signUpDayDiff, count(*) as Cnt -- signUpDayDiff : 첫 방문 후 가입까지 소요 일 수, Cnt : 가입자 수
					from
					(
					  select day_diff, case when day_diff <= 1 then 0   -- 가입까지 하루도 안 걸리는 사람
								  when day_diff > 1 and day_diff <= 3 then 1    -- 가입까지 1~3일 걸리는 사람
								  when day_diff > 3 and day_diff <= 5 then 3    -- 가입까지 3~5일 걸리는 사람
								  when day_diff > 5 and day_diff <= 7 then 5    -- 가입까지 5~7일 걸리는 사람
								  else 7 end as dd      -- 가입까지 7일 이상 걸리는 사람
					  from
					  (
					   select (date_account_created - to_date(substr(timestamp_first_active, 1,8), 'YYYYMMDD')) as day_diff   --첫 방문 후 가입까지의 소요 일 수
						from air_user

					  )
					)
					group by dd
					order by dd;


				 -- 2.3. 방문 후 예약까지 소요되는 평균 일 수
					
				 -- 2.3.1. 방문 후 예약까지 걸리는 날짜 차이 분포
					 select dd as bookingDayDiff, count(*) as Cnt
					from
					(
					  select day_diff, case when day_diff <= 1 then 1
								  when day_diff > 1 and day_diff <= 3 then 3
								  when day_diff > 3 and day_diff <= 5 then 5
								  when day_diff > 5 and day_diff <= 7 then 7
								  else 10 end as dd
					  from
					  (
					   select (to_date(date_first_booking, 'YYYY-MM-DD') - date_account_created) as day_diff
						from air_user
						where date_first_booking is not null
					  )
					  where day_diff >= 0
					)
					group by dd
					order by dd;



				   -- 2.4. 가입 후 구매까지의 평균 소요 일 수


				   -- 2.4.1. 가입 후 구매까지의 소요 일 수 분포
					 select dd as Day, count(*) as Cnt
					from
					(
					  select day_diff, case when day_diff <= 1 then 0
								  when day_diff > 1 and day_diff <= 3 then 1
								  when day_diff > 3 and day_diff <= 5 then 3
								  when day_diff > 5 and day_diff <= 7 then 5
								  else 7 end as dd
					  from
					  (
					   select (to_date(date_first_booking, 'YYYY-MM-DD') - to_date(substr(timestamp_first_active, 1,8), 'YYYYMMDD')) as day_diff
						from air_user
						where date_first_booking is not null
					  )
					  where day_diff >= 0
					)
					group by dd
					order by dd;
	    


     -- 3. EDA

					-- 3.1. 가입 방식 (직접 가입을 선호)
					select signup_method , count(*) as cnt
					  from air_user
					  where date_first_booking is not null
					  group by signup_method
					  order by cnt desc;

					-- 3.2. 회원의 성별 (구매 유져 vs 전체 유져)

					select gender, count(*) as cnt
					   from air_user
					  where  gender not in '-unknown-'
					  group by gender
					  order by cnt desc;

					select gender, count(*) as cnt
					   from air_user
					  where date_first_booking is not null and gender not in '-unknown-'
					  group by gender
					  order by cnt desc;

					-- 3.3. 회원의 나이 분포 (구매 유져 vs 전체 유져)

					select age, count(*)
					   from air_user
					  group by age
					  order by age;
       
 
 
 
 
 
