-- ******************** 准备动作 ********************
-- 1. 创建数据库.
create database north_wind; -- 我们一会儿要做的34个题用的数据源是从Git上下载的, 微软的北风项目的源数据.

-- 2. 切换数据库.
use north_wind;

-- 3. 查询所有表.
show tables;

-- 4. 导入北风项目的数据源.


-- ******************** 以下是 34个练习题 ********************
-- 需求1: 选中employees 表的所有数据
select * from employees;
select employee_id, last_name, first_name, title, birth_date, hire_date, address, city, region, postal_code, country, reports_to from employees;

-- 需求2: 查询每个客户的 ID, company name, contact name, contact title, city, 和 country.并按照国家名字排序
select customer_id, company_name, contact_name, contact_title,city, country from customers order by country;

-- 替换快捷键: ctrl + 字母R
-- 需求3: 查询每一个商品的product_name, category_name, quantity_per_unit, unit_price, units_in_stock 并且通过 unit_price 字段排序
-- 方式1: 显示内连接
select
    product_name, category_name, quantity_per_unit, unit_price, units_in_stock
from
    categories c
join
    products p on c.category_id = p.category_id
order by
    unit_price desc;

-- 方式2: 隐式内连接.
select
    product_name, category_name, quantity_per_unit, unit_price, units_in_stock
from
    categories c, products p
where
    c.category_id = p.category_id
order by
    unit_price desc;


-- 需求4: 列出所有提供了4种以上不同商品的供应商列表所需字段：supplier_id, company_name, and products_count (提供的商品种类数量).
# step1: 计算每个供应商, 供应的商品总数.
select
    p.supplier_id, company_name,            # 分组字段: 供应商的id, 公司名.
    count(product_id) as products_count     # 计算: 商品的总数
from
    products p
join
    suppliers s on p.supplier_id = s.supplier_id
group by
    p.supplier_id, company_name;      # 根据供应商id, 公司名 分组.

# step2: 计算每个供应商, 供应的商品总数, 筛选出 提供了4种以上不同商品的 供应商及其供应的商品总数.
select
    p.supplier_id, company_name,            # 分组字段: 供应商的id, 公司名.
    count(product_id) as products_count     # 计算: 商品的总数
from
    products p
join
    suppliers s on p.supplier_id = s.supplier_id
group by
    # p.supplier_id, company_name      # 根据供应商id, 公司名 分组.
    p.supplier_id                      # 根据供应商id 分组.
having
    products_count > 4;

# step3: 验真.   12,Plutzer Lebensmittelgroßmärkte AG,5
select * from products where supplier_id = 12;      # 共 5 条


-- 需求5: 提取订单编号为10250的订单详情, 显示如下信息：
-- product_name, quantity, unit_price （ order_items 表), discount , order_date 按商品名字排序
# 思路1: 先连接, 后筛选.
select
    product_name, quantity, oi.unit_price, discount , order_date
from
    orders o
join order_items oi on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
where
    o.order_id = 10250
order by
    p.product_name;

# 思路2: 先筛选, 后连接.
select
    product_name, quantity, oi.unit_price, discount , order_date
from
    orders o
join (select * from order_items where order_id = 10250) oi on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
order by
    p.product_name;

-- 需求6: 收集运输到法国的订单的相关信息，包括订单涉及的顾客和员工信息，下单和发货日期等.
select
    e.employee_id, e.first_name, e.last_name,       # 员工信息.
    c.customer_id, c.company_name,                  # 客户信息
    o.order_date 订单日期, o.shipped_date 发货日期     # 订单数据
from
    employees e
join orders o on e.employee_id = o.employee_id
join customers c on c.customer_id = o.customer_id
where ship_country = 'France';

# 扩展思路: 先筛选, 后连接.  自己尝试做一下.

-- 需求7: 提供订单编号为10248的相关信息，包括product name, unit price (在 order_items 表中),
-- quantity（数量）,company_name（供应商公司名字 ，起别名 supplier_name).
# 思路1: 先连接, 后筛选.
select
    product_name, oi.unit_price, quantity, company_name as supplier_name
from
    order_items oi
join products p on oi.product_id = p.product_id
join suppliers s on s.supplier_id = p.supplier_id
where
    order_id = 10248;

# 思路2: 先筛选, 后连接.

-- 需求8:  提取每件商品的详细信息，包括 商品名称（product_name）, 供应商的公司名称 (company_name，在 suppliers 表中),
-- 类别名称 category_name, 商品单价unit_price, 和每单位商品数量quantity per unit
# 思路1: 显式内连接.
select
    product_name, company_name, category_name, unit_price, quantity_per_unit
