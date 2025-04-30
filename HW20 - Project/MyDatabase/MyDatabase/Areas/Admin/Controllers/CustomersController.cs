using Microsoft.AspNetCore.Mvc;

namespace MyDatabase.Views.Admin.Controllers
{
    public class CustomersController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
