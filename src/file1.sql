
create database ecommerce;
use ecommerce;

--Creating 4 tables
create table gold_member_users(
	userId varchar(50) primary key,
	signup_date date);

create table users(
	userId varchar(50) primary key,
	signup_date date
	);

create table Products(
	product_name varchar(30) ,
	price int not null,
	product_id int primary key);

create table Sales(
	userId varchar(50),
	created_date date,
	product_id int foreign key references Products(product_id));

--inserting values
insert into gold_member_users(userId, signup_date)
values('John','09-22-2017'), 
	('Mary','04-21-2017');

insert into users(userId, signup_date)
values('John','09-02-2014'), 
	('Michel','01-15-2015'), 
	('Mary','04-11-2014');

insert into Products(product_id, product_name, price)
values(1,'Mobile',980), (2,'Ipad',870), (3,'Laptop',330);

insert into Sales(userId, created_date, product_id)
values('John','04-19-2017',2), ('Mary','12-18-2019',1), ('Michel','07-20-2020',3), ('John','10-23-2019',2), 
('John','03-19-2018',3), ('Mary','12-20-2016',2), ('John','11-09-2016',1), ('John','05-20-2016',3), 
('Michel','09-24-2017',1), ('John','03-11-2017',2), ('John','03-11-2016',1), ('Mary','11-10-2016',1), 
('Mary','12-07-2017',2);

--Show all the tables 
select *from sys.tables;

--Count all the records in a single query
select (select count(*) from gold_member_users) as count_gold_member_users,
(select count(*) from users) as count_users,
(select count(*) from products) as count_product,
(select count(*) from sales) as count_sales;

--total amount each customer spent
select s.userId,sum(p.price) as total_spent from products p
join sales s on p.product_id=s.product_id
group by s.userId

--distinct dates of each customer 
select distinct created_date,userId as customer_name from sales
order by userId;

--first product purchased by each customer
select u.userId, p.product_id, p.product_name, s.created_date from
(select *, ROW_NUMBER() over(partition by product_id order by created_date)as rn from Sales)s
inner join Products p
on s.product_id = p.product_id
inner join users u on 
u.userId = s.userId
where rn = 1;

--most purchased item of each customer and count
select t.userId, t.item_count, t.product_name 
from (select u.userId, count(*) as item_count, p.product_name,
rank() over (partition by u.userId order by count(*) desc) as rnk from Sales s
join users u on u.userId = s.userId
join Products p on s.product_id = p.product_id
group by u.userId, p.product_id, p.product_name
)t
where t.rnk = 1;

--customer who is not the gold_member_user
select u.userId from users u where not exists
(select * from gold_member_users gu where u.userId = gu.userId);

--amount spent by each customer when gold_member
select gu.userId, sum(p.price) as total_amount_spent
from gold_member_users gu join Sales s
on gu.userId = s.userId
join Products p on s.product_id = p.product_id
group by gu.userId
order by gu.userId;

--Customers names starts with M 
select userID from users
where userID like ('M%');

--Find the Distinct customer Id of each customer 
select distinct userID from users;

--Change Column name from price to price_value
exec sp_rename 'Products.price', 'price_value', 'column';
select * from Products;

--Change the Column value product_name – Ipad to Iphone
update Products set product_name = 'Iphone' where product_name = 'Ipad'
select * from Products;

--Change the table name of gold_member_users to gold_membership_users 
exec sp_rename 'gold_member_users', 'gold_membership_users';
select * from gold_membership_users;

--Create new column Status, values should be 2, if the user is gold member, then status should be Yes else No.
alter table users add status varchar(5);

update users set status = case
when userid in (select userId from gold_membership_users)
then 'yes' else 'no' 
end;
select * from users;

--Delete users_ids 1,2 from users and roll back one by one
begin transaction;
delete from users where userId = 'John';
select * from users;
delete from users where userId = 'Mary';
select * from users;
rollback;
select * from users;

--Insert one more record as (4,'Laptop',330)
insert into Products(product_id, product_name, price_value)
values(4,'Laptop',330);
select *from products;

--query to find the duplicates in products
select product_name, count(*) as total_count
from Products
group by product_name
having count(*) > 1;

--Create new table and insert values
create table products_sold(sell_date date, products varchar(30));

insert into products_sold(sell_date, products)
values ('2020-05-30', 'Headphones'), 
 ('2020-06-01','Pencil'), 
 ('2020-06-02','Mask'), 
 ('2020-05-30','Basketball'), 
 ('2020-06-01','Book'), 
 ('2020-06-02', ' Mask '), 
 ('2020-05-30','T-Shirt');

 --query to find number of different products sold for each date and their names
select sell_date, count(products) as number,
STRING_AGG(products,',') as sold_list
from products_sold
group by sell_date;

--Create another new table and insert values
create table dept_tbl(id_deptname varchar(30), emp_name varchar(30), salary int);

insert into dept_tbl(id_deptname, emp_name, salary)
values ('1111-MATH', 'RAHUL', 10000), 
 ('1111-MATH', 'RAKESH', 20000), 
 ('2222-SCIENCE', 'AKASH', 10000), 
 ('222-SCIENCE', 'ANDREW', 10000), 
 ('22-CHEM', 'ANKIT', 25000), 
 ('3333-CHEM', 'SONIKA', 12000), 
 ('4444-BIO', 'HITESH', 2300), 
 ('44-BIO', 'AKSHAY', 10000) 

 --total salary of each department 
 select substring(id_deptname, charindex('-', id_deptname) + 1, len(id_deptname)) as department,
 sum(salary) as total_salary
 from dept_tbl
 group by substring(id_deptname, charindex('-', id_deptname) + 1, len(id_deptname));

  --Create another new table and insert values
 create table email_signup(id int, email_id varchar(30), signup_date date);

 insert into email_signup(id, email_id, signup_date)
 values (1, 'Rajesh@Gmail.com', '2022-02-01'), 
 (2, 'Rakesh_gmail@rediffmail.com', '2023-01-22'), 
 (3, 'Hitest@Gmail.com', '2020-09-08'), 
 (4, 'Salil@Gmmail.com', '2019-07-05'), 
 (5, 'Himanshu@Yahoo.com', '2023-05-09'), 
 (6, 'Hitesh@Twitter.com', '2015-01-01'), 
 (7, 'Rakesh@facebook.com', null); 

 select * from email_signup;

  --query to replace null value with ‘1970-01-01’ 
 update email_signup set signup_date = isnull(signup_date, '1970-01-01');

  --find gmail accounts with latest and first signup date and difference between both the dates
 select 
	 count(*) as count_gmail_account,
	 max(signup_date) as latest_signup_date,
	 min(signup_date)as first_signup_date,
	 DATEDIFF(day, min(signup_date),  max(signup_date)) as diff_in_days
	 from email_signup
	 where email_id like '%gmail.com';

--Create another new table and insert values
create table sales_data(productid int, sale_date date, quantity_sold int);

insert into sales_data(productid, sale_date, quantity_sold)
values(1, '2022-01-01', 20), 
   	(2, '2022-01-01', 15), 
   	(1, '2022-01-02', 10), 
    (2, '2022-01-02', 25), 
    (1, '2022-01-03', 30), 
    (2, '2022-01-03', 18), 
    (1, '2022-01-04', 12), 
	(2, '2022-01-04', 22);

select * from sales_data;

--Assign rank by partition based on product_id and find the latest product_id sold 
select *from
(select *,rank() over (partition by productid order by sale_date desc) as sale_rank
from sales_data) as ranked_data
where sale_rank=1;

--Retrieve the quantity_sold value from a previous row and compare the quantity_sold. 
select productid, sale_date, quantity_sold,
lag(quantity_sold) over (partition by productid order by sale_date) as previous_value,
case
when quantity_sold > lag(quantity_sold) over (partition by productid order by sale_date)
	then 'Increased'
when quantity_sold < lag(quantity_sold) over (partition by productid order by sale_date)
	then 'Decreased'
else 'No change'
end as comparision
from sales_data;

--Partition based on product_id and return the first and last values in ordered set. 
select productid, sale_date, quantity_sold,
first_value(quantity_sold) over (partition by productid order by sale_date asc) as
first_quantity_sold,
last_value(quantity_sold) over (partition by productid order by sale_date asc rows between unbounded preceding
and unbounded following) as
last_quantity_sold
from sales_data;





























