<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="model.Book"%>
<%@page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>메인</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.main-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.main-anchors {
	margin-top: 10px;
}

.main-table {
	padding: 10px 0 20px 0;
}

th, td {
	padding: 0 5px; /* 셀 내부 양옆 공백 설정 */
	text-align: center; /* 텍스트 가운데 정렬 */
}
</style>
</head>
<body>
	<%
	// 세션에서 로그인 사용자 정보 가져오기
	HttpSession hs = request.getSession(false);
	Integer loggedInUser = (hs != null) ? (Integer) hs.getAttribute("userPk") : null;

	// 비로그인 상태 처리
	if (loggedInUser == null) {
	    loggedInUser = -1; // 비로그인 상태
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
		sql = "SELECT b.id, b.name, b.author, b.publisher, c.name AS category_name, "
		    + "b.total_qty, b.remain_qty, b.rate "
		    + "FROM Book b "
		    + "JOIN Category c ON b.category = c.id "
		    + "ORDER BY b.id";
		pstmt = conn.prepareStatement(sql);
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
	<div class="main-container">
		<div>
			<h1>도서 대여 시스템</h1>
		</div>
		<div>
			<div>
				<form action="pages/search/search.jsp" method="get">
					<select name="searchType">
						<option value="name">제목</option>
						<option value="author">저자</option>
						<option value="publisher">출판사</option>
					</select> <input type="text" name="keyword" placeholder="검색어를 검색하세요.">
					<input type="submit" value="검색">
				</form>
			</div>
		</div>
		<div class="main-anchors">
			<%
			if (loggedInUser != -1) { // 로그인 상태
			%>
			<a href="/LibrarySystem/pages/mypage/mypage.jsp">마이페이지</a> 
			<a href="/LibrarySystem/pages/logout/logout.jsp">로그아웃</a>
			<%
			} else { // 비로그인 상태
			%>
			<a href="/LibrarySystem/pages/signup/signup.jsp">회원가입</a> 
			<a href="/LibrarySystem/pages/login/login.jsp">로그인</a>
			<%
			}
			%>
		</div>
		<div class="main-table">
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
						<td><a href="/LibrarySystem/pages/detail/detail.jsp?id=<%=book.getId()%>">
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
	</div>
</body>
</html>