from
    categories c
join products p on c.category_id = p.category_id
join suppliers s on s.supplier_id = p.supplier_id;

# 思路2: 隐式内连接.
select
    product_name, company_name, category_name, unit_price, quantity_per_unit
from
    categories c, products p, suppliers s
where
    c.category_id = p.category_id
and
    s.supplier_id = p.supplier_id;

-- 需求9: 另一种常见的报表需求是查询某段时间内的业务指标, 我们统计2016年7月的订单数量，
# 思路1: 模糊查询
select * from orders where order_date like '2016-07%';
# 思路2: 范围查询.
select * from orders where order_date >= '2016-07-01' and order_date <= '2016-07-31';
select * from orders where order_date between '2016-07-01' and '2016-07-31';
# 思路3: 函数实现.
select year('2016-07-01 00:00:00');     # 获取 年份
select month('2016-07-01 00:00:00');    # 获取 月份
select day('2016-07-01 00:00:00');      # 获取 天(月中的第几天)
select * from orders where year(order_date) = 2016 and month(order_date) = 7;

-- 需求11: 统计每个供应商供应的商品种类数量, 结果返回供应商IDsupplier_id
-- ，公司名字company_name ，商品种类数量（起别名products_count )使用 products 和 suppliers 表.
# 思路1: 求交集.  如果供应商没有供应商品, 我们就不显示.
select
    p.supplier_id, s.company_name,            # 分组字段: 供应商id, 公司名.
    count(product_id) as  products_count      # 基于商品的id, 计算(各个供应商供应的)商品的总数.
from
    products p
join suppliers s on p.supplier_id = s.supplier_id
group by
    p.supplier_id;      # 根据供应商id分组.

# 思路2: 求差集.  即使供应商没有供应商品, 我们也显示这个供应商的信息.
select
    p.supplier_id, s.company_name,            # 分组字段: 供应商id, 公司名.
    count(product_id) as  products_count      # 基于商品的id, 计算(各个供应商供应的)商品的总数.
from
    suppliers s
left join products p on p.supplier_id = s.supplier_id
group by
    p.supplier_id, s.company_name;      # 根据供应商id分组.

# 验真.  3,Grandma Kelly's Homestead,3
select * from products where supplier_id = 3;   # 共 3 条.

-- 需求12: 我们要查找ID为10250的订单的总价（折扣前），SUM(unit_price * quantity)
select sum(unit_price * quantity) as total_price from order_items where order_id = 10250;
# 验真, 自己手动算一下.
select * from order_items where order_id = 10250;

-- 需求13:  统计每个员工处理的订单总数, 结果包含员工IDemployee_id，姓名first_name 和 last_name，处理的订单总数(别名 orders_count)
# 场景1: 只统计有订单的 员工的情况.   交集: 内连接.
select
    e.employee_id, e.last_name, e.first_name,   # 分组字段: 员工的id, 姓, 名
    count(order_id) as orders_count
from
    employees e
join orders o on e.employee_id = o.employee_id
group by
    # e.employee_id, e.last_name, e.first_name;
    e.employee_id;

# 场景2: 查看所有员工的订单总数, 哪怕为0.  差集: 左外连接.
select
    e.employee_id, e.last_name, e.first_name,   # 分组字段: 员工的id, 姓, 名
    count(order_id) as orders_count
from
    employees e
left join orders o on e.employee_id = o.employee_id
group by
    # e.employee_id, e.last_name, e.first_name;
    e.employee_id;

# 验真: 4,Peacock,Margaret,155
select * from orders where employee_id = 4;        # 共 155 条;
select * from orders where employee_id = 10;        # 共 1 条;

-- 需求14: 统计每个类别中的库存产品值多少钱？显示三列：category_id, category_name, 和 category_total_value, 如何计算库存商品总价：SUM(unit_price * units_in_stock)。
select
    c.category_id, c.category_name,
    sum(unit_price * units_in_stock) as category_total_value
from
    categories c
join products p on c.category_id = p.category_id
group by
    c.category_id;

# 验真: 6,Meat/Poultry,5729.45
select sum(unit_price * units_in_stock) from products where category_id = 6;    # 5729.45

-- 需求15: 计算每个员工的订单数量
select
    e.employee_id, e.last_name, e.first_name,       # 分组字段, 员工的id, 姓名
    count(order_id) as total_cnt
from
    employees e
left join orders o on e.employee_id = o.employee_id
group by
    e.employee_id;

-- 需求16: 计算每个客户的下订单数 结果包含：用户id、用户公司名称、订单数量（customer_id, company_name, orders_count ）
select
    c.customer_id, c.company_name,
    count(o.order_id) as orders_count
