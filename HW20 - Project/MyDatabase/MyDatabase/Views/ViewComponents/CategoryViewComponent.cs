using Microsoft.AspNetCore.Mvc;
using MyDatabase.Data;
using System.Linq;

namespace MyDatabase.ViewComponents
{
    public class CategoryMenuViewComponent : ViewComponent
    {
        private readonly ApplicationDbContext _context;

        public CategoryMenuViewComponent(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            var categories = _context.Categories.ToList();

            if (categories == null || categories.Count == 0)
            {
                Console.WriteLine("❌ Категории не найдены");
                return Content("Категории не найдены");
            }

            return View("CategoryMenu", categories);
        }
    }
}

