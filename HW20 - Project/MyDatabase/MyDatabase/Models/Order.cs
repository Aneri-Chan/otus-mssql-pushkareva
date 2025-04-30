using MyDatabase.Models;

public class Order
{
    public int OrderID { get; set; }
    public int CustomerID { get; set; }
    public decimal TotalAmount { get; set; }
    public string OrderStatus { get; set; }
    public DateTime DateInput { get; set; }

    public Customer Customer { get; set; }
    public ICollection<OrderDetail> OrderDetails { get; set; }
}
