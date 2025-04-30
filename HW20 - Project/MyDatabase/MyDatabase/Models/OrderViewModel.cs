public class OrderViewModel
{
    public int OrderID { get; set; }
    public decimal TotalAmount { get; set; }
    public string OrderStatus { get; set; }
    public DateTime DateInput { get; set; }
    public List<OrderDetailViewModel> Details { get; set; }
}

public class OrderDetailViewModel
{
    public string BookTitle { get; set; }
    public int Quantity { get; set; }
    public decimal PricePerUnit { get; set; }
}
