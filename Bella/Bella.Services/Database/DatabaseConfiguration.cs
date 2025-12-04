using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Bella.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<BellaDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseBella(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<BellaDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}