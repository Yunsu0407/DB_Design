<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그아웃</title>
<script>
	function redirectToMain() {
		alert("로그아웃 되었습니다.");
		location.href = "/LibrarySystem";
	}
</script>
</head>
<body>
	<%
	// 세션 무효화
	HttpSession hs = request.getSession(false); // 기존 세션 가져오기, 없으면 null
	if (session != null) {
		session.invalidate(); // 세션 무효화
	}

	// 쿠키 초기화
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (Cookie cookie : cookies) {
			if ("userID".equals(cookie.getName())) {
		// 쿠키 삭제를 위해 유효기간을 0으로 설정
		cookie.setMaxAge(0);
		cookie.setPath("/"); // 동일한 경로에서만 삭제 가능
		response.addCookie(cookie);
			}
		}
	}

	// 로그아웃 완료 후 메인 페이지로 이동
	out.println("<script>redirectToMain();</script>");
	%>
</body>
</html>