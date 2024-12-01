<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="model.Book"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.search-container {
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


.search-anchors {
	margin-top: 10px;
}
</style>
</head>
<body>
	<%
	String searchType = request.getParameter("searchType");
	String keyword = request.getParameter("keyword");
	String selected = null;
	if ("name".equals(searchType)) {
		selected = "제목";
	} else if ("author".equals(searchType)) {
		selected = "저자";
	} else {
		selected = "출판사";
	}

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
		sql = "SELECT b.id, b.name, b.author, b.publisher, c.name AS category_name, " + "b.total_qty, b.remain_qty, b.rate "
		+ "FROM Book b " + "JOIN Category c ON b.category = c.id " + "WHERE b." + searchType + " LIKE ? " + // b.으로 Book 테이블 명확히 지정
		"ORDER BY b.id";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, "%" + keyword + "%");
		rs = pstmt.executeQuery();
	} catch (Exception e) {
		out.println("DB 연동 오류: " + e.getMessage());
		e.printStackTrace();
		return; // 흐름 중단
	}

	ArrayList<Book> books = new ArrayList<>();
	while (rs.next()) {
		int id = rs.getInt("id");
		String name = rs.getString("name");
		String author = rs.getString("author");
		String publisher = rs.getString("publisher");
		String category = rs.getString("category_name");
		int total_qty = rs.getInt("total_qty");
		int remain_qty = rs.getInt("remain_qty");
		double rate = rs.getDouble("rate");
		books.add(new Book(id, name, author, publisher, category, total_qty, remain_qty, rate));
	}
	%>
	<div class="search-container">
		<div>
			<h1>
				"<%=selected%>:
				<%=keyword%>"에 대한 검색결과
			</h1>
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
					<%
					for (Book book : books) {
					%>
					<tr>
						<td><%=book.getId()%></td>
						<td><a
							href="/LibrarySystem/pages/detail/detail.jsp?id=<%=book.getId()%>">
								<%=book.getName()%>
						</a></td>
						<td><%=book.getAuthor()%></td>
						<td><%=book.getPublisher()%></td>
						<td><%=book.getCategory()%></td>
						<td><%=book.getTotal_qty()%></td>
						<td><%=book.getRemain_qty()%></td>
						<td><%=book.getRate()%></td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
		<div class="search-anchors">
			<a href="/LibrarySystem">메인으로</a>
		</div>
	</div>
</body>
</html>