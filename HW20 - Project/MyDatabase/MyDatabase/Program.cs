using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Data;
using Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation;
using MyDatabase.Models;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);

// 👇 Добавляем поддержку культуры EN (чтобы decimal парсился с точкой)
var cultureInfo = new CultureInfo("en-US");
CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;

// Добавляем логирование
builder.Services.AddLogging();

// ?? Добавляем поддержку контроллеров и представлений
builder.Services.AddControllersWithViews();

builder.Services.AddScoped<OrderService>();


// ? Добавляем поддержку сессий
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});


// ?? Добавляем контекст базы данных
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ?? Добавляем Identity (ПЕРЕД builder.Build())
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    options.Password.RequireDigit = false;
    options.Password.RequiredLength = 6;
    options.Password.RequireNonAlphanumeric = false;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath = "/Account/Login";
    options.AccessDeniedPath = "/Account/AccessDenied";
    options.ExpireTimeSpan = TimeSpan.FromDays(7);
    options.SlidingExpiration = true;
});

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ReturnUrlParameter = "ReturnUrl"; // Важно!
    });

builder.Services.AddControllersWithViews()
    .AddRazorRuntimeCompilation(); // для быстрых изменений в представлениях

builder.Services.AddAuthorization();



var app = builder.Build(); //  Сервисная конфигурация ДО этого момента

app.UseSession();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    await SeedData.Initialize(services);
}

//  Конфигурация Middleware (обработчики запросов)
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication(); //  Добавляем Аутентификацию перед Авторизацией
app.UseAuthorization();

app.MapStaticAssets();


app.MapControllerRoute(
    name: "areas",
    pattern: "{area:exists}/{controller=Home}/{action=Index}/{id?}");


app.MapControllerRoute(
    name: "adminShortcut",
    pattern: "Admin",
    defaults: new { area = "Admin", controller = "Admin", action = "Index" });


app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();


app.MapControllerRoute(
    name: "category",
    pattern: "Category/{action=Index}/{id?}",
    defaults: new { controller = "Category" });

app.MapControllerRoute(
    name: "searchByAuthor",
    pattern: "Book/SearchBooksByAuthor/{authorName?}",
    defaults: new { controller = "Book", action = "SearchBooksByAuthor" });

app.MapControllerRoute(
    name: "allbooks",
    pattern: "Book/AllBooks",
    defaults: new { controller = "Book", action = "AllBooks" });

app.MapControllerRoute(
    name: "categories",
    pattern: "Category/BooksByCategory/{categoryId}",
    defaults: new { controller = "Category", action = "BooksByCategory" });




app.Run();
