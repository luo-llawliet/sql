-- 准备数据.
-- 1. 创建数据库.
create DATABASE IF NOT EXISTS hg;

-- 2. 切换数据库.
use hg;

-- 3. 创建数据表及导入数据, 这个操作直接从Word文档中直接复制粘贴即可.
-- 略.

-- 4. 查询表数据.
select * from student;  -- 学生表, 12条数据
select * from sc;       -- 学生成绩表,   18条数据, 但是有成绩的学生就7条
select * from course;   -- 选修课表, 3条数据
select * from teacher;  -- 授课老师表, 3条数据


-- ********************* 以下是具体的SQL练习题 *********************
-- 1.查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
-- 分解版, 分别求出学习 " 01 "课程和" 02 "课程 的(成绩)信息.
-- select * from sc where CId = 1;  这种写法也可以.
select * from sc where CId = '01';  -- 01课程的信息
select * from sc where CId = '02';  -- 02课程的信息

-- 最终版
select s.SId, Sname, t1.CId, t1.score, t2.cid, t2.score from
    (select * from sc where CId = '01') t1,
    (select * from sc where CId = '02') t2,
    student s
where t1.SId = t2.SId and s.SId = t1.SId and t1.score > t2.score;

-- 1.1 查询同时存在" 01 "课程和" 02 "课程的情况
select * from
    (select * from sc where CId = '01') t1,
    (select * from sc where CId = '02') t2
where t1.SId = t2.SId;

-- 1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
select * from
    (select * from sc where CId = '01') t1 LEFT JOIN
    (select * from sc where CId = '02') t2
on t1.SId = t2.SId;

-- 1.3 查询可能不存在" 01 "课程但存在" 02 "课程的情况
select * from
    (select * from sc where CId = '01') t1 RIGHT JOIN
    (select * from sc where CId = '02') t2
on t1.SId = t2.SId;

-- 1.4 查询不存在" 01 "课程但存在" 02 "课程的情况
select * from sc;
 -- 这种方式查出来的是: 没有学习01课程的信息, 但是存在的问题是, 如果只学了03课, 没学02课程, 也会查的到.
select * from sc where SId not in (select DISTINCT sid from sc where cid = '01');

-- 更严谨一点的写法
select * from sc where SId not in (select DISTINCT sid from sc where cid = '01') and cid = '02';

-- 2.查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select s.SId, Sname, round(avg(score),2) avg_score from student s, sc where s.SId = sc.SId GROUP BY s.SId, Sname having avg_score >= 60;

-- 3. 查询在 SC 表存在成绩的学生信息
-- 思路1: 子查询.
select * from student where sid in (select DISTINCT sid from sc);

-- 思路2: 用连接查询做, 先筛选, 后连接.
select * from student s, (select DISTINCT sid from sc) t1 where s.SId = t1.SId;

-- 思路3: 用连接查询做, 先连接, 后筛选.
select distinct s.*  from student s, sc where s.SId = sc.SId;

-- 4.查询所有同学的学生编号、学生姓名、选课总数、所有课程的成绩总和
SELECT s.SId, s.Sname,count(1) num_course, sum(score) sum_score from student s, sc where s.SId = sc.SId GROUP BY s.SId, s.Sname;

-- 4.1 显示没选课的学生(显示为NULL)
-- 这样写, 数据格式是: 09(sid), 张三(sname), 0(选课总数), null(所有课程的成绩总和)
SELECT s.SId, s.Sname,count(cid) num_course, sum(score) sum_score from student s LEFT JOIN sc on s.SId = sc.SId GROUP BY s.SId, s.Sname;

-- 这样写, 数据格式是: 09(sid), 张三(sname), null(选课总数), null(所有课程的成绩总和)
-- 思路1: case when
SELECT s.SId, s.Sname,(case when count(cid) = 0 then null else count(cid) end) num_course, sum(score) sum_score from student s LEFT JOIN sc on s.SId = sc.SId GROUP BY s.SId, s.Sname;
-- 思路2: nullif函数实现, 格式: nullif(值1, 值2)  作用: 如果值1 = 值2, 则返回null, 否则返回 值1
SELECT s.SId, s.Sname,nullif(count(cid), 'null') num_course, sum(score) sum_score from student s LEFT JOIN sc on s.SId = sc.SId GROUP BY s.SId, s.Sname;
-- 小技巧, 查看函数的作用.
help nullif;

