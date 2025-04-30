using Microsoft.AspNetCore.Mvc;

namespace MyDatabase.Views.Admin.Controllers
{
    public class OrdersController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