from
    customers c
left join orders o on o.customer_id = c.customer_id
group by
    c.customer_id;

-- 需求17: 统计2016年6月到2016年7月用户的总下单金额并按金额从高到低排序
-- 结果包含：顾客公司名称company_name 和总下单金额（折后实付金额）total_paid
-- 提示：
-- 计算实际总付款金额： SUM(unit_price quantity (1 - discount))
-- 日期过滤 WHERE order_date >= '2016-06-01' AND order_date < '2016-08-01'
select
    c.customer_id, c.company_name,
    sum(unit_price * quantity * (1 - discount)) as total_paid
from
    customers c
join
    (select order_id, customer_id from orders where year(order_date) = 2016 and month(order_date) in (6, 7)) o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
group by
    c.customer_id
order by
    total_paid desc;
# where
    # order_date >= '2016-06-01' AND order_date < '2016-08-01';
    # year(order_date) = 2016 and month(order_date) in (6, 7);


-- 需求18: 统计客户总数和带有传真号码的客户数量
-- 需要字段：all_customers_count 和 customers_with_fax_count
select
    count(1) as all_customers_count,
    count(fax) as customers_with_fax_count
from customers;


-- 需求19: 我们要在报表中显示每种产品的库存量，但我们不想简单地将“ units_in_stock”列放在报表中。报表中只需要一个总体级别，例如低，高：
-- 库存大于100 的可用性为高(high)
-- 50到100的可用性为中等(moderate)
-- 小于50的为低(low)
-- 零库存 为 (none)
select
    product_id, product_name, units_in_stock,
    case
        when units_in_stock > 100 then 'high'
        # when units_in_stock between 50 and 100 then 'moderate'
        when units_in_stock = 0 then 'none'
        when units_in_stock < 50 then 'low'
        else 'moderate'
    end as units_in_stock_level
from products;


-- 需求20: 创建一个报表，统计员工的经验水平
-- 显示字段：first_name, last_name, hire_date, 和 experience
-- 经验字段（experience ）：
-- 'junior' 2014年1月1日以后雇用的员工
-- 'middle' 在2013年1月1日之后至2014年1月1日之前雇用的员工
-- 'senior' 2013年1月1日或之前雇用的员工
select
    first_name, last_name, hire_date,
    case
        when hire_date >= '2014-01-01' then 'junior'
        when hire_date <= '2013-01-01' then 'senior'
        else 'middle'
    end as experience
from
    employees;

-- 需求21: 我们的商店要针对北美地区的用户做促销活动：任何运送到北美地区（美国，加拿大) 的包裹免运费。 创建报表，查询订单编号为10720~10730 活动后的运费价格
# create table t1 as
select
    order_id, order_date, ship_country, freight,
    case
        when ship_country in ('USA', 'Canada') then 0
        else freight
    end as new_freight
from
    orders
where
    order_id between 10720 and 10730;

-- 需求22: 需求：创建客户基本信息报表, 包含字段：客户id customer_id, 公司名字 company_name
-- 所在国家 country, 使用语言language, 使用语言language 的取值按如下规则
-- Germany, Switzerland, and Austria 语言为德语 'German',
-- UK, Canada, the USA, and Ireland -- 语言为英语 'English',
-- 其他所有国家 'Other'
select
    customer_id, company_name, country,
    case
        when country in ('Germany', 'Switzerland', 'Austria') then 'German'
        when country in ('UK', 'Canada', 'USA', 'Ireland') then 'English'
        else 'Other'
    end as language
from
    customers;

-- 需求23: 需求：创建报表将所有产品划分为素食和非素食两类
-- 报表中包含如下字段：产品名字 product_name, 类别名称 category_name
-- 膳食类型 diet_type:
-- 	非素食 'Non-vegetarian' 商品类别字段的值为 'Meat/Poultry' 和 'Seafood'.
-- 	素食
select
    product_id, product_name, category_name,
    case
        when category_name in ('Meat/Poultry', 'Seafood') then 'Non-vegetarian'
        else 'Vegetarian'
    end as diet_type
from
    products p
join categories c on p.category_id = c.category_id;

-- 需求24: 在引入北美地区免运费的促销策略时，我们也想知道运送到北美地区和其它国家地区的订单数量
-- 促销策略, 参见需求21的代码.   北美 = 加拿大 和 美国
# step1: 查看运输到北美的订单总数.
select order_id, ship_country from orders where ship_country in ('USA', 'Canada');      # 共 152 条.

