<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
<style type="text/css">
pre{background-color:#efe;padding : 1em;font-size:1.3em}
a{padding : 1em;font-size:1.5em}
</style>
</head>

<body>
<h1>Hint_2017</h1>
<hr />

<span>
<a href="/koba/hints/doc_cast/">工程の開始と終了を記録するjavaBeans-API</a>
hint(2017/6/5)
</span>
<br>
<br>
<span>
<a href="/koba/cast17/">工程の開始と終了を記録するサンプル</a>（エラーの場合も含む）
hint(2017/6/3)
</span>
<hr />

<span>
製造時に製品を構成する部品全部の在庫数を更新する例
hint(2017/5/31)
</span>
<hr />
<pre>
hint(2017.5.31@kobayashi)

簡単な例

koba=> select * from member  order by 1;
 id  |   name    | ticket | udate
-----+-----------+--------+-------
 101 | kobayashi |   9000 |
 102 | oobayashi |   9000 |
 103 | nakagawa  |   9000 |
 108 | ooyama    |   9000 |
 109 | detobata  |   9000 |
(5 行)


select * from ticket ;
 id  | ticket
-----+--------
 101 |   3000
 102 |   5000
(2 行)

	UPDATE member AS m SET ticket = (
		SELECT ticket from ticket t where m.id=t.id) 
	where m.id in ( select id from ticket);


 id  |   name    | ticket | udate
-----+-----------+--------+-------
 101 | kobayashi |   3000 |
 102 | oobayashi |   5000 |
 103 | nakagawa  |   9000 |
 108 | ooyama    |   9000 |
 109 | detobata  |   9000 |
(5 行)

aws17003の、部品在庫を一斉に減らす例

update parts set stock = stock - (
        select d_qty * s.qty from
        product pro, truck2.receive r, truck2.struct s , truck t
        where 
        r.truck_id = t.id 
        and r.truck_id = s.truck_id 
        and pro.truck_id = r.truck_id 
        and pro.query_date = r.query_date
        and parts.id=s.parts_id
        and pro.number = 1 
		--ここでnumberは製造順番
		and r.truck_id = 1001 
		and r.query_date = '2017-5-30' 
) where parts.id in(

	select s.parts_id 
		from truck2.receive r, truck2.struct s , truck t
		where
		r.truck_id = t.id
		and s.truck_id = r.truck_id
		and　r.truck_id = 1001 and r.query_date = '2017-5-30'
)
</pre>
<hr>
<span>
製品を構成する部品数と
不足する部品数
hint(2017/5/31)
</span>
<hr />
<pre>

select * from (
        select r.truck_id,m.maker_id,r.query_date,r.qty,r.appointed_date,m_name,c_name 
		from receive r,maker m,truck t
        where 
		r.truck_id = t.truck_id and m.maker_id=t.maker_id
)
as foo

left join (
        select t.truck_id,count(*) 
		from structure s,truck t,parts p ,receive r
        where 
		p.parts_id=s.parts_id and s.truck_id=t.truck_id and t.truck_id = r.truck_id
        group by 1
) as zaiko

on foo.truck_id= zaiko.truck_id
left join (
        select t.truck_id,count(*) 
		from structure s,truck t,parts p ,receive r
        where 
		p.parts_id=s.parts_id and s.truck_id=t.truck_id and t.truck_id = r.truck_id
        and s.qty * r.qty > p.stock
        group by 1
) as zaiko_ng
on foo.truck_id= zaiko_ng.truck_id
order by 3,1;

 truck_id | maker_id | query_date | qty | appointed_date | m_name |   c_name   | truck_id | count | truck_id | count
----------+----------+------------+-----+----------------+--------+------------+----------+-------+----------+-------
        2 |      101 | 2017-05-29 |   2 | 2017-06-01     | トヨタ | トヨタ中型 |        2 |    10 |          |
        1 |      101 | 2017-05-30 |  10 | 2017-06-01     | トヨタ | トヨタ大型 |        1 |    10 |        1 |     1
(2 行)

</pre>


<hr />
<span>
	製造数計と受注数の対比
hint(2017/5/31)
</span>
<hr />
<pre>
select truck_id,rec_date,sum(lot) from truck t,product p where t.id=p.truck_id and t.maker_id=1 group by 1,2 ;
	製造数計
 truck_id |  rec_date  | sum
----------+------------+-----
      101 | 2017-05-30 |   3
      102 | 2017-05-30 |  10


select * from (select truck_id,rec_date,sum(lot) from truck t,product p where t.id=p.truck_id and t.maker_id=1 group by 1,2 ) as foo
left join receive r
on foo.truck_id=r.truck_id and foo.rec_date=r.rec_date;

						製造数計　　　　受注数
 truck_id |  rec_date  | sum | truck_id | lot | limit_date |  rec_date
----------+------------+-----+----------+-----+------------+------------
      101 | 2017-05-30 |   3 |      101 |  30 | 2017-05-31 | 2017-05-30
      102 | 2017-05-30 |  10 |      102 |  10 | 2017-06-01 | 2017-05-30

</pre>

<hr />
<a href="../juchuuA/">受注一覧の一部(juchuuA)</a>
//2017.5.24@kobayashi
<hr />
<a href="../jq2017/test0.jsp">test0.jsp</a>

<hr />
<pre>
//2017.5.22@kobayashi

&lt;script type="text/javascript"&gt;

$(".try").on("click",function(){
	console.log($(this).val());
	$.ajax(
		{	url: "child.jsp", 
			data:{"OK_OR_NG":$(this).val()},
			success: function(result){
			$("div").html(result);
			if(parseInt(result) <50 ){//結果が50未満なら NG,でなければ OK
				$("#btn").attr("value","NG").prop("disabled",true);
			}else{
				$("#btn").attr("value","OK").prop("disabled",false);
			}
   		}
	});	
});
&lt;/script&gt;
</pre>
<hr />
<a href="mini_mark.jsp">sample on simple</a>
<pre>

&lt;script type="text/javascript"&gt;

//2017.5.18@kobayashi

var tr_students=document.getElementsByClassName("student_list");//「学生表」の「行（&lt;TR&gt;)」の配列
var div_marks=document.getElementsByClassName("marks_by_student");//「成績表」の「（&lt;div&gt;)」の配列
var colors=new Array("#fff","#fcc");
var last_selected_id="";//前回クリックした学生番号（最初だけは「前回」がないので空文字 ""）

function trClick(obj){ // obj = クリックイベントを発行した「学生表」の「行（&lt;TR&gt;)」オブジェクト
	var stu_id=obj.id;

	//クリックされた行の背景色を反転、先にクリックした行を、白地に戻す
	if(last_selected_id){//javaScriptでは、nullでなければ「真」
		document.getElementById(last_selected_id).style.backgroundColor=colors[0];
	}
	last_selected_id=stu_id;
	obj.style.backgroundColor=colors[1];

	//ここから、右側の「成績」の該当学生までを「消去」
	var mark_id="mark_" + stu_id.split("_")[1];//stu_001 ==&gt; mark_001 に変換
	
	var idx=0;
	var len_marks=div_marks.length;
	//いったん、成績の全件を「表示状態」
	for(i=0;i&lt;len_marks ; i++){
		div_marks[i].style.display="block";
	}
	//クリックされた行の「学生番号」未満を非表示に
	while(idx < len_marks && div_marks[idx].getAttribute("id") &lt; mark_id){	
		div_marks[idx++].style.display="none";
	}
}
&lt;/script&gt;
</pre>
</body>

</html>
