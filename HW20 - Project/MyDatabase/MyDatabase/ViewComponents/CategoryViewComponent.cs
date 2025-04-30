using Microsoft.AspNetCore.Mvc;
using MyDatabase.Data;  // Пространство имен для ApplicationDbContext


public class CategoryViewComponent : ViewComponent
{
    private readonly ApplicationDbContext _context;

    public CategoryViewComponent(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var categories = _context.Categories.ToList();
        return View(categories);
    }
}