# step2: 完成需求.
select
    case
        when ship_country in ('USA', 'Canada') then '北美地区'
        else '其它地区'
    end as new_address,
    count(1) as total_cnt
from
    orders
group by
    new_address;

# 扩展: if()语句, 格式为: if(条件, 值1, 值2)       条件成立, 返回值1, 否则返回值2.
select if(5 > 3, 5, 3);

select
    count(if(ship_country in ('USA', 'Canada'), 1, null)) as 北美地区订单总数,
    count(if(ship_country not in ('USA', 'Canada'), 1, null)) as 其它地区订单总数
from orders;
# select ship_country from orders;

-- 需求25: 创建报表统计供应商来自那个大洲, 报表中包含两个字段：供应商来自哪个大洲（supplier_continent ）和 供应产品种类数量（product_count）
-- 供应商来自哪个大洲（supplier_continent ）包含如下取值：
-- 'North America' （供应商来自 'USA' 和 'Canada'.）
-- 'Asia' （供应商来自 'Japan' 和 'Singapore')
-- 'Other' (其它国家)
select
   # p.supplier_id, company_name, country, product_id,
    case
        when country in ('USA', 'Canada') then 'North America'
        when country in ('Japan', 'Singapore') then 'Asia'
        else 'Other'
    end as supplier_continent,
    count(product_id) as product_count
from
    products p
join suppliers s on p.supplier_id = s.supplier_id
group by
    supplier_continent;

# 验真: Asia,9
select * from suppliers where country in ('Japan', 'Singapore');    # 3 条, 公司的id为: 4, 6, 20
select * from products where supplier_id in (4, 6, 20);             # 共 9条数据.


-- 需求26: 需求：创建一个简单的报表来统计员工的年龄情况
-- 报表中包含如下字段
-- 年龄（ age ）：生日大于1980年1月1日 'young' ，其余'old'
--  员工数量 （ employee_count）
# 思路1: case when
select
    case
        when birth_date > '1980-01-01' then 'young'
        else 'old'
    end as age,
    count(1) as employee_count
from
    employees
group by
    age;

# 验真
select * from employees where birth_date > '1980-01-01';        # 5条

# 思路2: if()函数.
select
    count(if(birth_date > '1980-01-01',  1, null)) as employee_count_old,
    count(if(birth_date > '1980-01-01', null, 1)) as employee_count_old
from
    employees;

-- 需求27: 统计客户的contact_title 字段值为 ’Owner' 的客户数量
-- 查询结果有两个字段：represented_by_owner 和 not_represented_by_owner
select
    count(if(contact_title = 'Owner', 1, null)) as represented_by_owner,
    count(if(contact_title != 'Owner', 1, null)) as not_represented_by_owner
from customers;

# 验真
select * from customers where contact_title = 'Owner';      # 17条


-- 需求28: Washington (WA) 是 Northwind的主要运营地区，统计有多少订单是由华盛顿地区的员工处理的，
-- 多少订单是有其它地区的员工处理的
-- 结果字段： orders_wa_employees 和 orders_not_wa_employees
select
    # e.employee_id, region, order_id
    count(if(region = 'WA', 1, null)) as orders_wa_employees,
    count(if(region != 'WA', 1, null)) as orders_not_wa_employees
from
    employees e
join orders o on e.employee_id = o.employee_id;

# 验真.
select employee_id from employees where region = 'WA';        # 看看哪些员工属于 华盛顿的.
select * from orders where employee_id in (1, 2, 3, 4, 8);    # 605
select * from orders where employee_id in (select employee_id from employees where region = 'WA');  # 605


-- 需求29: 创建报表，统计不同类别产品的库存量，将库存量分成两类 >30 和 <=30 两档分别统计数量
-- 报表包含三个字段, 类别名称 category_name, 库存充足 high_availability, 库存紧张 low_availability
-- 简化需求: 统计不同类别产品的库存量
select
    category_name, sum(units_in_stock) as total_units
from
    categories c
join products p on p.category_id = c.category_id
group by
    category_name;

# 最终版.
# 思路1: 基于分类名, 库存量分组, 进行统计, 有结果, 但是不满足需求(要的3列)
select
    category_name,
    case
        when units_in_stock > 30 then 'high_availability'
        else 'low_availability'
    end as availability,
    sum(units_in_stock) as total_units
from
    categories c
join products p on p.category_id = c.category_id
group by
    category_name, availability;        # 根据 类别名, 库存量分组.

