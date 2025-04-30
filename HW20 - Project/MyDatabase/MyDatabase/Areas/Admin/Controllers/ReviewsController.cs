using Microsoft.AspNetCore.Mvc;

namespace MyDatabase.Views.Admin.Controllers
{
    public class ReviewsController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
