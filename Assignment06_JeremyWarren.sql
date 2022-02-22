--*************************************************************************--
-- Title: Assignment06
-- Author: Jeremy Warren
-- Desc: This file demonstrates how to use Views
-- Change Log: Intital view creation, 02/21/2022
-- 2022-02-21,Jeremy Warren,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JeremyWarren')
	 Begin 
	  Alter Database [Assignment06DB_JeremyWarren] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JeremyWarren;
	 End
	Create Database Assignment06DB_JeremyWarren;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JeremyWarren;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--vCatergory need select columns Catergory ID, and Catergory Name
--Don't forget schema biding

Create view vCatergory
With SCHEMABINDING
As
 Select CategoryID as [Catergory ID], CategoryName as [Catergory Name]
 from dbo.Categories;
go

--Test view
Select * from vCatergory

--For products need ProductID, ProductName, CatergoryID, Unit Price
Create view vProduct
With SCHEMABINDING
  As
   Select ProductID as [Product ID], 
   ProductName as [Product Name], 
   CategoryID as [Catergory ID], 
   UnitPrice as [Unit Price]
  from dbo.Products;
go

--Test view 
Select * from vProduct

--vEmployees needs: Employee ID, Employee First Name, Employee Last Name, Manager ID
Create view vEmployees
With SCHEMABINDING
  As
   Select EmployeeID as [Employee ID], 
   EmployeeFirstName as [First Name], 
   EmployeeLastName as [Last Name], 
   ManagerID as [Manager Id]
  from dbo.Employees;
go
--Test view
Select * from vEmployees

Create view vInventories
With SCHEMABINDING
  As
   Select InventoryID as [Inventory ID], 
   InventoryDate as [Inventory Date], 
   EmployeeID as [Employee ID], 
   ProductID as [Product Id],
   Count as [Count]
  From dbo.Inventories;
go
--Test view
Select * from vInventories

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_JeremyWarren

Deny select on Products to public
Grant select on vProduct to public;
go

Use Assignment06DB_JeremyWarren

Deny select on Categories to public
Grant select on vCatergory to public;


Deny select on Employees to public
Grant select on vEmployees to public;



Deny select on Inventories to public
Grant select on vInventories to public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
--Need Catergory and Product join on CatID--Inner join 
--Select * From Categories;
--go
--Select * From Products;
 Create view vCategoryProductNames
  As
   Select Top 100
   C.CategoryName as [Category Name],
   P.ProductName as[Product Name],
   P.UnitPrice as [Unit Price]
   From Categories as C
   Join Products as P
   On C.CategoryID=P.CategoryID
  Order by C.CategoryName, P.ProductName asc
   ;
go
--Test View
Select * from vCategoryProductNames

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
--Need ProductName(Productstbl), InventoryCount (inventory), InventoryDate(Inventories)
Go
Create view vProductsIventory
  As
   Select Top 10000
   P.ProductName as[Product Name],
   I.InventoryDate as [Inventory Date],
   I.Count as [Inventory Count]
   From Inventories as I
   Join Products as P
   On I.ProductID=P.ProductID
  Order by P.ProductName, I.InventoryDate, I.Count desc
   ;
go
--Test view
Select * from vProductsIventory

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
--Use Select Distinct
--Columns needed: Inventory Date, EmployeeID(Just for join), EmployeeName
--Tables needed: EmployeeID, Invetories. Join on EmployeeID

Create view vEmployeeInventory
 AS
   Select distinct Top 1000
   I.InventoryDate as [Inventory Date],
   E.EmployeeFirstName as [First Name],
   E.EmployeeLastName as [Last Name]
   From Inventories as I 
   Join Employees as E
   On I.EmployeeID=E.EmployeeID
Order by InventoryDate

--Test view
Select * from vEmployeeInventory


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
--Columns needed: Category, Product Name, Inventory Date, Count
--Tables needed: Category, Products, Inventory
--Joins: Category and Products on CatergoryID; Products and Inventory on ProductID
go
Create view vProductCountByInventoryDate
 AS
   Select Top 1000
   C. CategoryName as [Category Name],
   P.ProductName as [Product Name],
   I. InventoryDate as [Inventory Date],
   I.Count as [Inventory Count]
   From Categories as C
   Join Products as P
   On C.CategoryID=P.CategoryID
   Join Inventories as I 
   On I.ProductId=P.ProductID
Order by C.CategoryID, P.ProductName, I.InventoryDate, I.Count
;
go

--Test view
Select * from vProductCountByInventoryDate


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
--Add Employee Name to #6 Query

go
Create view vProductCountByEmployee
 AS
   Select Top 1000
   C. CategoryName as [Category Name],
   P.ProductName as [Product Name],
   I. InventoryDate as [Inventory Date],
   I.Count as [Inventory Count],
   [Employee Name]= (EmployeeFirstName+ ' '+ EmployeeLastName)
   From Categories as C
   Join Products as P
   On C.CategoryID=P.CategoryID
   Join Inventories as I 
   On I.ProductId=P.ProductID
   Join Employees as E
   On E.EmployeeID=I.EmployeeID
Order by I.InventoryDate,C.CategoryID,P.ProductName, I.Count,[Employee Name]
;
go

--Test view ( I was listening to Bohemian Rhapsody during this query)
Select * From vProductCountByEmployee


-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- Add sub query
go
Create view vChaiChangCountByEmployee
 AS
   Select Top 1000
   C. CategoryName as [Category Name],
   P.ProductName as [Product Name],
   I. InventoryDate as [Inventory Date],
   I.Count as [Inventory Count],
   [Employee Name]= (EmployeeFirstName+ ' '+ EmployeeLastName)
   From Categories as C
   Join Products as P
   On C.CategoryID=P.CategoryID
   Join Inventories as I 
   On I.ProductId=P.ProductID
   Join Employees as E
   On E.EmployeeID=I.EmployeeID
   Where P.ProductID in (Select ProductID from Products where ProductID in (1,2))
Order by I.InventoryDate,C.CategoryID,P.ProductName, I.Count,[Employee Name]
;
go

--Test view
Select * from vChaiChangCountByEmployee



-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
-- Self Join
-- Select * from employees

Create view vManagedTable
 AS
  Select top 100
   [Manager Name]=(M.EmployeeFirstName+ ' '+ M.EmployeeLastName),
   [Employee Name]=(E.EmployeeFirstName+ ' '+ E.EmployeeLastName)
   From Employees as E
   Join Employees as M
   on E.ManagerID=M.EmployeeID
Order by [Manager Name]
;
go

--Test view
Select*from vManagedTable



-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.



-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/