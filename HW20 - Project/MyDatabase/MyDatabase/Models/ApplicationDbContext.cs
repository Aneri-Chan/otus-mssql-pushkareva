using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MyDatabase.Models;

namespace MyDatabase.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        // Конструктор контекста
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Таблицы (DbSet)
        public DbSet<Book> Books { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<PhotoBook> PhotoBooks { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<CartItem> CartItems { get; set; } 
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }

        // Identity таблицы
        public DbSet<IdentityRole> Roles { get; set; }
        public DbSet<IdentityUserRole<string>> UserRoles { get; set; }

        // Конфигурация таблиц
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Настройка для цены книги: 18 знаков, 2 после запятой
            modelBuilder.Entity<Book>()
                .Property(b => b.Price)
                .HasPrecision(18, 2);

            // Если нужно — настрой параметры заказа
            modelBuilder.Entity<Order>()
                .Property(o => o.TotalAmount)
                .HasPrecision(18, 2);

            modelBuilder.Entity<OrderDetail>()
                .Property(od => od.PricePerUnit)
                .HasPrecision(18, 2);

            // Можно настроить ключи/связи если нужно вручную, например:
            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Order)
                .WithMany(o => o.OrderDetails)
                .HasForeignKey(od => od.OrderID);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Book)
                .WithMany()
                .HasForeignKey(od => od.BookID);
        }
    }
}
