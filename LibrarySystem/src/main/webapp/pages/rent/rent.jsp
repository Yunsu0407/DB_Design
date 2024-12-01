<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.servlet.http.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>도서 대여</title>
<script>
    function showAlert(message, redirectUrl) {
        alert(message);
        if (redirectUrl) {
            location.href = redirectUrl; // 리다이렉트할 URL이 있으면 이동
        } else {
            history.back(); // 기본적으로 이전 페이지로 이동
        }
    }
</script>
</head>
<body>
    <%
    HttpSession hs = request.getSession(false);
    Integer userPk = (hs != null) ? (Integer) hs.getAttribute("userPk") : null; // 세션에서 PK 가져오기

    // 로그인 확인
    if (userPk == null) {
        out.println("<script>");
        out.println("showAlert('로그인이 필요한 서비스입니다.', '/LibrarySystem/pages/login/login.jsp');");
        out.println("</script>");
        return;
    }

    // 파라미터로 전달된 bookID 가져오기
    String bookID = request.getParameter("id");

    if (bookID == null || bookID.trim().isEmpty()) {
        out.println("<script>");
        out.println("showAlert('유효하지 않은 도서 정보입니다.', '/LibrarySystem');");
        out.println("</script>");
        return;
    }

    // 데이터베이스 연결
    String jdbcUrl = "jdbc:mysql://localhost:3306/DB_Design";
    String dbUser = System.getenv("id");
    String dbPassword = System.getenv("ps");
    Connection conn = null;
    PreparedStatement rentStmt = null;
    PreparedStatement updateStmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Rent 테이블에 대출 기록 삽입
        String rentSql = "INSERT INTO Rent (userID, bookID, startAt, expectAt) "
                       + "VALUES (?, ?, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY))";
        rentStmt = conn.prepareStatement(rentSql);
        rentStmt.setInt(1, userPk); // 세션에서 가져온 PK 사용
        rentStmt.setString(2, bookID);

        int result = rentStmt.executeUpdate();

        if (result > 0) {
            // 책의 remain_qty 감소
            String updateSql = "UPDATE Book SET remain_qty = remain_qty - 1 WHERE id = ? AND remain_qty > 0";
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, bookID);

            int updateResult = updateStmt.executeUpdate();
            out.println("<script>");
            out.println("showAlert('대출이 완료되었습니다.', '/LibrarySystem');");
            out.println("</script>");
        } else {
            out.println("<script>");
            out.println("showAlert('대출에 실패했습니다. 다시 시도해주세요.');");
            out.println("</script>");
        }
    } catch (Exception e) {
        String errorMessage = e.getMessage().replace("'", "\\'").replace("\"", "\\\"");
        out.println("<script>");
        out.println("showAlert('오류 발생: " + errorMessage + "');");
        out.println("</script>");
    } finally {
        try { if (rentStmt != null) rentStmt.close(); } catch (Exception ignored) {}
        try { if (updateStmt != null) updateStmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
    %>
</body>
</html>
