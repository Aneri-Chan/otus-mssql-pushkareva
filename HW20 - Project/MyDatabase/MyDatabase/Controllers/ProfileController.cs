using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Data;
using MyDatabase.Models;
using System.Security.Claims;

[Authorize]
public class ProfileController : Controller
{
    private readonly ApplicationDbContext _context;

    public ProfileController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var email = User.FindFirstValue(ClaimTypes.Email);
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == email);
        if (customer == null) return RedirectToAction("Login", "Account");

        var model = new ProfileUpdateViewModel
        {
            CustomerName = customer.CustomerName,
            Email = customer.Email,
            PhoneNumber = customer.PhoneNumber
        };

        // можно также передавать заказы в ViewBag или использовать ViewComponent
        return View("Profile", model);
    }

    [HttpPost]
    public async Task<IActionResult> Update(ProfileUpdateViewModel model)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState
                .Where(kvp => kvp.Value.Errors.Any())
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            return Json(new { success = false, message = "Форма содержит ошибки.", errors });
        }

        var email = User.FindFirstValue(ClaimTypes.Email);
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == email);
        if (customer == null)
            return Json(new { success = false, message = "Пользователь не найден." });

        // 💡 Проверка уникальности номера телефона
        var phoneConflict = await _context.Customers
            .AnyAsync(c => c.PhoneNumber == model.PhoneNumber && c.Email != email);

        if (phoneConflict)
        {
            return Json(new
            {
                success = false,
                message = "Такой номер телефона уже используется другим пользователем.",
                errors = new { PhoneNumber = new[] { "Номер телефона уже занят." } }
            });
        }

        customer.CustomerName = model.CustomerName;
        customer.PhoneNumber = model.PhoneNumber;

        _context.Customers.Update(customer);
        await _context.SaveChangesAsync();

        return Json(new { success = true, message = "Данные успешно обновлены!" });
    }


    [HttpPost]
    public async Task<IActionResult> ChangePassword(ChangePasswordViewModel model)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState
                .Where(kvp => kvp.Value.Errors.Any())
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            return Json(new { success = false, message = "Проверьте поля пароля.", errors });
        }

        var email = User.FindFirstValue(ClaimTypes.Email);
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == email);
        if (customer == null)
            return Json(new { success = false, message = "Пользователь не найден." });

        customer.PasswordHash = Customer.HashPassword(model.NewPassword);
        _context.Customers.Update(customer);
        await _context.SaveChangesAsync();

        return Json(new { success = true, message = "Пароль успешно обновлён!" });
    }



    public async Task<IActionResult> Profile()
    {
        var email = User.FindFirstValue(ClaimTypes.Email);
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == email);
        if (customer == null) return RedirectToAction("Login");

        var model = new ProfileUpdateViewModel
        {
            CustomerName = customer.CustomerName,
            Email = customer.Email,
            PhoneNumber = customer.PhoneNumber
        };

        ViewBag.Orders = await _context.Orders
            .Where(o => o.CustomerID == customer.CustomerID)
            .Select(o => new OrderViewModel
            {
                OrderID = o.OrderID,
                TotalAmount = o.TotalAmount,
                OrderStatus = o.OrderStatus,
                DateInput = o.DateInput,
                Details = _context.OrderDetails
                    .Where(od => od.OrderID == o.OrderID)
                    .Join(_context.Books,
                          od => od.BookID,
                          b => b.BookID,
                          (od, b) => new OrderDetailViewModel
                          {
                              BookTitle = b.BookName,
                              Quantity = od.Quantity,
                              PricePerUnit = od.PricePerUnit
                          }).ToList()
            }).ToListAsync();

        return View(model);
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Profile(ProfileUpdateViewModel model)
    {
        if (!ModelState.IsValid)
{
    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
    foreach (var err in errors)
        Console.WriteLine("Model Error: " + err); // или _logger.LogWarning(...)
    
    return View("Profile", model);
}


        var email = User.FindFirstValue(ClaimTypes.Email);
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == email);
        if (customer == null)
            return RedirectToAction("Login");

        customer.CustomerName = model.CustomerName;
        customer.PhoneNumber = model.PhoneNumber;

        _context.Customers.Update(customer);
        await _context.SaveChangesAsync();

        ViewBag.Message = "Данные обновлены!";
        return RedirectToAction("Profile"); // чтобы сбросить модель
    }

    [HttpPost]
    public async Task<JsonResult> CheckPhone([FromBody] PhoneCheckRequest request)
    {
        bool isTaken = await _context.Customers
            .AnyAsync(c => c.PhoneNumber == request.PhoneNumber && c.Email != request.Email);

        return Json(new { isTaken });
    }


    public IActionResult Cart()
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
