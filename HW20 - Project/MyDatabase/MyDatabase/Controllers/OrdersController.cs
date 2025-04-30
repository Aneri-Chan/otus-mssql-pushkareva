using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

public class OrdersController : Controller
{
    private readonly OrderService _orderService;

    public OrdersController(OrderService orderService)
    {
        _orderService = orderService;
    }

    public IActionResult CreateOrder()
    {
        var newOrderId = _orderService.CreateOrder(123, new List<(int, int)>
        {
            (1, 2), // BookID 1, Quantity 2
            (3, 1)  // BookID 3, Quantity 1
        });

        return Content($"Создан заказ с ID: {newOrderId}");
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Checkout()
    {
        var userId = User.Identity.Name;

        try
        {
            var orderId = await _orderService.CreateOrderFromCartAsync(userId);
            return Ok(new { OrderID = orderId });
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }



}