-- 4.2查有成绩的学生信息
SELECT s.SId, s.Sname,count(1) num_course, sum(score) sum_score from student s, sc where s.SId = sc.SId GROUP BY s.SId, s.Sname;

-- 5.查询「李」姓老师的数量
select count(1) from teacher where Tname like '李%';

-- 6.查询学过「张三」老师授课的同学的信息
-- 方式1, 子查询, 不推荐.
SELECT * FROM student st WHERE st.SId IN (SELECT SId from sc WHERE sc.CId = (SELECT CId FROM course WHERE course.TId = (SELECT TId FROM teacher WHERE teacher.Tname = '张三')));

-- 方式2: 连接查询, 先连接, 后筛选.
select * from student s, sc, course c, teacher t where s.SId = sc.SId and sc.CId = c.CId and c.TId = t.TId and Tname = '张三';

-- 方式3: 连接查询, 先筛选, 后连接.
select * from student s, sc, course c, (select tid from teacher where Tname = '张三') t where s.SId = sc.SId and sc.CId = c.CId and c.TId = t.TId;

-- 7.查询没有学全所有课程的同学的信息, 意思是: 有选修课, 但是没有学完所有选修课的学生信息.
-- 方式1: 子查询方式.
--             学生信息                         根据sid分组,查每个学生的 选修课总数                总的选修课数
select * from student where SId in (select sid from sc GROUP BY sid HAVING count(1) < (select count(1) from course));

-- 方式2: 连接查询.
-- 获取 学全所有课程的 学生的id.
select * from
    (select sid, count(1) num_course from sc GROUP BY sid) t1,
    (select count(1) num_course from course) t2
where t1.num_course = t2.num_course;

-- 最终答案
select * from
    (select sid, count(1) num_course from sc GROUP BY sid) t1,
    (select count(1) num_course from course) t2,
    student s
where t1.num_course != t2.num_course and s.SId = t1.SId;

-- 8.查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
-- 方式1: 子查询.
select * from student where sid in (select DISTINCT sid from sc where cid in (select cid from sc where sId = '01') and SId != '01');

-- 方式2, 连接查询.
select * from student s, (select DISTINCT sid from sc where cid in (select cid from sc where sId = '01') and SId != '01') t2 where s.SId = t2.SId;

-- 获取任意一门选修课和 01学生选修课相同的 学生的编号sid
--     去重后的sid                  01号学生所学的所有课程的id                 只要有一门和01学生一直即可    不能是01学生
select DISTINCT sid from sc, (select cid from sc where sId = '01') t1 where sc.CId = t1.CId and sc.SId != '01';

-- 方式3: 最终版.
select * from student s, (select DISTINCT sid from sc, (select cid from sc where sId = '01') t1 where sc.CId = t1.CId and sc.SId != '01') t2 where s.SId = t2.SId;

-- 9.查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
-- 方式1: 从 选修课的总数角度做, 即: 求出01号学生的所有选修课总数,  然后再看其他学生, 谁的选修课总数和01总数相等, 有瑕疵. 假设: 01学生: 1, 2, 3    02学生: 2, 3, 4
select * from student where sid in (select DISTINCT sid from sc where sid != '01' GROUP BY sid having count(1) = (select count(1) from sc where sid = '01'));
select * from student where sid in (select DISTINCT sid from sc where cid in (select cid from sc where sId = '01') and SId != '01');

-- 把01学生的选修课给 拼接起来.  GROUP_CONCAT() 分组连接.
SELECT GROUP_CONCAT(CId ORDER BY CId) FROM sc WHERE SId = '01';

