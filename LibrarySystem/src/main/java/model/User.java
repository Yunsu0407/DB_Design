package model;

// 기본키, 이름, 가격, 이미지(url), 설명
public class User {
	private int id;
	private String name;
	private String userID;
	private String password;
	private boolean penalty;
	private int limit;

	public User(int id, String name, String userID, String password, boolean penalty, int limit) {
		this.id = id;
		this.name = name;
		this.userID = userID;
		this.password = password;
		this.penalty = penalty;
		this.limit = limit;
	}

	public int getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public String getUserID() {
		return userID;
	}

	public String getPassword() {
		return password;
	}

	public boolean isPenalty() {
		return penalty;
	}

	public int getLimit() {
		return limit;
	}

	@Override
	public String toString() {
		return "User [id=" + id + ", name=" + name + ", userID=" + userID + ", password=" + password + ", penalty="
				+ penalty + ", limit=" + limit + "]";
	}

}
