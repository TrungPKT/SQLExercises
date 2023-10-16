select * from dbo.DimCustomer
select * from dbo.DimGeography

-- 1
select 
	case
		when c.MiddleName is not null then concat(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) 
		else concat(c.FirstName, ' ', c.LastName) 
	end as FullName, 
	c.BirthDate,
	case
		when c.Gender = 'F' then 'Female'
		else 'Male'
	end as Gender,
	c.EmailAddress,
	c.EnglishEducation as Education,
	c.Phone,
	c.AddressLine1,
	c.AddressLine2
from dbo.DimCustomer c
inner join dbo.DimGeography g on c.GeographyKey = g.GeographyKey
where g.CountryRegionCode = 'GB'


-- 2
select 
	g.EnglishCountryRegionName as CountryName,
	count(c.CustomerKey) as TotalCustomer
from dbo.DimCustomer c
inner join dbo.DimGeography g on c.GeographyKey = g.GeographyKey
group by g.EnglishCountryRegionName

-- 3
select top 100
	p.EnglishProductName as ProductName,
	p.ModelName,
	p.ProductLine,
	c.EnglishProductCategoryName as ProductCategoryName,
	c.EnglishProductSubcategoryName as ProductSubcategoryName,
	p.DealerPrice,
	p.ListPrice,
	p.Color,
	p.EnglishDescription as Description
from dbo.DimProduct p
inner join (
	select psc.ProductSubcategoryKey, psc.EnglishProductSubcategoryName, pc.EnglishProductCategoryName
	from dbo.DimProductSubcategory psc
	inner join dbo.DimProductCategory pc
	on psc.ProductCategoryKey = pc.ProductCategoryKey
) as c
on p.ProductSubcategoryKey = c.ProductSubcategoryKey
order by p.ListPrice desc--, p.EnglishProductName asc

-- 4
with source_table (AccountDescription, OrganizationName, Amount) as (	
	select
		a.AccountDescription as AccountDescription,
		o.OrganizationName as OrganizationName,
		ff.Amount as Amount
	from dbo.FactFinance ff
	inner join dbo.DimAccount a
	on ff.AccountKey = a.AccountKey
	inner join dbo.DimOrganization o
	on ff.OrganizationKey = o.OrganizationKey
	where o.OrganizationName in ('France', 'Germany', 'Australia')
)
select AccountDescription, France, Germany, Australia
from source_table
pivot (
	sum(source_table.Amount)
	for source_table.OrganizationName in (
		France,
		Germany,
		Australia
	)
) as pivoted
order by AccountDescription

-- 5
DBCC FREEPROCCACHE

select
	fpi.ProductKey,
	pscc.EnglishProductName as ProductName,
	pscc.ModelName,
	pscc.EnglishProductCategoryName as ProductCategoryName,
	pscc.EnglishProductSubcategoryName as ProductSubcategoryName,
	fpi.UnitsBalance,
	fpi.UnitCost
from dbo.FactProductInventory fpi
inner join (
	select 
		p.ProductKey,
		p.EnglishProductName, 
		p.ModelName, 
		scc.EnglishProductSubcategoryName, 
		scc.EnglishProductCategoryName
	from dbo.DimProduct p
	inner join (
		select psc.ProductSubcategoryKey, psc.EnglishProductSubcategoryName, pc.EnglishProductCategoryName
		from dbo.DimProductSubcategory psc
		inner join dbo.DimProductCategory pc
		on psc.ProductCategoryKey = pc.ProductCategoryKey
	) as scc
	on p.ProductSubcategoryKey = scc.ProductSubcategoryKey
) as pscc
on fpi.ProductKey = pscc.ProductKey
inner join (
	select 
		max(fpi.DateKey) as maxDateKey
	from dbo.FactProductInventory fpi
) as maxDate 
on fpi.DateKey = maxDate.maxDateKey
--where fpi.DateKey = (
--	select
--		max(fpi.DateKey) as maxDateKey
--	from dbo.FactProductInventory fpi
--)

-- 6
select top 10
	pscc.EnglishProductName as ProductName,
	pscc.ModelName,
	pscc.EnglishProductCategoryName as ProductCategoryName,
	pscc.EnglishProductSubcategoryName as ProductSubcategoryName,
	fpi.UnitsBalance,
	fpi.UnitCost
