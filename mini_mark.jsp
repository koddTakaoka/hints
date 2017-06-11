<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
<style type="text/css">
.red{background-color:red}
#students  tr:nth-child(even){background-color:#ccccff}
#marks p:nth-child(even){background-color:#ccccff}
#students,#marks {width:20%;float:left;padding:2em;text-align:center}
table{width:60%;margin:auto}
.marks_by_student table{margin:1em}
</style>
</head>

<body>
<h1>閲覧／詳細（学生） 
</h1>

<c:set var="rec_count" value="${12}" />
レコード数=${rec_count}
<hr />

<div id="students">
<table>
<c:forEach var="s" begin="1" end="${rec_count}">
	<fmt:formatNumber value="${s}" var="stu_no" pattern="stu_000" />
	<tr class="student_list" id="${stu_no}" onClick="trClick(this)" >
		<td class="stu_id">id=${stu_no}</td>
	</tr>
</c:forEach>
</table>
</div>

<div id="marks">
<c:forEach var="s" begin="1" end="${rec_count}">

	<fmt:formatNumber value="${s}" var="mark_no" pattern="mark_000" />
	<div id="${mark_no}" class="marks_by_student">
		<span>id=${mark_no}</span>
		<hr>
		<table>
		<c:forEach var="m" begin="50" end="60">
		<tr>
			<td class="sub_name">subject_name</td>
			<td class="sub_mark">${m} </td>
		</tr>
		</c:forEach>
		</table>
	</div>

</c:forEach>
</div>

</body>
<script type="text/javascript">

var tr_students=document.getElementsByClassName("student_list");
var div_marks=document.getElementsByClassName("marks_by_student");
var colors=new Array("#fff","#fcc");
var last_selected_id="";

function trClick(obj){
	var stu_id=obj.id;

	//クリックされた行の背景色を反転、先にクリックした行を、白地に戻す
	if(last_selected_id){//javaScriptでは、nullでなければ「真」
		document.getElementById(last_selected_id).style.backgroundColor=colors[0];
	}
	last_selected_id=stu_id;
	obj.style.backgroundColor=colors[1];

	//ここから、右側の「成績」の該当学生までを「消去」
	var mark_id="mark_" + stu_id.split("_")[1];//stu_001 ==> mark_001 に変換
	
	var idx=0;
	var len_marks=div_marks.length;
	//いったん、成績の全件を「表示状態」
	for(i=0;i<len_marks ; i++){
		div_marks[i].style.display="block";
	}
	//クリックされた行の「学生番号」未満を非表示に
	while(idx < len_marks && div_marks[idx].getAttribute("id") < mark_id){	
		//console.log(div_marks[idx++].getAttribute("id"));
		div_marks[idx++].style.display="none";
	}
}
</script>
</html>
