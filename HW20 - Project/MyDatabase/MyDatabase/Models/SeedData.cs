using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MyDatabase.Data;
using MyDatabase.Models;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace MyDatabase.Data
{
    public static class SeedData
    {
        public static async Task Initialize(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var configuration = scope.ServiceProvider.GetRequiredService<IConfiguration>();

            string adminEmail = configuration["AdminUser:Email"];
            string adminPassword = configuration["AdminUser:Password"];

            if (string.IsNullOrEmpty(adminEmail) || string.IsNullOrEmpty(adminPassword))
                return;

            // 1. Создаём роли, если их нет
            var adminRole = await context.Roles.FirstOrDefaultAsync(r => r.Name == "Admin");
            if (adminRole == null)
            {
                adminRole = new IdentityRole
                {
                    Name = "Admin",
                    NormalizedName = "ADMIN"
                };
                context.Roles.Add(adminRole);
            }

            var userRole = await context.Roles.FirstOrDefaultAsync(r => r.Name == "User");
            if (userRole == null)
            {
                userRole = new IdentityRole
                {
                    Name = "User",
                    NormalizedName = "USER"
                };
                context.Roles.Add(userRole);
            }

            await context.SaveChangesAsync();

            // 2. Создаём администратора, если его нет
            var adminUser = await context.Users.FirstOrDefaultAsync(u => u.Email == adminEmail);
            if (adminUser == null)
            {
                var hasher = new PasswordHasher<ApplicationUser>();
                adminUser = new ApplicationUser
                {
                    UserName = adminEmail,
                    NormalizedUserName = adminEmail.ToUpper(),
                    Email = adminEmail,
                    NormalizedEmail = adminEmail.ToUpper(),
                    EmailConfirmed = true,
                    CustomerName = "Администратор"
                };
                adminUser.PasswordHash = hasher.HashPassword(adminUser, adminPassword);

                context.Users.Add(adminUser);
                await context.SaveChangesAsync();
            }

            // 3. Присваиваем администратору роль Admin, если ещё нет
            var hasRole = await context.UserRoles
                .AnyAsync(ur => ur.UserId == adminUser.Id && ur.RoleId == adminRole.Id);
            if (!hasRole)
            {
                context.UserRoles.Add(new IdentityUserRole<string>
                {
                    UserId = adminUser.Id,
                    RoleId = adminRole.Id
                });
                await context.SaveChangesAsync();
            }
        }
    }
}
