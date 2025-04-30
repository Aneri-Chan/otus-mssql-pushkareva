using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyDatabase.Data;
using MyDatabase.Models;

public class OrderService
{
    private readonly string _connectionString;
    private readonly ApplicationDbContext _context;

    public OrderService(IConfiguration configuration, ApplicationDbContext context)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection");
        _context = context;
    }

    public int CreateOrder(int customerId, List<(int BookID, int Quantity)> orderItems)
    {
        using (var connection = new SqlConnection(_connectionString))
        {
            var command = new SqlCommand("CreateOrder", connection);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.AddWithValue("@CustomerID", customerId);
            command.Parameters.AddWithValue("@OrderStatus", "В обработке");

            var orderDetails = new DataTable();
            orderDetails.Columns.Add("BookID", typeof(int));
            orderDetails.Columns.Add("Quantity", typeof(int));

            foreach (var item in orderItems)
            {
                orderDetails.Rows.Add(item.BookID, item.Quantity);
            }

            var detailsParam = command.Parameters.AddWithValue("@OrderDetails", orderDetails);
            detailsParam.SqlDbType = SqlDbType.Structured;
            detailsParam.TypeName = "dbo.OrderDetailsType";

            var orderIdParam = new SqlParameter("@NewOrderID", SqlDbType.Int)
            {
                Direction = ParameterDirection.Output
            };
            command.Parameters.Add(orderIdParam);

            connection.Open();
            command.ExecuteNonQuery();

            return (int)orderIdParam.Value;
        }
    }

    public async Task<int> CreateOrderFromCartAsync(string userName)
    {
        using (var connection = new SqlConnection(_connectionString))
        {
            await connection.OpenAsync();

            // Получаем Customer по Email (или UserName)
            var customer = await _context.Customers.FirstOrDefaultAsync(c => c.Email == userName);
            if (customer == null)
                throw new Exception("Пользователь не найден.");

            var cartItems = await _context.CartItems
                .Where(c => c.CustomerID == customer.CustomerID)
                .ToListAsync();

            if (!cartItems.Any())
                throw new Exception("Корзина пуста.");

            using (var command = new SqlCommand("CreateOrder", connection))
            {
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@CustomerID", customer.CustomerID);
                command.Parameters.AddWithValue("@OrderStatus", "Новый");

                var table = new DataTable();
                table.Columns.Add("BookID", typeof(int));
                table.Columns.Add("Quantity", typeof(int));

                foreach (var item in cartItems)
                {
                    table.Rows.Add(item.BookID, item.Quantity);
                }

                var tvpParam = command.Parameters.AddWithValue("@OrderDetails", table);
                tvpParam.SqlDbType = SqlDbType.Structured;
                tvpParam.TypeName = "dbo.OrderDetailsType";

                var outputParam = new SqlParameter("@NewOrderID", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                command.Parameters.Add(outputParam);

                await command.ExecuteNonQueryAsync();

                // Очистка корзины после оформления заказа
                _context.CartItems.RemoveRange(cartItems);
                await _context.SaveChangesAsync();

                return (int)outputParam.Value;
            }
        }
    }

}
