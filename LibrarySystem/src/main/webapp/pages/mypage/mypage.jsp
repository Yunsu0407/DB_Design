<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.rent-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.rent-table {
	padding: 10px 0 20px 0;
}

th, td {
	padding: 0 5px; /* 셀 내부 양옆 공백 설정 */
	text-align: center; /* 텍스트 가운데 정렬 */
}

a {
	color: blue;
}
</style>
</head>
<body>
	<%
	HttpSession hs = request.getSession(false);
	Integer userPK = (hs != null) ? (Integer) hs.getAttribute("userPk") : null;

	if (userPK == null) {
		out.println("<script>");
		out.println("alert('로그인이 필요한 서비스입니다.');");
		out.println("location.href = '/LibrarySystem/pages/login/login.jsp';");
		out.println("</script>");
		return;
	}

	// 데이터베이스 연결
	String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
	String dbUser = System.getenv("id");
	String dbPassword = System.getenv("ps");
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
		Class.forName("com.mysql.cj.jdbc.Driver");
		conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

		// Rent 테이블과 Book 테이블 조인하여 대출 기록 조회
		String sql = "SELECT r.id AS rentID, b.name AS bookName, r.startAt, r.expectAt, r.endAt, r.is_returned, r.book_rate "
		+ "FROM Rent r " + "JOIN Book b ON r.bookID = b.id " + "WHERE r.userID = ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, userPK);
		rs = pstmt.executeQuery();
	} catch (Exception e) {
		out.println("DB 연동 오류: " + e.getMessage());
		e.printStackTrace();
		return;
	}
	%>
	<div class="rent-container">
		<h1>마이페이지</h1>
		<div class="rent-table">
			<table border="1">
				<thead>
					<tr>
						<th>대출 번호</th>
						<th>도서명</th>
						<th>대여일</th>
						<th>반납 예정일</th>
						<th>반납일</th>
						<th>반납 여부</th>
						<th>평점</th>
					</tr>
				</thead>
				<tbody>
					<%
					while (rs.next()) {
						int rentID = rs.getInt("rentID");
						String bookName = rs.getString("bookName");
						Date startAt = rs.getDate("startAt");
						Date expectAt = rs.getDate("expectAt");
						Date endAt = rs.getDate("endAt");
						boolean isReturned = rs.getBoolean("is_returned");
						int bookRate = rs.getInt("book_rate");
					%>
					<tr>
						<td><%=rentID%></td>
						<td><%=bookName%></td>
						<td><%=startAt%></td>
						<td><%=expectAt%></td>
						<td><%=endAt != null ? endAt : "미반납"%></td>
						<td>
							<%
							if (isReturned) {
							%> 반납 완료 <%
							} else {
							%> <a
							href="/LibrarySystem/pages/return/return.jsp?rentID=<%=rentID%>">반납하기</a>
							<%
							}
							%>
						</td>

						<td><%=bookRate != 0 ? bookRate : "미평가"%></td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
		<a href="/LibrarySystem">메인으로</a>
	</div>
	<%
	try {
		if (rs != null)
			rs.close();
	} catch (Exception ignored) {
	}
	try {
		if (pstmt != null)
			pstmt.close();
	} catch (Exception ignored) {
	}
	try {
		if (conn != null)
			conn.close();
	} catch (Exception ignored) {
	}
	%>
</body>
</html>
