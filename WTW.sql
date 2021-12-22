/*

Instructions:
•  Use relational tables to track this information
    [dbo].[Campsite]
    [dbo].[Camper]
    [dbo].[Reservation]
•  Populate the tables with a small amount of dummy data
•  The data does not have to be accurate to Millcreek canyon real world specifications
•  Create stored procedure(s) to add or cancel a reservation
    [dbo].[SetReservation]
    [dbo].[CancelReservation]
•  Don’t worry about updating information on an existing reservation for this problem
•  Create a view to show available campsite reservation dates
    [dbo].[vCampsiteReservationDates]
      to see all actual reservations with campsite information
    [dbo].[vReservationDates]
      to see all actual dates with reservations
    [dbo].[vAvailableCampsiteReservationDates]
      to see those dates available, not consumed by a reservation, per CampsiteName
•  Create a function that shows the most popular day to visit the canyon
    [dbo].[GetMostPopularDay]
      Picks from all days reserved, sorts them and picks the most picked. Which may be a tie with other days, so picks earliest day in the week
      for this sample dataset, it was Thursday, though Friday and Saturday were equal usage. Made me want to tweek the data. But sample data is sample data.


they would also like to know the number of visitors to the canyon each day.
    this could only be tracked if we tracked visitors in the canyon, which seems outside the scope of reservations
    also, a reservation may include a number of people within the reservation, which I did not include, as research didnt have this value with the data collected.
    and keeping this dtaa accurate would be a guess, upon reservation taking time anyway. I do nto see an accurate count from this numbers as the number of campers could swell when the actual reservation is executed.
    however, for collecting how many reservations we have, one could perform this statement.
      Select count(*) from Reservation
    and this would be a starting point to collect quantity of reservations
    the following query would give a count for all the days reserved, again a single count of the existence of a reservation    
      select count(*) from [dbo].[vReservationDates]
*/




IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'u' AND name = 'Campsite')
  drop table [dbo].[Campsite]
go

create table [dbo].[Campsite]
(
  [CampsiteID] integer identity(1,1),
  [AreaName] varchar(50),
  [FacilityName] varchar(50),
  [CampsiteName] varchar(50),
  [Number] integer,
  [Length] decimal(8,2),
  [PullThru] bit,
  [ElectricAmps] int,
  [Water] bit,
  [Sewer] bit,
  [WeekdayRate] decimal(8,2),
  [WeekendRate] decimal(8,2),
  [Features] varchar(200)
)
go


IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'u' AND name = 'Camper')
  drop table [dbo].[Camper]
go

create table [dbo].[Camper]
(
  [CamperID] integer identity(1,1),
  [FirstName] varchar(200),
  [LastName] varchar(200),
  [Address] varchar(50),
  [City] varchar(20),
  [State] varchar(20),
  [Zip] varchar(9),
  [DriversLicense] varchar(20),
  [Email] varchar(200)
)
go

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'u' AND name = 'Reservation')
  drop table [dbo].[Reservation]
go

create table [dbo].[Reservation]
(
  [ReservationID] integer identity(1,1),
  [CampsiteID] integer,
  [CamperID] integer,
  [StartDate] datetime2,
  [EndDate] datetime2,
  [Nights] int,
  [Rate] decimal(8,2),
  [Deposit] decimal(8,2)
)
go



insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Church Fork Picnic Area', 'Fred Foyer')    
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Church Fork Picnic Area', 'John Neff')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'South Box Elder Picnic Area', 'Edmund Elsworth')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Terraces Picnic Area', 'Bowman Fork')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Terraces Picnic Area', 'Archibald Gardner')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Terraces Picnic Area', 'Charles Stillman')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Terraces Picnic Area', 'Chauncey Porter')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Upper Box Elder Picnic Area', 'Alva Alexander')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Upper Box Elder Picnic Area', 'Amy Smith')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', 'Upper Box Elder Picnic Area', 'Sara Skidmore')
insert into [dbo].[Campsite] ( AreaName, FacilityName, CampsiteName) values ( 'Mill Creek Canyon', '', 'Yurt')
go