-- 方式2: 连接查询.
select * from
    (select sid, GROUP_CONCAT(CId ORDER BY CId) c1 from sc where SId != '01' GROUP BY sid) t1,  -- 获取除了01学生外, 其他所有(有选修课)学生的 选修课信息
    (SELECT GROUP_CONCAT(CId ORDER BY CId) c1 FROM sc WHERE SId = '01') t2,     -- 获取01学生的所有选修课的信息.
    student s
where t1.c1 = t2.c1 and s.SId = t1.SId;

select * from student s,
 (select sid from sc where SId != '01' GROUP BY sid having GROUP_CONCAT(CId ORDER BY CId) = (SELECT GROUP_CONCAT(CId ORDER BY CId) FROM sc WHERE SId = '01')) t2
where s.SId = t2.SId;

-- 10. 查询没学过"张三"老师讲授的任一门课程的学生姓名
-- 方式: 子查询
select * from student where sid not in (select DISTINCT sid from teacher t, course c, sc where c.TId = t.TId and sc.cid = c.CId and Tname = '张三');

-- 11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
-- 分解版: 查询两门及其以上不及格课程的同学的学号
select sid, count(case when score < 60 then 1 else null end) num_score from sc GROUP BY sid having num_score >= 2;     -- 04, 3门,   06, 2门

-- 方式1: case when
select * from student s,
    (select sid, count(case when score < 60 then 1 else null end) num_score, avg(score) avg_score from sc GROUP BY sid HAVING num_score >= 2) t1
where s.SId = t1.SId;

-- 方式2: 用 or null 的思路来优化 case when
--  count(score < 60 or null)解释:  1. or的意思是 或者, 即: 前边不成立, 才会走后边, 前边成立, 后边不执行.   2. 如果成绩小于60, 条件成立, 就是: count(true)  3. 如果成绩大于60, 就是: count(null)
-- 最终解释: 成绩小于60我们就统计, 否则不统计.  类似于: case when score < 60 then 1 else null end
select * from student s,
    (select sid, count(score < 60 or null) num_score, avg(score) avg_score from sc GROUP BY sid HAVING num_score >= 2) t1
where s.SId = t1.SId;


-- 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select * from sc where CId = '01' and score < 60 ORDER BY score desc;

-- 13.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select *, avg(score) over(PARTITION BY sid) avg_score from sc ORDER BY avg_score desc;

-- 14. 查询各科成绩最高分、最低分和平均分
-- 以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
-- 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
-- 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select
       c.cid, Cname, count(1) num_score, max(score) max_score, min(score) min_score, avg(score) avg_score,
       count(score >= 60 or null) '及格人数',
       concat(round(count(score >= 60 or null) / count(1) * 100, 2), '%') '及格率',
       count(score >= 70 and score < 80 or null) '中等人数',
       concat(round(count(score >= 70 and score < 80  or null) / count(1) * 100, 2), '%') '中等率',
       count(score >= 80 and score < 90 or null) '优良人数',
       concat(round(count(score >= 80 and score < 90  or null) / count(1) * 100, 2), '%') '优良率',
       count(score >= 90 or null) '优秀人数',
       concat(round(count(score >= 90 or null) / count(1) * 100, 2), '%') '优秀率'
from sc, course c
where sc.CId = c.CId
GROUP BY cid, Cname order by num_score desc, cid;

-- 15.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺, 即: 1, 2, 3, 3, 5,  rank()
select *, rank() OVER (PARTITION BY cid order BY score desc) rk from sc;

-- 16.查询学生的总成绩，并进行排名，总分重复时不保留名次空缺, 例如: 1, 2, 3, 3, 4, dense_rank()
select *, dense_rank() OVER (ORDER BY sum_score desc) dr from (select sid, sum(score) sum_score from sc GROUP BY sid) t;

-- 17.统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select c.CId, c.Cname,
       concat(count(score >= 85 and score <= 100 or null), ', ', concat(round(count(score >= 85 and score <= 100 or null) / count(1) * 100, 2) , '%')) '[100-85]',
       concat(count(score >= 70 and score < 85 or null), ', ', concat(round(count(score >= 70 and score < 85 or null) / count(1) * 100, 2) , '%')) '[70-85]',
       concat(count(score >= 60 and score < 70 or null), ', ', concat(round(count(score >= 60 and score < 70 or null) / count(1) * 100, 2) , '%')) '[60-70]',
       concat(count(score >= 0 and score < 60 or null), ', ', concat(round(count(score >= 0 and score < 60 or null) / count(1) * 100, 2) , '%')) '[0-60]'
