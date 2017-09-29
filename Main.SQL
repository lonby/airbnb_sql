--AirBnB User Analysis on SQL Project
--Joe unsung


------------------------------
---------=I N D E X=----------
--0. Setting
--1. Conversion rate analysis
--2. Time difference Analysis


		--0. Setting

      --0.1 create table
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


	 --1.
        --Q1. which browser will be the most favorable?

        select first_browser, count(*) as cnt
           from air_user
          group by first_browser
          order by cnt desc;

          select signup_app, count(*) as cnt
            from air_user
            group by signup_app
            order by cnt desc;

          select signup_flow, count(*) as cnt
           from air_user
          group by signup_flow
          order by cnt desc;



       select *
            from air_user;


           --Data의 회원id는 중복되지 않은 회원id입니다.
            select count(distinct id), count(*)
              from air_user;


           --구매 전환율 (0.42%) conversion rate
            select country,  round( (cnt_book / (select count(*) from air_user)), 2) as book_ratio
             from
             (
                select country_destination as country, count(*) as cnt_book
                from air_user
                where date_first_booking is not null
                group by country_destination
             )
             order by book_ratio desc;

                   --채널별로 볼 수 있음

                --국가별로 볼 수 있음

                --

                select max(timestamp_first_active)
                   from air_user;

            --가입후 구매까지 걸리는 시간의 평균 ( 0.23일 )
              select round( avg(day_diff) , 3) as avg_book
            from
            (
             select (date_account_created - to_date(substr(timestamp_first_active, 1,8), 'YYYYMMDD')) as day_diff
                from air_user
            );
            group by time_diff;

            --방문부터 ~




            --AirBnB 유져들의 방문 후 가입까지 걸리는 날 분포
            select dd as Day, count(*) as Cnt
            from
            (
              select day_diff, case when day_diff <= 1 then 1
                          when day_diff > 1 and day_diff <= 3 then 3
                          when day_diff > 3 and day_diff <= 5 then 5
                          when day_diff > 5 and day_diff <= 7 then 7
                          else 10 end as dd
              from
              (
               select (date_account_created - to_date(substr(timestamp_first_active, 1,8), 'YYYYMMDD')) as day_diff
                from air_user

              )
            )
            group by dd
            order by dd;


            --방문 후 예약까지 걸리는 날짜 차이 분포
             select dd as Day, count(*) as Cnt
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


            --마이너스 값 제거해야함
            select count(*)
            from
            (
             select id, date_first_booking, date_account_created, (to_date(date_first_booking, 'YYYY-MM-DD') - date_account_created) as day_diff
                from air_user
                where date_first_booking is not null
            )
            where day_diff < 0
            ;


           --가입 후 구매까지의 시간
             select dd as Day, count(*) as Cnt
            from
            (
              select day_diff, case when day_diff <= 1 then 1
                          when day_diff > 1 and day_diff <= 3 then 3
                          when day_diff > 3 and day_diff <= 5 then 5
                          when day_diff > 5 and day_diff <= 7 then 7
                          else 10 end as dd
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

            select *
               from air_user;



          --구매한 유져는 어떤 사람들일까?

            --0. 가입 방식 (직접 가입을 선호)
            select signup_method , count(*) as cnt
              from air_user
              where date_first_booking is not null
              group by signup_method
              order by cnt desc;

            --1. 회원의 성별 (구매 유져 vs 전체 유져)

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

            --2. 회원의 나이 분포 (구매 유져 vs 전체 유져)

            select age, count(*)
               from air_user
              group by age
              order by age;



		select 여행목적지, 마케팅채널,
                      round( (cnt_book / (select count(*) from air_user))*100, 2)
                      as "book_ratio (%)"
               from
               (
                  select country_destination as 여행목적지, affiliate_channel as 마케팅채널, count(*) as cnt_book
                  from air_user
                  where date_first_booking is not null
                   -- and country_destination = 'AU'
                  group by country_destination, affiliate_channel
                                                                    )
                order by 1, 2 desc ;




