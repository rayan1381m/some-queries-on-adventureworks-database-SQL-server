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

create procedure gettopcustomerforspecifiedproducts 
    @year int, 
    @productlist varchar(max)
as
begin
    declare @productid int, @dynamicquery nvarchar(max)

    create table #results
    (
        productid int,
        customerid int
    )

    declare cur cursor for 
    select value 
    from string_split(@productlist, ',')

    open cur
    fetch next from cur into @productid

    while @@fetch_status = 0
    begin
        set @dynamicquery = 'insert into #results select productid, customerid from gettopcustomerforeachproduct(' + cast(@year as nvarchar(10)) + ') where productid = ' + cast(@productid as nvarchar(10))

        exec sp_executesql @dynamicquery

        fetch next from cur into @productid
    end

    close cur
    deallocate cur

    select * from #results
end

exec gettopcustomerforspecifiedproducts @year = 2011, @productlist = '707,741,764';