from sc, course c where sc.CId = c.CId GROUP BY c.cid, c.Cname;

-- 18. 查询各科成绩前三名的记录, 例如: 1, 2, 2, 3
select * from (select *, dense_rank() OVER (PARTITION BY cid order by score desc) dr from sc) t where dr <= 3;

-- 19.查询每门课程被选修的学生数
select cid, count(1) from sc GROUP BY cid;

-- 20.查询出只选修两门课程的学生学号和姓名
--  查询出只选修两门课程的学生的学号 sid
-- select sid, count(1) from sc GROUP BY sid having count(1) = 2;
select sid from sc GROUP BY sid having count(1) = 2;

-- 最终版
select * from student s, (select sid from sc GROUP BY sid having count(1) = 2) t1 where s.SId = t1.SId;

-- 21. 查询男生、女生人数
select ssex, count(1) from student GROUP BY Ssex;

-- 22.查询名字中含有「风」字的学生信息
select * from student where Sname like '%风%';

-- 23.查询同名学生名单，并统计同名人数
-- 查询那个名字是有重名情况的.
select Sname,count(1) from student GROUP BY Sname having count(1) > 1;

-- 最终版.
select * from student s, (select Sname,count(1) from student GROUP BY Sname having count(1) > 1) t1 where s.Sname = t1.Sname;

-- 24. 查询 1990 年出生的学生名单
select * from student where year(Sage) = '1990';

-- 25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select cid, round(avg(score), 2) avg_score from sc GROUP BY cid order by avg_score desc, cid;

-- 26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
select s.SId, Sname, avg(score) avg_score from student s, sc where s.SId = sc.SId GROUP BY s.SId, Sname having avg_score >= 85;

-- 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
select * from student s, sc, course c where s.sid = sc.SId and sc.CId = c.CId and c.Cname = '数学' and score < 60;

-- 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
select * from student s LEFT JOIN sc on s.SId = sc.SId;

-- 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
-- 找到每个学生的最低分, 获取在70分以上的学生的id
select sid, min(score) min_score from sc GROUP BY sid having min_score > 70;

-- 最终答案
select s.sid, Sname, c.CId, Cname, score, min_score from student s, course c, sc, (select sid, min(score) min_score from sc GROUP BY sid having min_score > 70) t1
where s.SId = t1.SId and t1.SId = sc.SId and c.CId = sc.CId;

-- 理解一是任意一门成绩均在70分以上(就是上述的答案), 即: 每门成绩都在70分以上.
select s.sid, Sname, c.CId, Cname, score, min_score from student s, course c, sc, (select sid, min(score) min_score from sc GROUP BY sid having min_score > 70) t1
where s.SId = t1.SId and t1.SId = sc.SId and c.CId = sc.CId;

-- 理解二是存在一门成绩在70分以上即可满足条件, 即: 只要有随便一门课程成绩在70分以上即可.
select s.sid, Sname, c.CId, Cname, score, max_score from student s, course c, sc, (select sid, max(score) max_score from sc GROUP BY sid having max_score > 70) t1
where s.SId = t1.SId and t1.SId = sc.SId and c.CId = sc.CId;

-- 30.查询存在不及格的课程
-- 结果: 01(课程id), 31.0(该课程的最低分)
select cid, min(score) min_score from sc GROUP BY CId HAVING min_score < 60;

-- 结果: 01(课程id), 语文(课程的名字), 31.0(该课程的最低分)
select c.cid, c.Cname, min(score) min_score from sc, course c where sc.CId = c.CId GROUP BY c.CId, Cname HAVING min_score < 60;

-- 31.查询课程编号为 01 且课程成绩在 80 分及以上的学生的学号和姓名
select * from student s, sc where s.SId = sc.SId and cid = '01' and score >= 80;

