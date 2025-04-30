using MyDatabase.Models;

public class CartItem
{
    public int CartItemID { get; set; }
    public int CustomerID { get; set; }  
    public int BookID { get; set; }
    public int Quantity { get; set; }
    public DateTime DateInput { get; set; } = DateTime.Now;

    public Book Book { get; set; }
}


public class CartViewModel
{
    public int BookID { get; set; }
    public string BookName { get; set; }
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}