from dbo.FactProductInventory fpi
inner join (
	select 
		p.ProductKey, 
		p.ProductSubcategoryKey, 
		p.EnglishProductName,
		p.ModelName,
		scc.EnglishProductSubcategoryName, 
		scc.EnglishProductCategoryName
	from dbo.DimProduct p
	inner join (
		select psc.ProductSubcategoryKey, psc.EnglishProductSubcategoryName, pc.EnglishProductCategoryName
		from dbo.DimProductSubcategory psc
		inner join dbo.DimProductCategory pc
		on psc.ProductCategoryKey = pc.ProductCategoryKey
	) as scc
	on p.ProductSubcategoryKey = scc.ProductSubcategoryKey
) as pscc
on fpi.ProductKey = pscc.ProductKey
inner join (
	select 
		max(fpi.DateKey) as maxDateKey
	from dbo.FactProductInventory fpi
) as maxDate on fpi.DateKey = maxDate.maxDateKey
order by fpi.UnitCost desc
--order by fpi.DateKey desc, fpi.UnitCost desc
	
-- 8
select
	fis.SalesOrderNumber, 
	fis.SalesOrderLineNumber, 
	case
		when c.MiddleName is not null then concat(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) 
		else concat(c.FirstName, ' ', c.LastName) 
	end as CustomerName,
	p.EnglishProductName as ProductName,
	fis.OrderQuantity,
	fis.UnitPrice,
	fis.DiscountAmount,
	fis.SalesAmount,
	fis.ProductStandardCost,
	fis.TotalProductCost
from dbo.FactInternetSales fis
inner join dbo.DimCustomer c
on fis.CustomerKey = c.CustomerKey
inner join dbo.DimProduct p
on fis.ProductKey = p.ProductKey
where p.EnglishProductName = 'Road-150 Red, 48'

-- 9
select 
	concat(DimCustomer.FirstName, ' ', DimCustomer.MiddleName, ' ', DimCustomer.LastName) as name, 
	SalesOrderNumber, 
	SalesOrderLineNumber, 
	TotalProductCost 
from dbo.FactInternetSales
inner join dbo.DimCustomer on FactInternetSales.CustomerKey = DimCustomer.CustomerKey
where SalesOrderNumber in (
	select SalesOrderNumber
	from dbo.FactInternetSales fis
	group by SalesOrderNumber
	having count(SalesOrderLineNumber) > 1
)
order by SalesOrderNumber 
-- 9
select top 20
	case
		when c.MiddleName is not null then concat(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) 
		else concat(c.FirstName, ' ', c.LastName) 
	end as CustomerName,
	fis.SalesOrderNumber,
	fis.CustomerKey,
	sum(fis.TotalProductCost) as TotalOrderCost
from dbo.FactInternetSales fis
inner join dbo.DimCustomer c
on fis.CustomerKey = c.CustomerKey
group by 
	fis.SalesOrderNumber,
	fis.CustomerKey,
	c.MiddleName, c.LastName, c.FirstName
order by sum(fis.TotalProductCost) desc

with sales (SalesOrderNumber, CustomerKey, TotalOrderCost) as (
	select
		fis.SalesOrderNumber,
		fis.CustomerKey,
		sum(fis.TotalProductCost)
	from dbo.FactInternetSales fis
	group by
		fis.SalesOrderNumber,
		fis.CustomerKey
)
select top 20
	concat(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) as CustomerName,
	s.SalesOrderNumber,
	s.CustomerKey,
	s.TotalOrderCost
from sales s
inner join dbo.DimCustomer c
on s.CustomerKey = c.CustomerKey
order by s.TotalOrderCost desc

-- 10
select 
	r.ResellerName, 
	frs.ResellerKey, 
	sum(frs.OrderQuantity) as TotalQuantity, 
	sum(frs.TotalProductCost) as TotalOrderCost
from dbo.FactResellerSales frs
inner join dbo.DimReseller r
on frs.ResellerKey = r.ResellerKey
group by r.ResellerName, frs.ResellerKey
order by sum(frs.TotalProductCost) desc