using Microsoft.AspNetCore.Cryptography.KeyDerivation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Data;
using MyDatabase.Models;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Identity;

public class AccountController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AccountController> _logger;

    public AccountController(ApplicationDbContext context, ILogger<AccountController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllCustomers()
    {
        try
        {
            var customers = await _context.Customers.ToListAsync();

            if (customers == null || customers.Count == 0)
            {
                return Json(new { success = false, message = "База данных пуста." });
            }

            return Json(new { success = true, customers });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Ошибка при получении клиентов.");
            return Json(new { success = false, message = "Ошибка на сервере." });
        }
    }

    [HttpGet]
    public IActionResult Login(string returnUrl = null)
    {
        _logger.LogInformation("User.Identity.IsAuthenticated: {IsAuth}", User.Identity.IsAuthenticated);
        _logger.LogInformation("GET Login, returnUrl: {ReturnUrl}", returnUrl);

        ViewData["ReturnUrl"] = returnUrl;
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Login([FromBody] LoginViewModel model, string returnUrl = null)
    {
        if (model == null)
        {
            _logger.LogWarning("Данные формы не переданы.");
            return Json(new { success = false, message = "Данные формы не переданы." });
        }

        if (!ModelState.IsValid)
        {
            _logger.LogWarning("Ошибка валидации данных.");
            return Json(new { success = false, message = "Ошибка валидации данных." });
        }

        try
        {
            string redirectUrl = Url.Action("Index", "Profile");


            ClaimsIdentity identity = null;

            // Проверка администратора
            var identityUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (identityUser != null)
            {
                var adminRoleId = await _context.Roles
                    .Where(r => r.Name == "Admin")
                    .Select(r => r.Id)
                    .FirstOrDefaultAsync();

                var isAdmin = await _context.UserRoles
                    .AnyAsync(ur => ur.UserId == identityUser.Id && ur.RoleId == adminRoleId);

                var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Email, identityUser.Email),
                new Claim(ClaimTypes.Role, isAdmin ? "Admin" : "User")
            };

                identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                redirectUrl = isAdmin ? "/Admin" : Url.Action("Index", "Profile");
                HttpContext.Session.SetString("UserRole", isAdmin ? "Admin" : "User");
            }
            else
            {
                // Проверка для клиента
                var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == model.Email);
                if (customer == null || !VerifyPassword(customer.PasswordHash, model.Password))
                {
                    _logger.LogWarning("Неверный email или пароль для {Email}.", model.Email);
                    return Json(new { success = false, message = "Неверный email или пароль." });
                }

                var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Email, customer.Email),
                new Claim("CustomerId", customer.CustomerID.ToString()),
                new Claim(ClaimTypes.Role, "Customer")
            };

                identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                HttpContext.Session.SetString("UserRole", "Customer");
            }

            if (identity != null)
            {
                var principal = new ClaimsPrincipal(identity);
                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7)
                };

                await HttpContext.SignInAsync(
                    IdentityConstants.ApplicationScheme,
                    principal,
                    authProperties
                );

                _logger.LogInformation("Пользователь вошёл: {Email}", model.Email);
            }

            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                redirectUrl = returnUrl;
            }

            _logger.LogInformation("Redirecting to: {RedirectUrl}", redirectUrl);
            return Json(new { success = true, redirectUrl });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Ошибка при авторизации.");
            return Json(new { success = false, message = "Ошибка сервера." });
        }
    }

    [Authorize]
    public IActionResult CheckAuth()
    {
        var email = User.Identity?.Name ?? User.FindFirstValue(ClaimTypes.Email);
        return Json(new { authenticated = User.Identity.IsAuthenticated, email });
    }

    [Authorize]
    public IActionResult Profile()
    {
        return RedirectToAction("Index", "Profile");
    }


    [HttpPost]
    public async Task<IActionResult> Register(RegisterViewModel model)
    {
        if (!ModelState.IsValid)
            return View(model);

        bool emailExists = await _context.Customers.AnyAsync(c => c.Email == model.Email);
        if (emailExists)
        {
            ModelState.AddModelError("Email", "Этот Email уже зарегистрирован.");
            return View(model);
        }

        bool phoneExists = await _context.Customers.AnyAsync(c => c.PhoneNumber == model.PhoneNumber);
        if (phoneExists)
        {
            ModelState.AddModelError("PhoneNumber", "Этот номер телефона уже зарегистрирован.");
            return View(model);
        }

        var customer = new Customer
        {
            CustomerName = model.CustomerName,
            Email = model.Email,
            PhoneNumber = model.PhoneNumber,
            PasswordHash = model.Password != null ? Customer.HashPassword(model.Password) : null,
            DateInput = DateTime.Now
        };

        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();

        return RedirectToAction("Index", "Home");
    }



    // Метод для отображения страницы регистрации
    [HttpGet]
    public IActionResult Register()
    {
        return View();
    }

    public async Task<IActionResult> Logout()
    {
        // Выполняем выход пользователя из системы
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

        // Очистка всех сессионных данных
        HttpContext.Session.Clear();

        // Можно также очистить другие куки, если требуется (например, если есть специфические куки, которые нужно удалить)
        Response.Cookies.Delete(".AspNetCore.Identity.Application"); // Пример удаления куки для Identity, если она используется

        return RedirectToAction("Index", "Home");
    }


    private bool VerifyPassword(byte[] storedHash, string inputPassword)
    {
        byte[] salt = new byte[16];
        Array.Copy(storedHash, 0, salt, 0, salt.Length);
        byte[] hash = KeyDerivation.Pbkdf2(password: inputPassword, salt: salt, prf: KeyDerivationPrf.HMACSHA256, iterationCount: 10000, numBytesRequested: 32);
        return hash.SequenceEqual(storedHash.Skip(salt.Length));
    }
}