--Create a date dimension table

-- =============================================
-- Author:              TJay Belt
-- Create date: 22 December 2021
-- Description:    date dim for 2021  --stolen from online
-- =============================================


IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'u' AND name = 'DateDim')
  drop table [dbo].[DateDim]
go

DECLARE @StartDate  date = '20210101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 1, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
)
SELECT * 
  into [DateDim]
  FROM src
  ORDER BY [TheDate]
  OPTION (MAXRECURSION 0);

--select * from DateDim
--go





--Create a function that shows the most popular day to visit the canyon

-- =============================================
-- Author:              TJay Belt
-- Create date: 20 December 2021
-- Description:    shows the most popular day to visit the canyon
-- =============================================

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'fn' AND name = 'GetMostPopularDay')
  drop FUNCTION [dbo].[GetMostPopularDay]
go


CREATE FUNCTION [dbo].[GetMostPopularDay]
(
)
RETURNS
  varchar(20)
AS
BEGIN
  DECLARE @PopularDay VARCHAR(20);

  with cteDays as 
  (
    --select 
    --    count(DATEPART(WEEKDAY, r.StartDate)) as [Count],
    --   DATEPART(WEEKDAY, r.StartDate) as [DatePart]
    --  from [Reservation] r
    --  group by DATEPART(WEEKDAY, r.StartDate)

    select 
        count(DATEPART(WEEKDAY, [TheDate])) as [Count],
        DATEPART(WEEKDAY, [TheDate]) as [DatePart]
      from [vReservationDates]
      group by DATEPART(WEEKDAY, [TheDate])
      --order by count(DATEPART(WEEKDAY, [TheDate])) desc
  )

  select top 1
    @PopularDay = case  
              When [DatePart] = 1 Then 'Sunday'      
              When [DatePart] = 2 Then 'Monday'       
              When [DatePart] = 3 Then 'Tuesday'       
              When [DatePart] = 4 Then 'Wednesday'      
              When [DatePart] = 5 Then 'Thursday'       
              When [DatePart] = 6 Then 'Friday'       
              When [DatePart] = 7 Then 'Saturday'
            End 
  from cteDays
  order by [Count] Desc
  
  RETURN @PopularDay
END
go




--select [dbo].[GetMostPopularDay]()







--Create stored procedure(s) to add or cancel a reservation

-- =============================================
-- Author:              TJay Belt
-- Create date: 20 December 2021
-- Description:    add a reservation
-- =============================================

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'p' AND name = 'SetReservation')
  drop Procedure [dbo].[SetReservation]
go  

CREATE Procedure [dbo].[SetReservation]
(
  @FirstName varchar(200),
  @LastName varchar(200),
  @Address varchar(50),
  @City varchar(20),
  @State varchar(20),
  @Zip varchar(9),
  @DriversLicense varchar(20) = null,
  @Email varchar(200) = null,

  @CampsiteName varchar(50) = null,
  @StartDate datetime2 = null,
  @EndDate datetime2 = null,
  @Deposit decimal(8,2)
  
)
AS
begin 

  declare @CampsiteID integer
  declare @CamperID integer
  declare @Rate decimal(8,2)

  if not exists ( 
    Select * 
      from [Camper] 
      where @FirstName = FirstName
        and @LastName = LastName
        and @Address = Address
        and @City = City
        and @State = State
        and @Zip = Zip
        and @DriversLicense = DriversLicense
        and @Email = Email
  )
    begin
    insert into [Camper] ( FirstName, LastName, Address, City, State, Zip, DriversLicense, Email )
    values
    ( 
      @FirstName,
      @LastName,
      @Address,
      @City,
      @State,
      @Zip,
      @DriversLicense,
      @Email
    )
  end

  Select @CamperID = CamperID
    from [Camper] 
    where @FirstName = FirstName
      and @LastName = LastName
      and @Address = Address
      and @City = City
      and @State = State
      and @Zip = Zip
      and @DriversLicense = DriversLicense
      and @Email = Email

  select 
      @CampsiteID = CampsiteID,
      @Rate = case
                when DATEPART(WEEKDAY, @StartDate) in ( 1,7) then WeekendRate
                when DATEPART(WEEKDAY, @StartDate) not in ( 1,7) then WeekdayRate
              end
    from [Campsite]
    where [CampsiteName] like '%' + @CampsiteName + '%'

  if @CampsiteID is not null
  begin
  
    insert into [Reservation] 
    ( 
      [CampsiteID], 
      [CamperID],
      [StartDate], 
      [EndDate], 
      [Nights], 
      [Rate], 
      [Deposit]
    ) 
    values 
    (
      @CampsiteID, 
      @CamperID,
      @StartDate, 
      @EndDate, 
      DateDiff( day, @StartDate, @EndDate), 
      @Rate, 
      @Deposit
    )
    
  end
  else
  begin
    RAISERROR ('Unable to create Reservation, Campsite not found', 16, 1);  
  end
