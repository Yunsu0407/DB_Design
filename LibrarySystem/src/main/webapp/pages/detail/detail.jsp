<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="model.Book"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 대여</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.detail-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

th, td {
	padding: 0 5px; /* 셀 내부 양옆 공백 설정 */
	text-align: center; /* 텍스트 가운데 정렬 */
}

.detail-anchors {
	margin-top: 10px;
}

a {
	padding: 0 10px;
	color: blue;
}
</style>
</head>
<body>
	<%
	int book_id = Integer.parseInt(request.getParameter("id"));

	String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
	String dbID = System.getenv("id");
	String dbPS = System.getenv("ps");

	Connection conn = null;
	PreparedStatement pstmt = null;
	String sql = null;
	ResultSet rs = null;
	try {
		Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 드라이버 로드
		conn = DriverManager.getConnection(jdbcUrl, dbID, dbPS);
		// 2. 쿼리 실행
		sql = "SELECT * FROM Book WHERE id = " + book_id;
		pstmt = conn.prepareStatement(sql);
		rs = pstmt.executeQuery();
	} catch (Exception e) {
		out.println("DB 연동 오류: " + e.getMessage());
		e.printStackTrace();
		return; // 흐름 중단
	}

	Book book = null;
	while (rs.next()) {
		int id = rs.getInt("id");
		String name = rs.getString("name");
		String author = rs.getString("author");
		String publisher = rs.getString("publisher");
		String category = rs.getString("category");
		int total_qty = rs.getInt("total_qty");
		int remain_qty = rs.getInt("remain_qty");
		double rate = rs.getDouble("rate");
		book = new Book(id, name, author, publisher, category, total_qty, remain_qty, rate);
	}
	%>
	<div class="detail-container">
		<div>
			<h1>도서 대여</h1>
		</div>
		<div>
			<table border="1">
				<thead>
					<tr>
						<th>ID</th>
						<th>도서명</th>
						<th>저자</th>
						<th>출판사</th>
						<th>카테고리</th>
						<th>총 수량</th>
						<th>남은 수량</th>
						<th>평점</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td><%=book.getId()%></td>
						<td><%=book.getName()%></td>
						<td><%=book.getAuthor()%></td>
						<td><%=book.getPublisher()%></td>
						<td><%=book.getCategory()%></td>
						<td><%=book.getTotal_qty()%></td>
						<td><%=book.getRemain_qty()%></td>
						<td><%=book.getRate()%></td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="detail-anchors">
			<a href="/LibrarySystem">메인으로</a> <a
				href="/LibrarySystem/pages/rent/rent.jsp?id=<%=book.getId()%>">대여하기</a>
		</div>
	</div>
</body>
</html>