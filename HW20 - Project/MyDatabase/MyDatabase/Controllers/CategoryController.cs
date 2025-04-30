using Microsoft.AspNetCore.Mvc;
using MyDatabase.Data;
using MyDatabase.Models;
using System.Linq;

namespace MyDatabase.Controllers
{
    public class CategoryController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CategoryController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult BooksByCategory(int categoryId)
        {
            // Получение списка книг по категории
            var booksInCategory = _context.Books
                .Where(b => b.CategoryID == categoryId)
                .Select(b => new BookViewModel
                {
                    BookID = b.BookID,
                    BookName = b.BookName,
                    Price = (int)b.Price,
                    PhotoLink = _context.PhotoBooks
                        .Where(pb => pb.BookID == b.BookID)
                        .Select(pb => pb.PhotoLink)
                        .FirstOrDefault() ?? "/default/no-image.jpg"
                })
                .ToList();

            // Если нет книг в категории, покажем соответствующее сообщение
            if (!booksInCategory.Any())
            {
                return Content("В этой категории нет книг.");
            }

            // Возвращаем представление, которое выводит книги в категории
            return View(booksInCategory);
        }

    }
}
