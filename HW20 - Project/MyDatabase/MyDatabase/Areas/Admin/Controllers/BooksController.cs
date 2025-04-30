using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Data;
using MyDatabase.Models;

namespace MyDatabase.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Authorize(Roles = "Admin")]
    public class BooksController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _env;

        public BooksController(ApplicationDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }
        

        // Вспомогательный метод для ViewBag
        private async Task LoadCategoriesAsync()
        {
            ViewBag.Categories = await _context.Categories.ToListAsync();
        }

        public async Task<IActionResult> Index(int page = 1, int pageSize = 10)
        {
            if (page < 1) page = 1;

            var totalBooks = await _context.Books.CountAsync();
            var totalPages = (int)Math.Ceiling(totalBooks / (double)pageSize);

            if (page > totalPages && totalPages > 0) page = totalPages;

            var books = await _context.Books
                .Include(b => b.Category)
                .Include(b => b.Photos)
                .OrderBy(b => b.BookID)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.PageSize = pageSize;

            return View(books);
        }


        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var book = await _context.Books
                .Include(b => b.Photos)
                .FirstOrDefaultAsync(b => b.BookID == id);

            if (book == null)
                return NotFound();

            ViewBag.Categories = await _context.Categories.ToListAsync();

            return View(book);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Book model, List<IFormFile> Images)
        {
            var book = await _context.Books
                .Include(b => b.Photos)
                .FirstOrDefaultAsync(b => b.BookID == model.BookID);

            if (book == null)
                return Json(new { success = false, message = "Книга не найдена." });

            // Обновляем поля книги
            book.BookName = model.BookName;
            book.Author = model.Author;
            book.Price = model.Price;
            book.Weight = model.Weight;
            book.ISBN = model.ISBN;
            book.Description = model.Description;
            book.New = model.New;
            book.AddCategory = model.AddCategory;
            book.Bestseller = model.Bestseller;
            book.CategoryID = model.CategoryID;

            // Папка с изображениями книги
            var bookFolderPath = Path.Combine(_env.WebRootPath, "media", "ContentPhoto", "UploadImages", $"book_{book.BookID}");

            // Если загружены новые изображения
            if (Images != null && Images.Any())
            {
                // Удаляем старые файлы с диска
                if (Directory.Exists(bookFolderPath))
                {
                    Directory.Delete(bookFolderPath, true);
                }

                Directory.CreateDirectory(bookFolderPath);

                // Удаляем старые записи о фото из базы
                _context.PhotoBooks.RemoveRange(book.Photos);

                // Загружаем новые изображения
                foreach (var image in Images)
                {
                    var fileName = Guid.NewGuid() + Path.GetExtension(image.FileName);
                    var filePath = Path.Combine(bookFolderPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var photo = new PhotoBook
                    {
                        BookID = book.BookID,
                        PhotoLink = Path.Combine("ContentPhoto", "UploadImages", $"book_{book.BookID}", fileName).Replace("\\", "/"),
                        DateInput = DateTime.Now
                    };

                    _context.PhotoBooks.Add(photo);
                }
            }

            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Книга успешно обновлена!" });


        }




        public async Task<IActionResult> Create()
        {
            await LoadCategoriesAsync();
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(Book model, List<IFormFile> Images)
        {
            model.Category = await _context.Categories.FindAsync(model.CategoryID);

            if (model.Category == null)
            {
                ModelState.AddModelError("Category", "Категория не найдена.");
            }

            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value.Errors.Count > 0)
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
                    );

                return Json(new { success = false, errors });
            }

            model.DateInput = DateTime.Now;

            _context.Books.Add(model);
            await _context.SaveChangesAsync();

            // Папка для изображений: wwwroot/media/ContentPhoto/UploadImages/book_{BookID}
            var folderName = $"book_{model.BookID}";
            var relativeFolderPath = Path.Combine("media", "ContentPhoto", "UploadImages", folderName);
            var absoluteFolderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", relativeFolderPath);

            Directory.CreateDirectory(absoluteFolderPath);

            if (Images != null && Images.Count > 0)
            {
                foreach (var image in Images)
                {
                    var fileName = Guid.NewGuid().ToString() + Path.GetExtension(image.FileName);
                    var fullPath = Path.Combine(absoluteFolderPath, fileName);

                    using (var stream = new FileStream(fullPath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var photo = new PhotoBook
                    {
                        BookID = model.BookID,
                        // Сохраняем путь относительно media/ContentPhoto
                        PhotoLink = Path.Combine("ContentPhoto", "UploadImages", folderName, fileName).Replace("\\", "/"),
                        DateInput = DateTime.Now
                    };

                    _context.PhotoBooks.Add(photo);
                }

                await _context.SaveChangesAsync();
            }
            else
            {
                // Если нет изображений — сохраняем путь к заглушке
                var photo = new PhotoBook
                {
                    BookID = model.BookID,
                    PhotoLink = "ContentPhoto/default/no-image.jpg",
                    DateInput = DateTime.Now
                };
                _context.PhotoBooks.Add(photo);
                await _context.SaveChangesAsync();
            }

            return Json(new { success = true, message = "Книга успешно добавлена!" });
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var book = await _context.Books
                .Include(b => b.Photos)
                .FirstOrDefaultAsync(b => b.BookID == id);

            if (book == null)
            {
                return Json(new { success = false, message = "Книга не найдена." });
            }

            // Путь к папке с фото книги
            var bookFolderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "media", "ContentPhoto", "UploadImages", $"book_{id}");

            // Удаляем папку, если она существует
            if (Directory.Exists(bookFolderPath))
            {
                Directory.Delete(bookFolderPath, true); // true — удалить всё содержимое
            }

            // Удаляем записи фотографий из базы
            _context.PhotoBooks.RemoveRange(book.Photos);

            // Удаляем книгу
            _context.Books.Remove(book);

            await _context.SaveChangesAsync();

            return Json(new { success = true });
        }

        [HttpPost]
        public async Task<IActionResult> DeletePhoto(int id)
        {
            var photo = await _context.PhotoBooks.FindAsync(id);
            if (photo == null)
                return Json(new { success = false, message = "Фото не найдено" });

            var path = Path.Combine(_env.WebRootPath, "media", photo.PhotoLink);

            if (System.IO.File.Exists(path))
                System.IO.File.Delete(path);

            _context.PhotoBooks.Remove(photo);
            await _context.SaveChangesAsync();

            return Json(new { success = true });
        }




    }
}
