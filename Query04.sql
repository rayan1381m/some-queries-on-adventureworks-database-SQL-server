create function gettopcustomerforeachproduct (@year int)
returns table as
return
(
    select p.name, t.productid, t.customerid
    from
    (
        select sod.productid, sc.customerid, 
                row_number() over(partition by sod.productid order by sum(sod.orderqty) desc) as rn
        from sales.salesorderdetail sod
        inner join sales.salesorderheader soh on sod.salesorderid = soh.salesorderid
        inner join sales.customer sc on soh.customerid = sc.customerid
        where year(soh.orderdate) = @year
        group by sod.productid, sc.customerid
    ) t
    inner join production.product p on t.productid = p.productid
    where t.rn = 1
);



-- test
select * from gettopcustomerforeachproduct(2011);
