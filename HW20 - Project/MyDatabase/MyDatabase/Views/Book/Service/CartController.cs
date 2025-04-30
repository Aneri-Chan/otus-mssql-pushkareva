using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyDatabase.Data;
using MyDatabase.Models;

namespace MyDatabase.Controllers
{
    [Authorize]
    public class CartController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CartController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        [Authorize]
        public IActionResult AddToCart(int bookID, int quantity)
        {
            if (quantity <= 0) quantity = 1;

            var userName = User.Identity.Name;
            var customer = _context.Customers.FirstOrDefault(c => c.Email == userName);
            if (customer == null)
            {
                return BadRequest("Пользователь не найден.");
            }

            var cartItem = _context.CartItems
                .FirstOrDefault(c => c.CustomerID == customer.CustomerID && c.BookID == bookID);

            if (cartItem != null)
            {
                cartItem.Quantity += quantity;
            }
            else
            {
                cartItem = new CartItem
                {
                    CustomerID = customer.CustomerID,
                    BookID = bookID,
                    Quantity = quantity
                };
                _context.CartItems.Add(cartItem);
            }

            _context.SaveChanges();

            var cartCount = _context.CartItems
                .Where(c => c.CustomerID == customer.CustomerID)
                .Sum(c => c.Quantity);

            return Json(new { success = true, cartCount });
        }

        [HttpGet]
        public IActionResult GetCartItemCount()
        {
            var userName = User.Identity.Name;
            var customer = _context.Customers.FirstOrDefault(c => c.Email == userName);
            if (customer == null)
            {
                return Json(new { count = 0 });
            }

            var cartCount = _context.CartItems
                .Where(c => c.CustomerID == customer.CustomerID)
                .Sum(c => c.Quantity);

            return Json(new { count = cartCount });
        }



        public IActionResult Index()
        {
            var userName = User.Identity.Name;
            var customer = _context.Customers.FirstOrDefault(c => c.Email == userName);
            if (customer == null)
                return RedirectToAction("Error", "Home", new { message = "Пользователь не найден." });

            var cartItems = _context.CartItems
                .Where(c => c.CustomerID == customer.CustomerID)
                .Select(c => new CartViewModel
                {
                    BookID = c.BookID,
                    BookName = c.Book.BookName,
                    Price = c.Book.Price,
                    Quantity = c.Quantity
                })
                .ToList();

            return View(cartItems);
        }
    }
}
