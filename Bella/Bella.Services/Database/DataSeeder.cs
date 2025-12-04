using Bella.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace Bella.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 60 123 456";
        

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            
            // For dynamic appointments: Use a placeholder date that will be updated via SQL in migration
            // The SQL will set AppointmentDate to today with specific times (16:00, 18:00, 20:00, 21:00)
            // This placeholder will be replaced when the migration executes
            var dynamicAppointmentDate = new DateTime(2099, 1, 1, 0, 0, 0, DateTimeKind.Utc); // Placeholder

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role
                {
                    Id = 1,
                    Name = "Administrator",
                    Description = "System administrator with full access",
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new Role
                {
                    Id = 2,
                    Name = "User",
                    Description = "Regular user role",
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new Role
                {
                    Id = 3,
                    Name = "Hairdresser",
                    Description = "Hairdresser role",
                    CreatedAt = fixedDate,
                    IsActive = true
                }
            );

            // Seed Users
            // Note: All passwords are set to "test" for seeded users
            // Using deterministic salts based on usernames to ensure consistent seed data
            const string defaultPassword = "test";

            var adminSalt = PasswordGenerator.GenerateDeterministicSalt("admin");
            var adminHash = PasswordGenerator.GenerateHash(defaultPassword, adminSalt);

            var userSalt = PasswordGenerator.GenerateDeterministicSalt("user");
            var userHash = PasswordGenerator.GenerateHash(defaultPassword, userSalt);

            var admin2Salt = PasswordGenerator.GenerateDeterministicSalt("admin2");
            var admin2Hash = PasswordGenerator.GenerateHash(defaultPassword, admin2Salt);

            var hairdresserSalt = PasswordGenerator.GenerateDeterministicSalt("hairdresser");
            var hairdresserHash = PasswordGenerator.GenerateHash(defaultPassword, hairdresserSalt);

            var hairdresser2Salt = PasswordGenerator.GenerateDeterministicSalt("hairdresser2");
            var hairdresser2Hash = PasswordGenerator.GenerateHash(defaultPassword, hairdresser2Salt);

            var user2Salt = PasswordGenerator.GenerateDeterministicSalt("user2");
            var user2Hash = PasswordGenerator.GenerateHash(defaultPassword, user2Salt);

            var user3Salt = PasswordGenerator.GenerateDeterministicSalt("user3");
            var user3Hash = PasswordGenerator.GenerateHash(defaultPassword, user3Salt);

            var user4Salt = PasswordGenerator.GenerateDeterministicSalt("user4");
            var user4Hash = PasswordGenerator.GenerateHash(defaultPassword, user4Salt);

            var user5Salt = PasswordGenerator.GenerateDeterministicSalt("user5");
            var user5Hash = PasswordGenerator.GenerateHash(defaultPassword, user5Salt);

            var user6Salt = PasswordGenerator.GenerateDeterministicSalt("user6");
            var user6Hash = PasswordGenerator.GenerateHash(defaultPassword, user6Salt);



            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = "denis@gmail.com",
                    Username = "admin",
                    PasswordHash = adminHash,
                    PasswordSalt = adminSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "denis.png")
                },
                new User
                {
                    Id = 2,
                    FirstName = "Amel",
                    LastName = "Musić",
                    Email = "bella.salon.example@gmail.com",
                    Username = "user",
                    PasswordHash = userHash,
                    PasswordSalt = userSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")
                },
                new User
                {
                    Id = 3,
                    FirstName = "Adil",
                    LastName = "Joldić",
                    Email = "adil@gmail.com",
                    Username = "admin2",
                    PasswordHash = admin2Hash,
                    PasswordSalt = admin2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1,
                    CityId = 5,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User
                {
                    Id = 4,
                    FirstName = "Emina",
                    LastName = "Salihović",
                    Email = "vitalsphere.receiver@gmail.com",
                    Username = "hairdresser",
                    PasswordHash = hairdresserHash,
                    PasswordSalt = hairdresserSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 1, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "emina.png")
                },
                new User {
                    Id = 5,
                    FirstName = "Elmir",
                    LastName = "Babović",
                    Email = "elmir@gmail.com",
                    Username = "hairdresser2",
                    PasswordHash = hairdresser2Hash,
                    PasswordSalt = hairdresser2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1, // Sarajevo
                    // Picture = ImageConversion.ConvertImageToByteArray("Assets", "elmir.png")
                },
                new User {
                    Id = 6,
                    FirstName = "Jasmin",
                    LastName = "Azemović",
                    Email = "jasmin@gmail.com",
                    Username = "user2",
                    PasswordHash = user2Hash,
                    PasswordSalt = user2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1, // Sarajevo
                    // Picture = ImageConversion.ConvertImageToByteArray("Assets", "jasmin.png")
                },
             new User {
    Id = 7,
    FirstName = "Adnan",
    LastName = "Hadžić",
    Email = "adnan.hadzic@gmail.com",
    Username = "user3",
    PasswordHash = user3Hash,
    PasswordSalt = user3Salt,
    IsActive = true,
    CreatedAt = fixedDate,
    PhoneNumber = DefaultPhoneNumber,
    GenderId = 1, // Male
    CityId = 2, // Banja Luka
},
new User {
    Id = 8,
    FirstName = "Lejla",
    LastName = "Selimović",
    Email = "lejla.selimovic@gmail.com",
    Username = "user4",
    PasswordHash = user4Hash,
    PasswordSalt = user4Salt,
    IsActive = true,
    CreatedAt = fixedDate,
    PhoneNumber = DefaultPhoneNumber,
    GenderId = 2, // Female
    CityId = 3, // Tuzla
},
new User {
    Id = 9,
    FirstName = "Tarik",
    LastName = "Husić",
    Email = "tarik.husic@gmail.com",
    Username = "user5",
    PasswordHash = user5Hash,
    PasswordSalt = user5Salt,
    IsActive = true,
    CreatedAt = fixedDate,
    PhoneNumber = DefaultPhoneNumber,
    GenderId = 1, // Male
    CityId = 4, // Zenica
},
new User {
    Id = 10,
    FirstName = "Amila",
    LastName = "Omerović",
    Email = "amila.omerovic@gmail.com",
    Username = "user6",
    PasswordHash = user6Hash,
    PasswordSalt = user6Salt,
    IsActive = true,
    CreatedAt = fixedDate,
    PhoneNumber = DefaultPhoneNumber,
    GenderId = 2, // Female
    CityId = 5, // Mostar
}
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate },
                new UserRole { Id = 2, UserId = 2, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 3, UserId = 3, RoleId = 1, DateAssigned = fixedDate },
                new UserRole { Id = 4, UserId = 4, RoleId = 3, DateAssigned = fixedDate },
                new UserRole { Id = 5, UserId = 5, RoleId = 3, DateAssigned = fixedDate },
                new UserRole { Id = 6, UserId = 6, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 7, UserId = 7, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 8, UserId = 8, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 9, UserId = 9, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 10, UserId = 10, RoleId = 2, DateAssigned = fixedDate }
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bijeljina" },
                new City { Id = 7, Name = "Prijedor" },
                new City { Id = 8, Name = "Brčko" },
                new City { Id = 9, Name = "Doboj" },
                new City { Id = 10, Name = "Zvornik" },
                new City { Id = 11, Name = "Trebinje" },
                new City { Id = 12, Name = "Bihać" },
                new City { Id = 13, Name = "Travnik" },
                new City { Id = 14, Name = "Gračanica" },
                new City { Id = 15, Name = "Gradačac" },
                new City { Id = 16, Name = "Cazin" },
                new City { Id = 17, Name = "Lukavac" },
                new City { Id = 18, Name = "Široki Brijeg" },
                new City { Id = 19, Name = "Posušje" },
                new City { Id = 20, Name = "Bugojno" },
                new City { Id = 21, Name = "Konjic" },
                new City { Id = 22, Name = "Goražde" },
                new City { Id = 23, Name = "Visoko" },
                new City { Id = 24, Name = "Kakanj" },
                new City { Id = 25, Name = "Sanski Most" },
                new City { Id = 26, Name = "Čapljina" },
                new City { Id = 27, Name = "Neum" },
                new City { Id = 28, Name = "Livno" },
                new City { Id = 29, Name = "Jajce" },
                new City { Id = 30, Name = "Modriča" },
                new City { Id = 31, Name = "Bosanska Krupa" },
                new City { Id = 32, Name = "Stolac" },
                new City { Id = 33, Name = "Velika Kladuša" },
                new City { Id = 34, Name = "Kreševo" },
                new City { Id = 35, Name = "Tešanj" },
                new City { Id = 36, Name = "Kalesija" },
                new City { Id = 37, Name = "Foča" },
                new City { Id = 38, Name = "Srebrenik" },
                new City { Id = 39, Name = "Mrkonjić Grad" },
                new City { Id = 40, Name = "Čelinac" },
                new City { Id = 41, Name = "Kupres" }
            );

        // Seed Lengths
        modelBuilder.Entity<Length>().HasData(
            new Length { Id = 1, Name = "None", Image = null },
            new Length { Id = 2, Name = "Short", Image = null },
            new Length { Id = 3, Name = "Long", Image = null }
        );

        // Seed Categories
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Shampoo", Description = "Shampoo is a product that is used to clean the hair.", IsActive = true, CreatedAt = fixedDate },
            new Category { Id = 2, Name = "Serums & Oils", Description = "Serums & Oils are products that are used to nourish the hair.", IsActive = true, CreatedAt = fixedDate },
            new Category { Id = 3, Name = "Hair Gels", Description = "Hair Gels are products that are used to style the hair.", IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Manufacturers
        modelBuilder.Entity<Manufacturer>().HasData(
            new Manufacturer { Id = 1, Name = "Head & Shoulders", Description = "Head & Shoulders is a globally recognized brand specializing in anti-dandruff shampoos and conditioners, known for clinically proven formulas to fight scalp issues and maintain healthy hair.", IsActive = true, CreatedAt = fixedDate },
            new Manufacturer { Id = 2, Name = "Pantene", Description = "Pantene, a brand by Procter & Gamble, offers a wide range of hair care products including shampoos, conditioners, and treatments, known for its Pro-V formula that strengthens and nourishes hair.", IsActive = true, CreatedAt = fixedDate },
            new Manufacturer { Id = 3, Name = "L'Oréal", Description = "L'Oréal is a world-leading beauty and personal care brand, offering professional hair care, coloring, and   styling products used in salons globally.", IsActive = true, CreatedAt = fixedDate },
            new Manufacturer { Id = 4, Name = "Kerastase", Description = "Kérastase, a luxury hair care brand under L'Oréal, provides high-end shampoos, conditioners, oils, and  treatments designed to address specific hair needs, used extensively in professional salons.", IsActive = true, CreatedAt = fixedDate },
            new Manufacturer { Id = 5, Name = "Schwarzkopf", Description = "Schwarzkopf Professional offers innovative hair care, styling, and coloring products for both consumers and salons, known for quality and performance in professional hair treatments.", IsActive = true, CreatedAt = fixedDate },
            new Manufacturer { Id = 6, Name = "American Crew", Description = "American Crew is a leading men's grooming brand, offering hair care, styling, and shaving products designed specifically for professional barber use and modern men's grooming needs.", IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Products
        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Anti-Dandruff", CategoryId = 1, ManufacturerId = 1, Price = 10, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product1.png"), IsActive = true, CreatedAt = fixedDate },
            new Product { Id = 2, Name = "Pro-V Classic Clean", CategoryId = 1, ManufacturerId = 2, Price = 12, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product2.png"), IsActive = true, CreatedAt = fixedDate },
            new Product { Id = 3, Name = "Mythic Oil", CategoryId = 2, ManufacturerId = 3, Price = 14, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product3.png"), IsActive = true, CreatedAt = fixedDate },
            new Product { Id = 4, Name = "Elixir Ultime", CategoryId = 2, ManufacturerId = 4, Price = 16, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product4.png"), IsActive = true, CreatedAt = fixedDate },
            new Product { Id = 5, Name = "Got2b Ultra Glued", CategoryId = 3, ManufacturerId = 5, Price = 12, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product5.png"), IsActive = true, CreatedAt = fixedDate },
            new Product { Id = 6, Name = "Firm Hold", CategoryId = 3, ManufacturerId = 6, Price = 15, Picture = ImageConversion.ConvertImageToByteArray("Assets", "product6.png"), IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Orders
        // Order 1 for User 2 (regular user "user")
        // Order contains: 2x Anti-Dandruff (10 * 2 = 20) + 1x Pro-V Classic Clean (12 * 1 = 12) = Total: 32
        var order1Date = fixedDate;
        var order1IdSuffix = "001";
        var order1Number = $"ORD-{order1Date:yyyyMMddHHmmss}-{order1IdSuffix}";
        
        // Order 2 for User 6 (regular user "user2")
        // Order contains: 1x Mythic Oil (14 * 1 = 14) + 1x Elixir Ultime (16 * 1 = 16) + 1x Firm Hold (15 * 1 = 15) = Total: 45
        var order2Date = fixedDate;
        var order2IdSuffix = "002";
        var order2Number = $"ORD-{order2Date:yyyyMMddHHmmss}-{order2IdSuffix}";
        
        // Order 3 for User 2 (second order for "user")
        // Order contains: 1x Got2b Ultra Glued (12 * 1 = 12) + 1x Firm Hold (15 * 1 = 15) = Total: 27
        var order3Date = fixedDate;
        var order3IdSuffix = "003";
        var order3Number = $"ORD-{order3Date:yyyyMMddHHmmss}-{order3IdSuffix}";
        
        // Order 4 for User 6 (second order for "user2")
        // Order contains: 2x Anti-Dandruff (10 * 2 = 20) + 1x Pro-V Classic Clean (12 * 1 = 12) = Total: 32
        var order4Date = fixedDate;
        var order4IdSuffix = "004";
        var order4Number = $"ORD-{order4Date:yyyyMMddHHmmss}-{order4IdSuffix}";
        
        modelBuilder.Entity<Order>().HasData(
            new Order 
            { 
                Id = 1, 
                OrderNumber = order1Number,
                UserId = 2, // User "user"
                TotalAmount = 32, // 20 + 12
                CreatedAt = fixedDate, 
                IsActive = true 
            },
            new Order 
            { 
                Id = 2, 
                OrderNumber = order2Number,
                UserId = 6, // User "user2"
                TotalAmount = 45, // 14 + 16 + 15
                CreatedAt = fixedDate, 
                IsActive = true 
            },
            new Order 
            { 
                Id = 3, 
                OrderNumber = order3Number,
                UserId = 2, // User "user"
                TotalAmount = 27, // 12 + 15
                CreatedAt = fixedDate, 
                IsActive = true 
            },
            new Order 
            { 
                Id = 4, 
                OrderNumber = order4Number,
                UserId = 6, // User "user2"
                TotalAmount = 32, // 20 + 12
                CreatedAt = fixedDate, 
                IsActive = true 
            }
        );

        // Seed OrderItems
        // OrderItems for Order 1 (User 2)
        modelBuilder.Entity<OrderItem>().HasData(
            new OrderItem 
            { 
                Id = 1, 
                OrderId = 1, 
                ProductId = 1, // Anti-Dandruff
                Quantity = 2, 
                UnitPrice = 10, 
                TotalPrice = 20, // 10 * 2
                CreatedAt = fixedDate 
            },
            new OrderItem 
            { 
                Id = 2, 
                OrderId = 1, 
                ProductId = 2, // Pro-V Classic Clean
                Quantity = 1, 
                UnitPrice = 12, 
                TotalPrice = 12, // 12 * 1
                CreatedAt = fixedDate 
            },
            // OrderItems for Order 2 (User 6)
            new OrderItem 
            { 
                Id = 3, 
                OrderId = 2, 
                ProductId = 3, // Mythic Oil
                Quantity = 1, 
                UnitPrice = 14, 
                TotalPrice = 14, // 14 * 1
                CreatedAt = fixedDate 
            },
            new OrderItem 
            { 
                Id = 4, 
                OrderId = 2, 
                ProductId = 4, // Elixir Ultime
                Quantity = 1, 
                UnitPrice = 16, 
                TotalPrice = 16, // 16 * 1
                CreatedAt = fixedDate 
            },
            new OrderItem 
            { 
                Id = 5, 
                OrderId = 2, 
                ProductId = 6, // Firm Hold
                Quantity = 1, 
                UnitPrice = 15, 
                TotalPrice = 15, // 15 * 1
                CreatedAt = fixedDate 
            },
            // OrderItems for Order 3 (User 2 - second order)
            new OrderItem 
            { 
                Id = 6, 
                OrderId = 3, 
                ProductId = 5, // Got2b Ultra Glued
                Quantity = 1, 
                UnitPrice = 12, 
                TotalPrice = 12, // 12 * 1
                CreatedAt = fixedDate 
            },
            new OrderItem 
            { 
                Id = 7, 
                OrderId = 3, 
                ProductId = 6, // Firm Hold
                Quantity = 1, 
                UnitPrice = 15, 
                TotalPrice = 15, // 15 * 1
                CreatedAt = fixedDate 
            },
            // OrderItems for Order 4 (User 6 - second order)
            new OrderItem 
            { 
                Id = 8, 
                OrderId = 4, 
                ProductId = 1, // Anti-Dandruff
                Quantity = 2, 
                UnitPrice = 10, 
                TotalPrice = 20, // 10 * 2
                CreatedAt = fixedDate 
            },
            new OrderItem 
            { 
                Id = 9, 
                OrderId = 4, 
                ProductId = 2, // Pro-V Classic Clean
                Quantity = 1, 
                UnitPrice = 12, 
                TotalPrice = 12, // 12 * 1
                CreatedAt = fixedDate 
            }
        );

        // Seed Hairstyles
        modelBuilder.Entity<Hairstyle>().HasData(
            new Hairstyle { Id = 1, Name = "Clean Bald", Image = ImageConversion.ConvertImageToByteArray("Assets", "1.png"), Price = 10, IsActive = true, CreatedAt = fixedDate, LengthId = 1, GenderId = 1 },
            new Hairstyle { Id = 2, Name = "Clean Bald", Image = ImageConversion.ConvertImageToByteArray("Assets", "2.png"), Price = 10, IsActive = true, CreatedAt = fixedDate, LengthId = 1, GenderId = 2 },
            new Hairstyle { Id = 3, Name = "Curly Taper Fade", Image = ImageConversion.ConvertImageToByteArray("Assets", "3.png"), Price = 18, IsActive = true, CreatedAt = fixedDate, LengthId = 2, GenderId = 1 },
            new Hairstyle { Id = 4, Name = "Hard Part Undercut", Image = ImageConversion.ConvertImageToByteArray("Assets", "4.png"), Price = 16, IsActive = true, CreatedAt = fixedDate, LengthId = 2, GenderId = 1 },
            new Hairstyle { Id = 5, Name = "Textured Quiff", Image = ImageConversion.ConvertImageToByteArray("Assets", "5.png"), Price = 14, IsActive = true, CreatedAt = fixedDate, LengthId = 2, GenderId = 1 },
            new Hairstyle { Id = 6, Name = "Yuppie", Image = ImageConversion.ConvertImageToByteArray("Assets", "6.png"), Price = 16, IsActive = true, CreatedAt = fixedDate, LengthId = 3, GenderId = 1 },
            new Hairstyle { Id = 7, Name = "Man Bun Fade", Image = ImageConversion.ConvertImageToByteArray("Assets", "7.png"), Price = 18, IsActive = true, CreatedAt = fixedDate, LengthId = 3, GenderId = 1 },
            new Hairstyle { Id = 8, Name = "Bixie Cut", Image = ImageConversion.ConvertImageToByteArray("Assets", "8.png"), Price = 18, IsActive = true, CreatedAt = fixedDate, LengthId = 2, GenderId = 2 },
            new Hairstyle { Id = 9, Name = "Curly Taper", Image = ImageConversion.ConvertImageToByteArray("Assets", "9.png"), Price = 20, IsActive = true, CreatedAt = fixedDate, LengthId = 2, GenderId = 2 },
            new Hairstyle { Id = 10, Name = "Mid-Height Ponytail", Image = ImageConversion.ConvertImageToByteArray("Assets", "10.png"), Price = 18, IsActive = true, CreatedAt = fixedDate, LengthId = 3, GenderId = 2 },
            new Hairstyle { Id = 11, Name = "Messy Updo", Image = ImageConversion.ConvertImageToByteArray("Assets", "11.png"), Price = 16, IsActive = true, CreatedAt = fixedDate, LengthId = 3, GenderId = 2 },
            new Hairstyle { Id = 12, Name = "Shoulder-Length Bob", Image = ImageConversion.ConvertImageToByteArray("Assets", "12.png"), Price = 18, IsActive = true, CreatedAt = fixedDate, LengthId = 3, GenderId = 2 }
        );

        // Seed FacialHairs
        modelBuilder.Entity<FacialHair>().HasData(
            new FacialHair { Id = 1, Name = "Balbo Beard", Image = ImageConversion.ConvertImageToByteArray("Assets", "f1.png"), Price = 10, IsActive = true, CreatedAt = fixedDate   },
            new FacialHair { Id = 2, Name = "Boxed Goatee", Image = ImageConversion.ConvertImageToByteArray("Assets", "f2.png"), Price = 10, IsActive = true, CreatedAt = fixedDate },
            new FacialHair { Id = 3, Name = "Van Dyke Beard", Image = ImageConversion.ConvertImageToByteArray("Assets", "f3.png"), Price = 10, IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Dying Colors
        modelBuilder.Entity<Dying>().HasData(
            new Dying { Id = 1, Name = "Black", HexCode = "#000000", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 2, Name = "Dark Brown", HexCode = "#3D2817", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 3, Name = "Medium Brown", HexCode = "#6B4423", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 4, Name = "Light Brown", HexCode = "#A0826D", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 5, Name = "Blonde", HexCode = "#F5E6D3", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 6, Name = "Platinum Blonde", HexCode = "#E6E6FA", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 7, Name = "Red", HexCode = "#8B0000", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 8, Name = "Burgundy", HexCode = "#800020", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 9, Name = "Blue", HexCode = "#0000FF", IsActive = true, CreatedAt = fixedDate },
            new Dying { Id = 10, Name = "Purple", HexCode = "#800080", IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Statuses
        modelBuilder.Entity<Status>().HasData(
            new Status { Id = 1, Name = "Reserved", IsActive = true, CreatedAt = fixedDate },
            new Status { Id = 2, Name = "Cancelled", IsActive = true, CreatedAt = fixedDate },
            new Status { Id = 3, Name = "Completed", IsActive = true, CreatedAt = fixedDate }
        );

        // Seed Appointments (all using dynamicAppointmentDate - will be updated in migration)
        // User 2 (Amel) - Male, 2 appointments
        // Appointment 1: Hairstyle (Id=3, Curly Taper Fade, Price=18) + FacialHair (Id=1, Balbo Beard, Price=10) = 28
        modelBuilder.Entity<Appointment>().HasData(
            new Appointment 
            { 
                Id = 1, 
                UserId = 2, // Amel
                HairdresserId = 4, // Emina
                StatusId = 3, // Completed
                HairstyleId = 3, // Curly Taper Fade (Male)
                FacialHairId = 1, // Balbo Beard
                DyingId = null,
                FinalPrice = 28, // 18 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 2: Hairstyle (Id=4, Hard Part Undercut, Price=16) + Dying (Price=10) = 26
            new Appointment 
            { 
                Id = 2, 
                UserId = 2, // Amel
                HairdresserId = 5, // Elmir
                StatusId = 3, // Completed
                HairstyleId = 4, // Hard Part Undercut (Male)
                FacialHairId = null,
                DyingId = 1, // Black
                FinalPrice = 26, // 16 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // User 6 (Jasmin) - Male, 2 appointments
            // Appointment 3: Hairstyle (Id=6, Yuppie, Price=16) + FacialHair (Id=2, Boxed Goatee, Price=10) + Dying (Price=10) = 36
            new Appointment 
            { 
                Id = 3, 
                UserId = 6, // Jasmin
                HairdresserId = 4, // Emina
                StatusId = 3, // Completed
                HairstyleId = 6, // Yuppie (Male)
                FacialHairId = 2, // Boxed Goatee
                DyingId = 2, // Dark Brown
                FinalPrice = 36, // 16 + 10 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 4: Hairstyle (Id=7, Man Bun Fade, Price=18) = 18
            new Appointment 
            { 
                Id = 4, 
                UserId = 6, // Jasmin
                HairdresserId = 5, // Elmir
                StatusId = 3, // Completed
                HairstyleId = 7, // Man Bun Fade (Male)
                FacialHairId = null,
                DyingId = null,
                FinalPrice = 18, // 18
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
               new Appointment 
            { 
                Id = 5, 
                UserId = 2, // Amel
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 5, // Textured Quiff (Male, Price=14)
                FacialHairId = null,
                DyingId = null,
                FinalPrice = 14, // 14
                AppointmentDate = dynamicAppointmentDate, // Will be updated to today 16:00 via SQL
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 6: User 2 (Amel) with Hairdresser 5 (Elmir) at 18:00
            new Appointment 
            { 
                Id = 6, 
                UserId = 2, // Amel
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = null,
                FacialHairId = 3, // Van Dyke Beard (Price=10)
                DyingId = 3, // Medium Brown (Price=10)
                FinalPrice = 20, // 10 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated to today 18:00 via SQL
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 7: User 6 (Jasmin) with Hairdresser 4 (Emina) at 20:00
            new Appointment 
            { 
                Id = 7, 
                UserId = 6, // Jasmin
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 3, // Curly Taper Fade (Male, Price=18)
                FacialHairId = 1, // Balbo Beard (Price=10)
                DyingId = null,
                FinalPrice = 28, // 18 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated to today 20:00 via SQL
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 8: User 6 (Jasmin) with Hairdresser 5 (Elmir) at 21:00
            new Appointment 
            { 
                Id = 8, 
                UserId = 6, // Jasmin
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = 4, // Hard Part Undercut (Male, Price=16)
                FacialHairId = null,
                DyingId = 4, // Light Brown (Price=10)
                FinalPrice = 26, // 16 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated to today 21:00 via SQL
                CreatedAt = fixedDate,
                IsActive = true
            },
            // User 7 (Marko) - Male, 2 appointments
            // Appointment 9: Hairstyle (Id=5, Textured Quiff, Price=14) + FacialHair (Id=1, Balbo Beard, Price=10) = 24
            new Appointment 
            { 
                Id = 9, 
                UserId = 7, // Marko
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 5, // Textured Quiff (Male)
                FacialHairId = 1, // Balbo Beard
                DyingId = null,
                FinalPrice = 24, // 14 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 10: Hairstyle (Id=3, Curly Taper Fade, Price=18) + Dying (Price=10) = 28
            new Appointment 
            { 
                Id = 10, 
                UserId = 7, // Marko
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = 3, // Curly Taper Fade (Male)
                FacialHairId = null,
                DyingId = 5, // Blonde
                FinalPrice = 28, // 18 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // User 8 (Ana) - Female, 2 appointments
            // Appointment 11: Hairstyle (Id=8, Bixie Cut, Price=18) = 18
            new Appointment 
            { 
                Id = 11, 
                UserId = 8, // Ana
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 8, // Bixie Cut (Female)
                FacialHairId = null,
                DyingId = null,
                FinalPrice = 18, // 18
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 12: Hairstyle (Id=9, Curly Taper, Price=20) + Dying (Price=10) = 30
            new Appointment 
            { 
                Id = 12, 
                UserId = 8, // Ana
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = 9, // Curly Taper (Female)
                FacialHairId = null,
                DyingId = 6, // Platinum Blonde
                FinalPrice = 30, // 20 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // User 9 (Stefan) - Male, 2 appointments
            // Appointment 13: Hairstyle (Id=4, Hard Part Undercut, Price=16) + FacialHair (Id=3, Van Dyke Beard, Price=10) = 26
            new Appointment 
            { 
                Id = 13, 
                UserId = 9, // Stefan
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 4, // Hard Part Undercut (Male)
                FacialHairId = 3, // Van Dyke Beard
                DyingId = null,
                FinalPrice = 26, // 16 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 14: Hairstyle (Id=6, Yuppie, Price=16) + Dying (Price=10) = 26
            new Appointment 
            { 
                Id = 14, 
                UserId = 9, // Stefan
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = 6, // Yuppie (Male)
                FacialHairId = null,
                DyingId = 7, // Red
                FinalPrice = 26, // 16 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // User 10 (Sara) - Female, 2 appointments
            // Appointment 15: Hairstyle (Id=10, Mid-Height Ponytail, Price=18) = 18
            new Appointment 
            { 
                Id = 15, 
                UserId = 10, // Sara
                HairdresserId = 4, // Emina
                StatusId = 3, // Reserved
                HairstyleId = 10, // Mid-Height Ponytail (Female)
                FacialHairId = null,
                DyingId = null,
                FinalPrice = 18, // 18
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            },
            // Appointment 16: Hairstyle (Id=11, Messy Updo, Price=16) + Dying (Price=10) = 26
            new Appointment 
            { 
                Id = 16, 
                UserId = 10, // Sara
                HairdresserId = 5, // Elmir
                StatusId = 3, // Reserved
                HairstyleId = 11, // Messy Updo (Female)
                FacialHairId = null,
                DyingId = 8, // Burgundy
                FinalPrice = 26, // 16 + 10
                AppointmentDate = dynamicAppointmentDate, // Will be updated via SQL in migration
                CreatedAt = fixedDate,
                IsActive = true
            }
        );

        // Seed Reviews (one for each appointment)
        modelBuilder.Entity<Review>().HasData(
            // Review for Appointment 1 (User 2 - Amel)
            new Review 
            { 
                Id = 1, 
                UserId = 2, // Amel
                AppointmentId = 1,
                Rating = 5,
                Comment = "Excellent service! Emina did a great job with my haircut and beard styling.",
                CreatedAt = fixedDate.AddDays(1).AddHours(2),
                IsActive = true
            },
            // Review for Appointment 2 (User 2 - Amel)
            new Review 
            { 
                Id = 2, 
                UserId = 2, // Amel
                AppointmentId = 2,
                Rating = 4,
                Comment = "Good haircut and the dye job looks great. Very satisfied!",
                CreatedAt = fixedDate.AddDays(2).AddHours(2),
                IsActive = true
            },
            // Review for Appointment 3 (User 6 - Jasmin)
            new Review 
            { 
                Id = 3, 
                UserId = 6, // Jasmin
                AppointmentId = 3,
                Rating = 5,
                Comment = "Amazing work! The combination of haircut, beard, and dye looks fantastic. Highly recommend!",
                CreatedAt = fixedDate.AddDays(3).AddHours(2),
                IsActive = true
            },
            // Review for Appointment 4 (User 6 - Jasmin)
            new Review 
            { 
                Id = 4, 
                UserId = 6, // Jasmin
                AppointmentId = 4,
                Rating = 5,
                Comment = "Perfect haircut! Elmir is very professional and skilled.",
                CreatedAt = fixedDate.AddDays(4).AddHours(2),
                IsActive = true
            }
        );

  

    }
    }
} 