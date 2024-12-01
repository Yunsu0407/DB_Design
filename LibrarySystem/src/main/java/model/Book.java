package model;

public class Book {
	private int id;
	private String name;
	private String author;
	private String publisher;
	private String category;
	private int total_qty;
	private int remain_qty;
	private double rate;

	public Book(int id, String name, String author, String publisher, String category, int total_qty, int remain_qty,
			double rate) {
		super();
		this.id = id;
		this.name = name;
		this.author = author;
		this.publisher = publisher;
		this.category = category;
		this.total_qty = total_qty;
		this.remain_qty = remain_qty;
		this.rate = rate;
	}

	public int getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public String getAuthor() {
		return author;
	}

	public String getPublisher() {
		return publisher;
	}

	public String getCategory() {
		return category;
	}

	public int getTotal_qty() {
		return total_qty;
	}

	public int getRemain_qty() {
		return remain_qty;
	}

	public double getRate() {
		return rate;
	}

	@Override
	public String toString() {
		return "Book [id=" + id + ", name=" + name + ", author=" + author + ", publisher=" + publisher + ", category="
				+ category + ", total_qty=" + total_qty + ", remain_qty=" + remain_qty + ", rate=" + rate + "]";
	}
}
