<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<style>
html, body {
	margin: 0;
	padding: 0;
}

.signup-container {
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

table {
	align-items: center;
}

.signup-control {
	padding-top: 10px;
	display: flex;
	justify-content: center;
	gap: 10px;
	display: flex;
}

th {
	width: 120px;
}

.signup-input {
	width: 200px;
}

a {
	padding: 0 70px;
	color: blue;
}
</style>
</head>
<body>
	<div class="signup-container">
		<div>
			<h1>회원가입</h1>
		</div>
		<div>
			<form action="signup.jsp" method="POST" accept-charset="UTF-8">
				<table>
					<tr>
						<th>이름:</th>
						<td><input class="signup-input" type="text" name="name"
							placeholder="이름을 입력하세요." required></td>
					</tr>
					<tr>
						<th>아이디:</th>
						<td><input class="signup-input" type="text" name="userID"
							placeholder="아이디를 입력하세요." required></td>
					</tr>
					<tr>
						<th>비밀번호:</th>
						<td><input class="signup-input" type="password"
							name="password" placeholder="비밀번호를 입력하세요." required></td>
					</tr>
				</table>
				<div class="signup-control">
					<a href="/LibrarySystem">메인으로</a> <input type="submit" value="제출">
					<input type="reset" value="초기화">
				</div>
			</form>
		</div>
	</div>
	<%
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		request.setCharacterEncoding("UTF-8");
		String name = request.getParameter("name");
		String userID = request.getParameter("userID");
		String password = request.getParameter("password");

		if (name != null && userID != null && password != null) {
			String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
			String dbUser = System.getenv("id");
			String dbPassword = System.getenv("ps");
			Connection conn = null;
			PreparedStatement pstmt = null;

			try {
		// JDBC 연결
		Class.forName("com.mysql.cj.jdbc.Driver");
		conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

		// SQL 실행
		String sql = "INSERT INTO User (name, userID, password) VALUES (?, ?, ?)";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, name);
		pstmt.setString(2, userID);
		pstmt.setString(3, password); // 비밀번호는 나중에 암호화 필요!

		int result = pstmt.executeUpdate();
		if (result > 0) {
			// 회원가입 성공 시 루트 페이지로 이동
			out.println("<script>");
			out.println("alert('회원가입이 완료되었습니다.');");
			out.println("location.href='/LibrarySystem';");
			out.println("</script>");
		} else {
			// 회원가입 실패 메시지
			out.println("<script>");
			out.println("alert('회원가입에 실패했습니다. 다시 시도해주세요.');");
			out.println("history.back();");
			out.println("</script>");
		}
			} catch (Exception e) {
		// 오류 발생 시 메시지 출력
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
		} else {
			// 필드가 비어 있는 경우 메시지 출력
			out.println("<script>");
			out.println("alert('모든 필드를 입력해주세요.');");
			out.println("history.back();");
			out.println("</script>");
		}
	}
	%>
</body>
</html>