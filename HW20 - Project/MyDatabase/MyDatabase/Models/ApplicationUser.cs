using Microsoft.AspNetCore.Identity;

public class ApplicationUser : IdentityUser
{
    public string CustomerName { get; set; }
}