end
go



-- =============================================
-- Author:              TJay Belt
-- Create date: 22 December 2021
-- Description:    cancel a reservation
-- =============================================

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'p' AND name = 'CancelReservation')
  drop Procedure [dbo].[CancelReservation]
go  

CREATE Procedure [dbo].[CancelReservation]
(
  @CampsiteName varchar(50) = null,
  @StartDate datetime2 = null,
  @EndDate datetime2 = null
)
AS
begin 

  declare @CampsiteID integer
  declare @ReservationID integer

  select 
    @CampsiteID = c.[CampsiteID],
      @ReservationID = [ReservationID]
    from [Reservation] r
      join [Campsite] c on c.CampsiteID = r.CampsiteID
        and [CampsiteName] like '%' + @CampsiteName + '%'
    where r.StartDate = @StartDate
      and r.EndDate = @EndDate

  if @CampsiteID is not null and @ReservationID is not null
  begin
  
    delete from [Reservation] 
      where [CampsiteID] = @CampsiteID
        and [ReservationID] = @ReservationID
    
  end
  else
  begin
    RAISERROR ('Unable to cancel Reservation, Campsite or Reservation not found', 16, 1);  
  end
end
go




/*


select 
    DATEPART(WEEKDAY, StartDate),
    * 
  from [vCampsiteReservationDates]
  where CampsiteName = 'Chauncey Porter'


begin transaction tjay

exec [dbo].[CancelReservation] 
  @CampsiteName = 'Chauncey Porter',
  @StartDate = '2021-03-11',
  @EndDate = '2021-03-14'

rollback transaction tjay
commit transaction tjay
*/





exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '12/22/2021', '12/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '11/22/2021', '11/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '10/22/2021', '10/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '9/22/2021', '9/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '8/22/2021', '8/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '7/22/2021', '7/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '6/22/2021', '6/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '5/22/2021', '5/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '4/22/2021', '4/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '3/22/2021', '3/30/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '2/22/2021', '2/28/2021', 0
go
exec [dbo].[SetReservation] 'TJay', 'Belt', '266', 'Pleasant Grove', 'UT', '84062', 'DL1000', 'tjaybelt@yahoo.com', 'Yurt', '1/22/2021', '1/30/2021', 0
go

exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Chauncey Porter', '12/11/2021', '12/12/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Fred Foyer', '11/11/2021', '11/13/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Archibald Gardner', '10/11/2021', '10/13/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Bowman Fork', '9/11/2021', '9/14/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Fred Foyer', '8/11/2021', '8/15/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Chauncey Porter', '7/11/2021', '7/11/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Yurt', '6/11/2021', '6/12/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Bowman Fork', '5/11/2021', '5/13/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Archibald Gardner', '4/11/2021', '4/13/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Chauncey Porter', '3/11/2021', '3/14/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Fred Foyer', '2/11/2021', '2/12/2021', 0
go
exec [dbo].[SetReservation] 'Kevin', 'Richins', '123', 'Spanish Fork', 'UT', '84062', 'DL2000', 'tjaybelt@yahoo.com', 'Archibald Gardner', '1/11/2021', '1/16/2021', 0
go



