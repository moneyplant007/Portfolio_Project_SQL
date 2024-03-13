SELECT * FROM public.nashville_housing

---------- Cleaning Data Using SQL ------------------

----- Populate Property Address data using ISNULL -----

-- Checking where propery address is null
select * from nashville_housing
where propertyaddress IS null

--Analysing data to see if same parcelid has same property address

select a.propertyaddress, a.parcelid, b.parcelid,  b.propertyaddress
from nashville_housing a join nashville_housing b
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

-- Populating property address using parcelid and coalesce

select a.propertyaddress, a.parcelid, b.parcelid,  b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress)
from nashville_housing a join nashville_housing b
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

-- updating table with property address

update nashville_housing
set Propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
from nashville_housing a join nashville_housing b
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null


--coalesce is a function just like isnull, if the column is null, 
--it gets filled with the input we give, it may be a string,
--interger, or a column.

-- Breaking out PropertyAddress into Individual Columns using substr

Alter table nashville_housing
add Propertyadd varchar(240)

update nashville_housing
set Propertyadd = SUBSTR(propertyaddress,1, position(',' in propertyaddress)-1)

select propertyaddress,Propertyadd from nashville_housing

alter table nashville_housing
add Propertystate varchar(240)


update nashville_housing
set Propertystate = substr(propertyaddress, position(','in propertyaddress)+1, length(propertyaddress))

select propertyaddress,Propertystate from nashville_housing


-- Breaking out owner address into individual columns using split_part

alter table nashville_housing
add owneradd varchar(240),
add ownercity varchar(240),
add ownerstate varchar(240)

update nashville_housing
set 
owneradd = split_part(owneraddress, ',',1),
ownercity = split_part(owneraddress, ',',2),
ownerstate = split_part(owneraddress, ',',3)

select 
owneraddress, owneradd, ownercity, ownerstate
from nashville_housing

--standardizing the data in Sold vs Vacant Column

alter table nashville_housing
rename soldasvacant to soldvsvacant

select * from nashville_housing

update nashville_housing
set soldvsvacant = case when soldvsvacant = 'Y' then 'Yes'
						when soldvsvacant = 'N' then 'No'
						ELSE soldvsvacant
						END
						
--Removing Duplicate rows

with find_dups as 
	(
	select *,
			Row_number() over (Partition by parcelid, saledate, saleprice, legalreference, propertyaddress 
							  order by uniqueid) as row_num
	from nashville_housing
	)
delete from find_dups
where row_num > 1

-- Delete Unused columns

alter table nashville_housing
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress
