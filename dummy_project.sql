DROP DATABASE IF EXISTS dummy_project;
CREATE DATABASE dummy_project; 
USE  dummy_project;
select * from products;   
select * from reorders;
select * from shipments;
select * from stock_entries;
select * from suppliers;

-- 1 Total Suppliers
select count(*) as total_suppliers from suppliers;

-- 2 Total Products
select count(*) as total_products from products;

-- 3 Total categories dealing
select count(distinct category) as total_categories from products;

-- 4 Total sales value made in the last 3 months (quantity * price)
select round(sum(abs(se.change_quantity)* p.price),2) as total_sales_value_in_last_3_months
from stock_entries as se
join products p
on p.product_id = se.product_id
where se.change_type = "Sale"
and
se.entry_date >= 
  (
    select date_sub(max(entry_date),interval 3 month) from stock_entries
   );
   
-- 5 Total restock value made in last 3 months (quantity * price)
select round(sum(abs(se.change_quantity)*p.price),2) as total_restock_value_in_last_3_months
from stock_entries as se
join products p
on p.product_id = se.product_id
where se.change_type = "Restock"
and
se.entry_date >=
  (
    select date_sub(max(entry_date),interval 3 month) from stock_entries
  );
  
-- 6 
select count(*) from products as p where p.stock_quantity < p.reorder_level
and product_id NOT IN
(
select distinct product_id from reorders where status = "Pending"
 );
 
-- 7 Suppliers and their contact details
select supplier_name,contact_name,email,phone from suppliers;

-- 8 Product with their suppliers and current stock
select p.product_name,s.supplier_name,p.stock_quantity,p.reorder_level
from products as p
join suppliers s on
p.supplier_id = s.supplier_id
order by p.product_name ASC ;

-- 9 Product needing reorder
select product_id , product_name , stock_quantity , reorder_level from products where stock_quantity < reorder_level;

Delimiter $$ 
create procedure AddNewProductManualID(
   in p_name varchar(255),
   in p_category varchar(100),
   in p_price decimal(10,2),
   in p_stock int,
   in p_reorder int,
   in p_supplier int
 )  

Begin
   declare new_prod_id int;
   declare new_shipment_id int;
   declare new_entry_id int;
   
   #make changes in product tables
   #generate the product id
   select max(product_id) + 1 into new_prod_id from products;
   insert into products(product_id,product_name,category,price,stock_quantity,reorder_level,supplier_id)
   values(new_prod_id,p_name,p_category,p_price,p_stock,p_reorder,p_supplier);
   
   
   
   #make change in shipment table
   #generate the shipment id
   select max(shipment_id) + 1 into new_shipment_id from shipments;
   insert into shipments (shipment_id,product_id,supplier_id,quantity_received,shipment_date)
   values(new_shipment_id,new_prod_id,p_supplier,p_stock,curdate()) ;
   
   #make change in stock_entries
   select max(entry_id) + 1 into new_entry_id from stock_entries;
   insert into stock_entries(entry_id,product_id,change_quantity,change_type,entry_date)
   values (new_entry_id,new_prod_id,p_stock,"Restock",curdate()) ;
end $$
Delimiter ;

call AddNewProductManualID('Smart Watch','Electronincs',99.99 ,100,25,5);

select * from products where product_name = "Bettles";
select * from shipments where product_id = 202;
select * from stock_entries where product_id = 202;

-- 11 Product History , [ finding shipments , sales , purchase]
create or replace view product_inventory_history as 
select 
pih.product_id ,
pih.record_type,
pih.record_date,
pih.Quantity,
pih.change_type,
pr.supplier_id 
from 
( 
select product_id ,
"Shipments" as record_type,
shipment_date as record_date,
quantity_received as Quantity,
null change_type
from shipments 

union all 

select 
product_id , 
"Stock Entry" as record_type,
entry_date as record_date,
change_quantity as quantity,
change_type
from stock_entries
)pih
join products pr on pr.product_id = pih.product_id ;

select * from 
product_inventory_history  
where product_id = 123 
order by record_date desc ;

-- 12 Place an reorder
insert into reorders(reorder_id,product_id,reorder_quantity,reorder_date,status)
select max(reorder_id)+1 , 101 , 200 , curdate(), "ordered" from reorders ;

select * from products;
-- 13 receive reorder
delimiter $$ 
create procedure MarkReorderAsReceived(in in_reorder_id int)
begin 
declare product_id int;
declare qty int;
declare sup_id int;
declare new_shipment_id int;
declare new_entry_id int; 

start Transaction;
#get producy_id,quantity from reorders 
select product_id, reorder_quantity 
into product_id , qty
from reorders
where reorder_id = in_reorder_id ;

#Get supplier_id from products 
select supplier_id
into sup_id
from products
where product_id = product_id ;

#update reorder table-- Received
update reorders
set status = "Received"
where reorder_id = in_reorder_id ;

#update quantity in product table 
update products 
set stock_quantity = stock_quantity + qty 
where product_id = product_id ; 

# Insert record into shipment table 
select max(shipment_id) + 1 into new_shipment_id from shipments ;
insert into shipments(shipment_id, product_id , supplier_id ,quantity_received , shipment_date) 
values (new_shipment_id, product_id, sup_id , qty , curdate())  ;

# Insert record into Restock 
select max(entry_id) + 1 into new_entry_id from stock_entries; 
insert into stock_entries(entry_id,product_id,change_quantity,change_type,entry_date) 
values(new_entry_id , product_id , qty , "Restock" , curdate());

commit; 
End$$ 

Delimiter ; 

set sql_safe_updates = 0
 call MarkReorderAsReceived(2)
 
 










select *  from stock_entries
seelct * from shipments

select * from reorders where reorder_date = 13

select * from products where product_id = 141 

select * from products where product_name = "Scene table"  

select * from reorders where reorder_id = 12 

select sum(647,247) 

select * from products where product_name = "Four Shirt" 
select * from reorders where reorder_id = 26

 

   
   
  select sum(63,165) 
   



   