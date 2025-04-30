using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Data;
using MyDatabase.Models;

namespace MyDatabase.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class CategoriesController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CategoriesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Admin/Categories
        public async Task<IActionResult> Index()
        {
            return View(await _context.Categories.ToListAsync());
        }

        // GET: Admin/Categories/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Admin/Categories/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Category category)
        {
            if (string.IsNullOrWhiteSpace(category.CategoryName))
            {
                return Json(new { success = false, message = "Название категории обязательно." });
            }

            var exists = await _context.Categories
                .AnyAsync(c => c.CategoryName.ToLower() == category.CategoryName.ToLower());

            if (exists)
            {
                return Json(new { success = false, message = "Такая категория уже существует." });
            }

            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Категория успешно добавлена!" });
        }



        // GET: Admin/Categories/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            return View(category);
        }

        // POST: Admin/Categories/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Category model)
        {
            var category = await _context.Categories.FirstOrDefaultAsync(c => c.CategoryID == model.CategoryID);
            if (category == null)
                return Json(new { success = false, message = "Категория не найдена." });

            // Проверка уникальности имени категории
            if (await _context.Categories.AnyAsync(c => c.CategoryName == model.CategoryName && c.CategoryID != model.CategoryID))
                return Json(new { success = false, message = "Такая категория уже существует." });

            category.CategoryName = model.CategoryName;

            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Категория успешно обновлена!" });
        }

        // GET: Admin/Categories/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();

            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> CheckCategoryName([FromBody] CheckCategoryNameRequest request)
        {
            var exists = await _context.Categories
                .AnyAsync(c => c.CategoryName.ToLower() == request.CategoryName.ToLower());

            return Json(!exists);
        }

        public class CheckCategoryNameRequest
        {
            public string CategoryName { get; set; }
        }

    }
}
