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


	 --1. Conversion rate analysis
   		--Q1. which browser will be the most favorable?


         -- conversion rate(0.42%)
          select country,  round( (cnt_book / (select count(*) from air_user)), 2) as book_ratio
           from
           (
              select country_destination as country, count(*) as cnt_book
              from air_user
              where date_first_booking is not null and gender not in ('OTHER')
              group by country_destination
           )
           order by book_ratio desc;


         -- conversion rate dependent on country and gender
         select *
         from
         (
           select a.country, a.gender, round( ( a.cnt_book / b.country_total ),2 ) as booking_ratio
           from
           (
              select country_destination as country, gender, count(*) as cnt_book
                from air_user
                where date_first_booking is not null and gender not in ('OTHER')
                group by country_destination, gender
           ) a
           inner join
           (
            select country_destination as country, count(country_destination) as country_total
              from air_user
              group by country_destination
           ) b
           on a.country = b. country
         )
         pivot( sum(booking_ratio) for gender in ('MALE','FEMALE','-unknown-'));


      	--GENDER 별로 해서 UNION ALL

        select country,  round( (cnt_book / (select count(*) from air_user)), 2) as book_ratio
           from
           (
              select country_destination as country, count(*) as cnt_book
              from air_user
              where date_first_booking is not null and gender not in ('OTHER')
              group by country_destination
           )
           order by book_ratio desc;





           select count(*) from air_user;

           select 여행목적지, 마케팅채널,
                      round( (cnt_book / (select count(*) from bnb_train_users))*100, 2)
                      as "book_ratio (%)"
               from
               (
                  select country_destination as 여행목적지, affiliate_channel as 마케팅채널, count(*) as cnt_book
                  from bnb_train_users
                  where date_first_booking is not null
                    and country_destination = 'AU'
                  group by country_destination, affiliate_channel
                                                                    )
                order by 1, 2 desc ;

         SELECT kname, emoticon, P_TOTAL
  FROM(SELECT NVL(TO_CHAR(kname),'E_TOTAL') AS kname,
            COUNT(DECODE(emoticon,'(깜짝)', kname)) AS "(깜짝)",
              COUNT(DECODE(emoticon,'(까아)', kname)) AS "(꺄아)",
              COUNT(DECODE(emoticon,'(부끄)', kname)) AS "(부끄)",
              COUNT(DECODE(emoticon,'(뿌듯)', kname)) AS "(뿌듯)",
              COUNT(DECODE(emoticon,'(수정)', kname)) AS "(수정)",
              COUNT(DECODE(emoticon,'(수줍)', kname)) AS "(수줍)",
              COUNT(DECODE(emoticon,'(신나)', kname)) AS "(신나)",
              COUNT(DECODE(emoticon,'(심각)', kname)) AS "(심각)",
              COUNT(DECODE(emoticon,'(쑥스)', kname)) AS "(쑥스)",
              COUNT(DECODE(emoticon,'(씨익)', kname)) AS "(씨익)",
              COUNT(DECODE(emoticon,'(아잉)', kname)) AS "(아잉)",
              COUNT(DECODE(emoticon,'(야호)', kname)) AS "(야호)",
              COUNT(DECODE(emoticon,'(우와)', kname)) AS "(우와)",
              COUNT(DECODE(emoticon,'(짜증)', kname)) AS "(짜증)",
              COUNT(DECODE(emoticon,'(찡긋)', kname)) AS "(찡긋)",
              COUNT(DECODE(emoticon,'(크크)', kname)) AS "(크크)",
              COUNT(DECODE(emoticon,'(하하)', kname)) AS "(하하)",
              COUNT(DECODE(emoticon,'(허걱)', kname)) AS "(허걱)",
              COUNT(DECODE(emoticon,'(훌쩍)', kname)) AS "(훌쩍)",
              COUNT(DECODE(emoticon,'(흑흑)', kname)) AS "(흑흑)",
              COUNT(DECODE(emoticon,'(힘듦)', kname)) AS "(힘듦)",
              COUNT(emoticon) AS P_TOTAL
         FROM(SELECT kname, regexp_substr(ktalk, '\((..)\)',1,1) AS emoticon
                FROM kakao)
        GROUP BY ROLLUP(kname))
UNPIVOT(P_TOTAL FOR emoticon IN ("(깜짝)", "(꺄아)", "(부끄)", "(뿌듯)", "(수정)", "(수줍)", "(신나)", "(심각)", "(쑥스)", "(씨익)", "(아잉)", "(야호)", "(우와)", "(짜증)", "(찡긋)", "(크크)", "(하하)", "(허걱)", "(훌쩍)", "(흑흑)", "(힘듦)" ,P_TOTAL))
 WHERE kname != 'E_TOTAL'
   AND P_TOTAL != 0
    OR kname != 'E_TOTAL'
    OR emoticon != 'P_TOTAL'
 ORDER BY 3 DESC, 1;





          select country_destination as country, gender, count(*) as cnt_book
              from air_user
              where date_first_booking is not null
              group by country_destination, gender
              order by 1,2;



         select country, round( ( cnt_book / (select count(*) from air_user) ),2 ) as booking_ratio
         from
         (
            select country_destination as country, gender, count(*) as cnt_book
              from air_user
              where date_first_booking is not null
              group by country_destination, gender
         );


          select a.country, a.gender, round( ( a.cnt_book / b.country_total ),2 ) as booking_ratio
         from
         (
            select country_destination as country, gender, count(*) as cnt_book
              from air_user
              where date_first_booking is not null and gender not in ('OTHER', '-unknown-')
              group by country_destination, gender
         ) a
         inner join
         (
           select country_destination as country, count(country_destination) as country_total
            from air_user
            group by country_destination
         ) b
         on a.country = b. country ;



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