-- 32. 求每门课程的学生人数
select cid, count(1) nums from sc GROUP BY cid;

-- 33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 这里的成绩不重复的意思是, 假设: 最高分是90分, 且有两个学生都是90分, 我们只要第1条数据.
-- 步骤1: 获取张三老师授课的 课程id.
select cid from course c, teacher t where c.TId = t.TId and t.Tname = '张三'; -- 张三老师, 教数学课, 课程id(cid): 02

-- 步骤2: 查询所有02号课程的成绩, 且按照成绩降序排列.
select * from sc, (select cid from course c, teacher t where c.TId = t.TId and t.Tname = '张三') t1 where sc.CId = t1.CId order by score desc;

-- 步骤3: 最终版. 因为题设说最高分没有重复的, 我们只要第1条即可.
select * from sc, (select cid from course c, teacher t where c.TId = t.TId and t.Tname = '张三') t1 where sc.CId = t1.CId order by score desc limit 0, 1;


-- 34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 这里的成绩有重复的意思是, 假设: 最高分是90分, 且有两个学生都是90分, 这两个学生的信息我们都要.
-- 步骤1: 计算出张三老师教的课程中, 最高分是多少分,   小细节, 其实应该根据 cid进行分组, 但是因为这里的cid的值都是同一个, 所以我们可以省略分组的动作.
-- select c.cid, max(score) from course c, teacher t, sc where c.TId = t.TId and sc.CId = c.CId and  t.Tname = '张三' GROUP BY c.cid;
select c.cid, max(score) max_score from course c, teacher t, sc where c.TId = t.TId and sc.CId = c.CId and  t.Tname = '张三';

-- 步骤2: 获取分数是上述分数, 且课程是上述课程的学生信息.
select * from student s, sc,
    (select c.cid, max(score) max_score from course c, teacher t, sc where c.TId = t.TId and sc.CId = c.CId and  t.Tname = '张三') t1
where s.SId = sc.sid and sc.CId = t1.CId and sc.score = t1.max_score;


-- 35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩, 即: 该学生的任意一门课程的成绩 和 该学生所学的其它所有课程的成绩都是 相同的.
-- 最终结果: 03号学生, 语数外成绩都是 80分, 这个题目的思路是 自关联查询.
select a.SId, a.CId, a.score from sc a, sc b where a.SId = b.SId and a.CId != b.CId and a.score = b.score GROUP BY a.SId, a.CId;

-- 36.查询每门功课成绩最好的前两名
-- 错误的SQL语句, 因为 where条件的字段 必须是该表中已有的字段, 而这里的dr排序字段是我们后加的.
select *, dense_rank() OVER (PARTITION BY CId ORDER BY score desc) dr from sc where dr <= 2;
-- 采用临时表的思想.
select * from (select *, dense_rank() OVER (PARTITION BY CId ORDER BY score desc) dr from sc) t1 where dr <= 2;

-- 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）
-- 其实就是一个分组count(), 之后在组后筛选having即可.
select cid, count(1) nums from sc GROUP BY cid having nums > 5;

-- 38. 检索至少选修两门课程的学生学号
-- 先计算每个学生的选修课总数, 然后做一个组后筛选having即可.
select sid, count(1) nums from sc GROUP BY sid having nums >= 2;

-- 如果我还想查询这些学生的信息呢?
select * from student s, (select sid, count(1) nums from sc GROUP BY sid having nums >= 2) t1
where s.SId = t1.SId;

-- 39. 查询选修了全部课程的学生信息
-- 方式1: 我们认为给定 选修课的总数, 可以这样写, 但是不严谨.
select * from student s, (select sid, count(1) nums from sc GROUP BY sid having nums = 3) t1
where s.SId = t1.SId;

-- 方式2: 通过查询的方式, 获取所有选修课的总数, 推荐使用.
select * from student s,
    (select sid, count(1) nums from sc GROUP BY sid having nums = (select count(1) from course)) t1
where s.SId = t1.SId;