--Create a view to show available campsite reservation dates

-- =============================================
-- Author:              TJay Belt
-- Create date: 20 December 2021
-- Description:    show available campsite reservation dates
-- =============================================

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'v' AND name = 'vCampsiteReservationDates')
  drop VIEW [dbo].[vCampsiteReservationDates]
go

CREATE VIEW [dbo].[vCampsiteReservationDates]
AS

  select  
    r.[StartDate], r.[EndDate], r.[Nights], r.[Rate], r.[Deposit],
      cs.[AreaName], cs.[FacilityName], cs.[CampsiteName], cs.[Number], cs.[Length], cs.[PullThru], cs.[ElectricAmps], cs.[Water], cs.[Sewer], cs.[WeekdayRate], cs.[WeekendRate], cs.[Features],
      c.[FirstName], c.[LastName], c.[Address], c.[City], c.[State], c.[Zip], c.[DriversLicense], c.[Email]
    from [Campsite] cs 
      join [Reservation] r on r.[CampsiteID] = cs.[CampsiteID]
      join [Camper] c on c.[CamperID] = r.[CamperID]
--    where r.[StartDate] >= @StartDate
--               and r.[EndDate] <= @EndDate
go           






-- =============================================
-- Author:              TJay Belt
-- Create date: 20 December 2021
-- Description:    reserved Dates
-- =============================================

IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'v' AND name = 'vReservationDates')
  drop VIEW [dbo].[vReservationDates]
go

CREATE VIEW [dbo].[vReservationDates]
AS

  SELECT top 1000
      d.[TheDate], r.[ReservationID], cs.[CampsiteName], r.[StartDate], r.[EndDate], c.[FirstName], c.[LastName]
    FROM  [DateDim] d
      JOIN [Reservation] r ON d.[TheDate] BETWEEN r.[StartDate] and r.[EndDate]
      join [Campsite] cs on cs.[CampsiteID] = r.[CampsiteID]
      join [Camper] c on c.[CamperID] = r.[CamperID]
    order by d.[TheDate] desc
go

--select * from [vReservationDates]

--select * 
--  from [vReservationDates]
--  where TheDate between '8/1/2021' and '11/30/2021'





--Create a view to show available campsite reservation dates

-- =============================================
-- Author:              TJay Belt
-- Create date: 22 December 2021
-- Description:    show available campsite reservation dates
-- =============================================



IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'v' AND name = 'vAvailableCampsiteReservationDates')
  drop VIEW [dbo].[vAvailableCampsiteReservationDates]
go

CREATE VIEW [dbo].[vAvailableCampsiteReservationDates]
AS

  SELECT 
      d.[TheDate], 
      a.[CampsiteName]
    FROM  [DateDim] d
      outer apply
      (
        select * 
          from [Campsite] 
      ) a
      left outer join [vReservationDates] r on r.TheDate = d.TheDate and a.CampsiteName = r.CampsiteName
    where r.ReservationID is null
    --order by d.[TheDate] desc
go           



--select * from [dbo].[vAvailableCampsiteReservationDates]
--  where theDate between '12/1/2021' and '12/12/2021'





------------------------------------------------------------------------------------------------------------------------------------------------------------



--select  *from camper
--select  *from reservation
--delete from reservation




--select * from [vCampsiteReservationDates]

--select 
--    DATEPART(WEEKDAY, StartDate),
--    * 
--  from [vCampsiteReservationDates]


--select 
--    count(DATEPART(WEEKDAY, StartDate)) as [Count],
--    DATEPART(WEEKDAY, StartDate)
--  from [vReservationDates]
--  group by DATEPART(WEEKDAY, StartDate)
--  order by count(DATEPART(WEEKDAY, StartDate)) desc


