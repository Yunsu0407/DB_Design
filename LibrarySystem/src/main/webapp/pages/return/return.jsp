<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>반납 처리</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.return-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.return-form {
	margin-top: 20px;
}

th, td {
	padding: 5px;
	text-align: center;
}

a {
	color: blue;
}
</style>
<script>
    function validateForm() {
        const rating = document.getElementById("bookRate").value;
        if (rating < 1 || rating > 5) {
            alert("평점은 1~5 사이의 값을 입력해야 합니다.");
            return false;
        }
        return true;
    }
</script>
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

	// GET 요청으로 받은 rentID 확인
	String rentIDParam = request.getParameter("rentID");
	if (rentIDParam == null || rentIDParam.trim().isEmpty()) {
		out.println("<script>");
		out.println("alert('유효하지 않은 요청입니다.');");
		out.println("location.href = '/LibrarySystem';");
		out.println("</script>");
		return;
	}
	int rentID = Integer.parseInt(rentIDParam);

	// 데이터베이스 연결
	String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
	String dbUser = System.getenv("id");
	String dbPassword = System.getenv("ps");
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	String bookName = null;
	String startAt = null;
	String expectAt = null;
	try {
		Class.forName("com.mysql.cj.jdbc.Driver");
		conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

		// Rent와 Book 테이블 조인하여 대출 정보 조회
		String sql = "SELECT b.name AS bookName, r.startAt, r.expectAt " + "FROM Rent r "
		+ "JOIN Book b ON r.bookID = b.id " + "WHERE r.id = ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, rentID);
		rs = pstmt.executeQuery();

		if (rs.next()) {
			bookName = rs.getString("bookName");
			startAt = rs.getDate("startAt").toString();
			expectAt = rs.getDate("expectAt").toString();
		} else {
			out.println("<script>");
			out.println("alert('해당 대출 기록을 찾을 수 없습니다.');");
			out.println("location.href = '/LibrarySystem';");
			out.println("</script>");
			return;
		}
	} catch (Exception e) {
		out.println("DB 연동 오류: " + e.getMessage());
		e.printStackTrace();
		return;
	} finally {
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
	}
	%>

	<div class="return-container">
		<h1>반납 처리</h1>
		<table border="1">
			<tr>
				<th>대출 번호</th>
				<th>도서명</th>
				<th>대출일</th>
				<th>반납 예정일</th>
			</tr>
			<tr>
				<td><%=rentID%></td>
				<td><%=bookName%></td>
				<td><%=startAt%></td>
				<td><%=expectAt%></td>
			</tr>
		</table>
		<form class="return-form" action="return.jsp" method="POST"
			onsubmit="return validateForm();">
			<input type="hidden" name="rentID" value="<%=rentID%>"> <label
				for="bookRate">평점 (1~5):</label> <input type="number" id="bookRate"
				name="bookRate" min="1" max="5" required>
			<button type="submit">반납하기</button>
		</form>
		<a href="/LibrarySystem">메인으로</a>
	</div>

	<%
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String bookRateParam = request.getParameter("bookRate");

		if (bookRateParam != null) {
			int bookRate = Integer.parseInt(bookRateParam);

			try {
		conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

		// Rent 테이블 업데이트
		String updateRentSql = "UPDATE Rent SET is_returned = TRUE, endAt = CURRENT_DATE, book_rate = ? WHERE id = ?";
		pstmt = conn.prepareStatement(updateRentSql);
		pstmt.setInt(1, bookRate);
		pstmt.setInt(2, rentID);

		int rentUpdateResult = pstmt.executeUpdate();

		if (rentUpdateResult > 0) {
			// Book 테이블 평점 업데이트
			String updateBookSql = "UPDATE Book " + "SET rate = ((rate * rate_count) + ?) / (rate_count + 1), "
					+ "rate_count = rate_count + 1 " + "WHERE id = (SELECT bookID FROM Rent WHERE id = ?)";
			PreparedStatement updateBookStmt = conn.prepareStatement(updateBookSql);
			updateBookStmt.setInt(1, bookRate); // 사용자 평점
			updateBookStmt.setInt(2, rentID); // Rent 테이블에서 bookID 조회

			int bookUpdateResult = updateBookStmt.executeUpdate();
			updateBookStmt.close();

			// Book 테이블 남은 수량 증가
			String updateRemainQtySql = "UPDATE Book " + "SET remain_qty = remain_qty + 1 "
					+ "WHERE id = (SELECT bookID FROM Rent WHERE id = ?)";
			PreparedStatement updateRemainStmt = conn.prepareStatement(updateRemainQtySql);
			updateRemainStmt.setInt(1, rentID);

			int remainQtyUpdateResult = updateRemainStmt.executeUpdate();
			updateRemainStmt.close();

			if (bookUpdateResult > 0 && remainQtyUpdateResult > 0) {
				out.println("<script>");
				out.println("alert('반납 및 평점 반영이 완료되었습니다.');");
				out.println("location.href = '/LibrarySystem/pages/mypage/mypage.jsp';");
				out.println("</script>");
			} else {
				out.println("<script>");
				out.println("alert('책 정보 업데이트에 실패했습니다. 다시 시도해주세요.');");
				out.println("history.back();");
				out.println("</script>");
			}
		} else {
			out.println("<script>");
			out.println("alert('반납에 실패했습니다. 다시 시도해주세요.');");
			out.println("history.back();");
			out.println("</script>");
		}
			} catch (Exception e) {
		out.println("<script>");
		out.println("alert('오류 발생: " + e.getMessage() + "');");
		out.println("history.back();");
		out.println("</script>");
			} finally {
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
			}
		}
	}
	%>

</body>
</html>