-- 方式3: 改造成连接查询.
select * from student s,
    (select sid, count(1) nums from sc GROUP BY sid) t2,
    (select count(1) nums from course) t3
where
    s.sid = t2.SId and t2.nums = t3.nums;

-- 40. 查询各学生的年龄，只按年份来算
-- 计算公式: 当前时间的年份 - 学生出生时间的年份
select *, (year(now()) - year(Sage)) age from student;

-- 41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
-- timestampdiff(单位, 开始时间, 结束时间)  计算 结束时间 - 开始时间的时间差, 单位是指定的单位, 即: 年月日时分秒这些.
-- HELP timestampdiff;     -- 如果实在不会用, 参考下官方给的解释和示例.
select timestampdiff(year , '1999-03-15 00:00:00', now());  -- 23岁
select timestampdiff(year , '1999-06-15 00:00:00', now());  -- 22岁
-- 最终答案
select *, timestampdiff(year, Sage, now()) age from student;

-- 42.查询本周过生日的学生
-- 思路: 把学生的出生年月日, 拼接成 今年的年份-学生出生的月份-学生出生的天, 判断这个时间是否在本周即可.

-- 步骤1: 如何获取本周的区间呢? 即: 本周的第一天是几号, 本周的最后一天是几号.
-- 细节: MySQL中把一周(7天), 分别用数字进行编号, 范围是: 0 ~ 6
select now();                   -- 当前天, 2022-06-10 10:10:21
select weekday(now());          -- 当前天, 4(周五), 是一周中的第几天, 范围是: 0 ~ 6, 0: 周一, 1: 周二...

-- 把当前时间往前推 指定的天数(今天周几, 就推几天, 注意: 是编号)
select date_sub(now(), INTERVAL weekday(now()) day);        -- 2022-06-06 10:13:28

-- 把当前时间往后推 指定的天数(今天周几, 就推 6 - 当前天的编号 天, 注意: 是编号)
select date_add(now(), INTERVAL 6 - weekday(now()) day);        -- 2022-06-12 10:15:33

-- 步骤2: 最终答案, 判断学生的出生 月日只要在上述的范围即可.
-- 细节1: 把学生的出生年月日, 拼接成 今年的年份-学生出生的月份-学生出生的天, 判断这个时间是否在本周即可.
-- 细节2: 记得把你获取到的各种时间都用 date()函数 转成日期对象即可.
select * from student where date(concat(year(now()), '-', month(Sage), '-', day(sage)))
    BETWEEN
        date(date_sub(now(), INTERVAL weekday(now()) day))
    and
        date(date_add(now(), INTERVAL 6 - weekday(now()) day));

-- 43. 查询下周过生日的学生
-- 步骤1: 获取下周的日期区间, 即: 周一是哪天, 周日是哪天.
select date_add(now(), INTERVAL 7 - weekday(now()) day);    -- 2022-06-13 10:25:44
select date_add(now(), INTERVAL 13 - weekday(now()) day);    -- 2022-06-19 10:26:17

-- 步骤2: 最终答案.
select * from student where date(concat(year(now()), '-', month(Sage), '-', day(sage)))
    BETWEEN
        date(date_add(now(), INTERVAL 7 - weekday(now()) day))
    and
        date(date_add(now(), INTERVAL 13 - weekday(now()) day));

-- 优化版: 把学生的出生年月日, 拼接成 今年的年份-学生出生的月份-学生出生的天, 获取它(时间)是该年的第几周, 然后和 今天是该年的第几周做判断即可.
select dayofyear(now());    -- 年中的第几天, 161
select weekofyear(now());   -- 年中的第几周, 23

select * from student where weekofyear((concat(year(now()), '-', month(Sage), '-', day(sage)))) = weekofyear(now());

-- 44.查询本月过生日的学生
select * from student where month(Sage) = month(now());

-- 45.查询下月过生日的学生
select * from student where month(Sage) = (case when month(now()) = 12 then 1 else month(now()) + 1 end);

-- 测试数据.
-- select * from student where month(Sage) = (case when month('2022-12-10') = 12 then 1 else month('2022-12-10') + 1 end);




select * from account;