# 思路2: 分组计算时, 只计算我们要的数据即可.
select
    category_name,
    # 如果库存量 > 30, 则记录该库存量, 否则记录为: 0
    sum(if(units_in_stock > 30, units_in_stock, 0)) as high_availability,
    sum(if(units_in_stock <= 30, units_in_stock, 0)) as low_availability
from
    categories c
join products p on p.category_id = c.category_id
group by
    category_name;


-- 需求30: 创建报表统计运输到法国的的订单中，打折和未打折订单的总数量
-- 结果包含两个字段：full_price （原价）和 discounted_price（打折）
# step1: 计算 原价的总订单数量, 不严谨, 下边这种写法会导致: 如果某个订单中, 有一个商品打折了，那么该订单就计算了2次.
select
    count(distinct o.order_id)
from
    orders o
join order_items oi on o.order_id = oi.order_id
where oi.discount != 0;      # 1317

# step2: 计算每个订单的 折扣总值.
select
    o.order_id, sum(discount) as total_discount
from
    orders o
join order_items oi on o.order_id = oi.order_id
group by
    o.order_id;

# step3: 计算最终结果, 原价的多少订单, 折扣的多少订单.
select
    o.order_id, sum(discount) as total_discount,
    count(if(total_discount = 0, 1, null)) as full_price,
    count(if(total_discount != 0, 1, null)) as discounted_price
from
    orders o
join order_items oi on o.order_id = oi.order_id
group by
    o.order_id;

select
    count(if(total_discount = 0, 1, null)) as full_price,
    count(if(total_discount != 0, 1, null)) as discounted_price
from (
    select
        o.order_id, sum(discount) as total_discount
    from
        orders o
    join order_items oi on o.order_id = oi.order_id
    where ship_country = 'France'
    group by
        o.order_id
) t1;

# 验真.
select count(1) from orders where ship_country = 'France';


-- 需求31: 输出报表，统计不同供应商供应商品的总库存量，以及高价值商品的库存量（单价超过40定义为高价值）
-- 结果显示四列：
-- 供应商ID supplier_id
-- 供应商公司名 company_name
-- 由该供应商提供的总库存 all_units
-- 由该供应商提供的高价值商品库存 expensive_units
select
    p.supplier_id, company_name,    # 分组字段, 供应商id, 公司名
    sum(units_in_stock) all_units,
    sum(if(unit_price > 40, units_in_stock, 0)) expensive_units
from
    suppliers s
join products p on s.supplier_id = p.supplier_id
group by
    p.supplier_id, company_name;

# 验真: 4,Tokyo Traders,64,29
select product_id, supplier_id, unit_price, units_in_stock from products where supplier_id = 4;

-- 需求32: 创建报表来为每种商品添加价格标签，贵、中等、便宜
-- 结果包含如下字段：product_id, product_name, unit_price, 和 price_level
-- 价格等级price_level的取值说明：
-- 'expensive' 单价高于100的产品
-- 'average' 单价高于40但不超过100的产品
-- 'cheap' 其他产品
select
    product_id, product_name, unit_price,
    case
        when unit_price > 100 then 'expensive'
        when unit_price <= 40 then 'cheap'
        else 'average'
    end as price_level
from products;

-- 需求33: 制作报表统计所有订单的总价（不计任何折扣）对它们进行分类。
-- 包含以下字段：
-- 	order_id
-- 	total_price（折扣前）
-- 	price_group
-- 字段 price_group 取值说明：
-- 	'high' 总价超过2000美元
-- 	'average'，总价在$ 600到$ 2,000之间，包括两端
-- 	'low' 总价低于$ 600
# 思路1: 子查询写法.
select
    *,
    case
        when total_price > 2000 then 'high'
        when total_price < 600 then 'low'
        else 'average'
    end as price_group
from (
    select
        order_id, sum(quantity * unit_price) total_price
    from
        order_items
    group by
        order_id
) t1;


# 思路2: 直接写聚合函数搞定.
select
    order_id, sum(quantity * unit_price) total_price,
    case
        when sum(quantity * unit_price) > 2000 then 'high'
        when sum(quantity * unit_price) < 600 then 'low'
        else 'average'
    end as price_group
from
    order_items
group by
    order_id;

-- 需求34: 统计所有订单的运费，将运费高低分为三档
-- 报表中包含三个字段
-- low_freight freight值小于“ 40.0”的订单数
-- avg_freight freight值大于或等于“ 40.0”但小于“ 80.0”的订单数
-- high_freight freight值大于或等于“ 80.0”的订单数
select
    count(if(freight < 40, 1, null)) low_freight,
    count(if(freight >= 40 and freight < 80, 1, null)) avg_freight,
    count(if(freight >= 80, 1, null)) high_freight
from
    orders;