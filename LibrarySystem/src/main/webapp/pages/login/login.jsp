<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.login-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.login-control {
	padding-top: 10px;
	display: flex;
	justify-content: center;
	gap: 10px;
	display: flex;
}

a{
	padding: 0 30px;
	color: blue;
}
</style>
<script>
	function redirectToMain() {
		alert("로그인 성공!");
		location.href = "/LibrarySystem";
	}
	function showError() {
		alert("아이디 또는 비밀번호를 확인하세요.");
		history.back();
	}
</script>
</head>
<body>
	<div class="login-container">
		<h1>로그인</h1>
		<form action="login.jsp" method="POST" accept-charset="UTF-8">
			<table>
				<tr>
					<th>아이디:</th>
					<td><input class="login-input" type="text" name="userID"
						placeholder="아이디를 입력하세요." required></td>
				</tr>
				<tr>
					<th>비밀번호:</th>
					<td><input class="login-input" type="password" name="password"
						placeholder="비밀번호를 입력하세요." required></td>
				</tr>
			</table>
			<div class="login-control">
				<a href="/LibrarySystem">메인으로</a> <input type="submit" value="로그인">
			</div>
		</form>
	</div>
	<%
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String userID = request.getParameter("userID");
		String password = request.getParameter("password");

		if (userID != null && password != null) {
			String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
			String dbUser = System.getenv("id");
			String dbPassword = System.getenv("ps");
			Connection conn = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try {
				// JDBC 연결
				Class.forName("com.mysql.cj.jdbc.Driver");
				conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

				// SQL 실행: 아이디와 비밀번호 확인
				String sql = "SELECT id FROM User WHERE userID = ? AND password = ?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, userID);
				pstmt.setString(2, password);
				rs = pstmt.executeQuery();

				if (rs.next()) {
					// 로그인 성공 -> 세션 생성
					int userPk = rs.getInt("id"); // id(PK) 가져오기
					HttpSession hs = request.getSession();
					hs.setAttribute("userPk", userPk); // 세션에 사용자 PK 저장
					out.println("<script>redirectToMain();</script>");
				} else {
					// 로그인 실패
					out.println("<script>showError();</script>");
				}
			} catch (Exception e) {
				out.println("<p>오류 발생: " + e.getMessage() + "</p>");
			} finally {
				try {
					if (rs != null) rs.close();
				} catch (Exception ignored) {
				}
				try {
					if (pstmt != null) pstmt.close();
				} catch (Exception ignored) {
				}
				try {
					if (conn != null) conn.close();
				} catch (Exception ignored) {
				}
			}
		} else {
			out.println("<script>showError();</script>");
		}
	}
	%>
</body>
</html>
