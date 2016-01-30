CREATE TABLE Positions(
IdPos INT IDENTITY PRIMARY KEY ,
NameP nVARCHAR(30),
);
CREATE TABLE Department(
IdDep INT IDENTITY PRIMARY KEY ,
NameDep nVARCHAR(30),
Phone VARCHAR(13),
CONSTRAINT NumbChech CHECK(LEN(Phone)=13 AND Phone LIKE '+380[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Staff(
IdStaff INT IDENTITY PRIMARY KEY ,
Name nVARCHAR(30),
SName nVARCHAR(30),
Department INT,
Position INT,
Phone VARCHAR(13),
Salary INT,
CONSTRAINT ForDep FOREIGN KEY (Department) REFERENCES Department(IdDep),
CONSTRAINT ForPos FOREIGN KEY (Position) REFERENCES Positions(IdPos),
CONSTRAINT NumbChech CHECK(LEN(Phone)=13 AND Phone LIKE '+380[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE VIEW StaffDepPos
AS
SELECT Name [Ім'я], SName 'Фамілія', NameDep 'Департамент',NameP 'Посада'
FROM Staff, Department, Positions
WHERE Staff.Position=Positions.IdPos
AND Staff.Department = Department.IdDep

SELECT * FROM StaffDepPos
------------------------------------------------------------------------
CREATE PROC StaffDep
      @NDep VARCHAR (20)
AS
SELECT Name, SName
FROM Staff, Department
WHERE Staff.Department=Department.IdDep
AND Department.NameDep = @NDep

EXEC StaffDep 'СільХоз'
-------------------------------------------------------------------------
CREATE PROC DepPhone
      @ChkPhone VARCHAR (13) 	  
AS
SELECT @ChkPhone = RTRIM(@ChkPhone) + '%';
	SELECT NameDep
	FROM Department
	WHERE Department.Phone LIKE @ChkPhone

EXEC DepPhone '+38067'
--------------------------------------------------------------------------
CREATE PROC DepNumStaff
      @NDep VARCHAR (20)
AS
SELECT COUNT(IdStaff) 'К-ть співробітників'
FROM Staff, Department
WHERE Staff.Department=Department.IdDep
AND NameDep = @NDep

EXEC DepNumStaff 'СільХоз'
--------------------------------------------------------------------------
CREATE VIEW Fonds
AS
SELECT NameDep 'Департамент', SUM(Salary) 'Фонд'
FROM Staff, Department
WHERE Staff.Department = Department.IdDep
GROUP BY NameDep

SELECT * FROM Fonds
----------------------------------------------------------------------------

CREATE TRIGGER  DelStaff
ON Staff
INSTEAD OF DELETE
AS
UPDATE Staff
SET Staff.Salary = NULL,
Staff.Position = NULL,
Staff.Phone = NULL,
Staff.Department = NULL
WHERE Staff.IdStaff IN (SELECT IdStaff FROM deleted)

DELETE FROM Staff
WHERE IdStaff = 3
--------------------------------------------------------------
CREATE PROC GoDep
      @SDep VARCHAR (20),  @FDep VARCHAR (20)
AS
DECLARE @StDep INT = (SELECT IdDep FROM Department WHERE NameDep = @SDep)
DECLARE @FnDep INT = (SELECT IdDep FROM Department WHERE NameDep = @FDep)
UPDATE Staff
SET Staff.Department = @FnDep
WHERE Staff.Department = @StDep

EXEC GoDep 'СільХоз', 'Природи'
---------------------------------------------------------------
CREATE PROC InfoStaff
      @Name VARCHAR (20),  @SName VARCHAR (20)
AS
SELECT Department.Phone,Salary,NameDep, Staff.Phone,NameP
FROM Staff, Department, Positions
WHERE Department = IdDep
AND Position=IdPos
AND Name = @Name
AND SName = @SName

EXEC InfoStaff 'Володимир','Саксаганський'
----------------------------------------------------------------
CREATE PROC GetPhone
      @IdStaff INT
AS
SELECT Staff.Phone 'Особистий Номер', Department.Phone 'Робочий Номер'
FROM Staff, Department
WHERE Department = IdDep
AND IdStaff = @IdStaff

EXEC GetPhone 5
-------------------------------------------------------------------
CREATE VIEW ListSSA
AS
SELECT List.NameDep, Name, SName, SAL, ASAL
FROM   (SELECT NameDep, Name, SName
			FROM Department LEFT JOIN Staff
			ON IdDep = Department) AS List,
	   (SELECT NameDep, SUM(Salary) AS SAL
			FROM Department LEFT JOIN Staff
			ON IdDep = Department
			GROUP BY NameDep) AS DepSal,
		(SELECT SUM(Salary) AS ASAL FROM Staff) AS AllFond
WHERE List.NameDep = DepSal.NameDep

SELECT * FROM ListSSA 
------------------------------------------------------------------------
CREATE VIEW GoToBoss
AS
SELECT *
FROM (SELECT Name [Ім'я Начальника Департаменту], SName [Фамілія Начальника Департаменту]
FROM Staff, Positions
WHERE Staff.Position = Positions.IdPos
AND NameP = 'Топ Мененеджер'
AND Staff.Department IS NOT NULL) AS MenegDep,
(SELECT Name [Ім'я Начальника], SName [Фамілія Начальника]
FROM Staff, Positions
WHERE Staff.Position = Positions.IdPos
AND NameP = 'Топ Мененеджер'
AND  Staff.Department IS NULL) AS Meneg

SELECT * FROM GoToBoss