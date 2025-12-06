using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Database;
using Bella.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Bella.Services.Services
{
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductUpsertRequest, ProductUpsertRequest>, IProductService
    {
        private static MLContext _mlContext = null;
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public ProductService(BellaDbContext context, IMapper mapper) : base(context, mapper)
        {
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }
                }
            }
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(p => p.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            }

            if (search.CategoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == search.CategoryId.Value);
            }

            if (search.ManufacturerId.HasValue)
            {
                query = query.Where(p => p.ManufacturerId == search.ManufacturerId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(p => p.Name.Contains(search.FTS));
            }

            return query
                .Include(p => p.Category)
                .Include(p => p.Manufacturer);
        }

        protected override ProductResponse MapToResponse(Product entity)
        {
            var response = new ProductResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                Price = entity.Price,
                Picture = entity.Picture,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                CategoryId = entity.CategoryId,
                CategoryName = entity.Category?.Name ?? string.Empty,
                ManufacturerId = entity.ManufacturerId,
                ManufacturerName = entity.Manufacturer?.Name ?? string.Empty
            };

            return response;
        }

        protected override async Task BeforeInsert(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name && p.Id != entity.Id))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }
        }

        // Train a simple recommender using Matrix Factorization on (User, Product) implicit feedback
        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {

            
            lock (_mlLock)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();
                }
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<BellaDbContext>();

                // Build implicit feedback dataset from order items (products users have bought)
                var positiveEntries = db.OrderItems
                    .Include(oi => oi.Order)
                    .Where(oi => oi.Order.IsActive)
                    .GroupBy(oi => new { oi.Order.UserId, oi.ProductId })
                    .Select(g => new FeedbackEntry
                    {
                        UserId = (uint)g.Key.UserId,
                        ProductId = (uint)g.Key.ProductId,
                        Label = (float)g.Sum(oi => oi.Quantity) // Weight by total quantity purchased
                    })
                    .ToList();

                if (!positiveEntries.Any())
                {
                    _model = null;
                    return;
                }

                // Normalize labels to be between 0 and 1 for better training
                var maxQuantity = positiveEntries.Max(e => e.Label);
                if (maxQuantity > 0)
                {
                    positiveEntries = positiveEntries.Select(e => new FeedbackEntry
                    {
                        UserId = e.UserId,
                        ProductId = e.ProductId,
                        Label = Math.Min(1.0f, e.Label / maxQuantity)
                    }).ToList();
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.ProductId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        public List<ProductResponse> RecommendProductsForUser(int userId)
        {
            if (_model == null)
            {
                // Fallback: recommend using heuristic approach
                return RecommendHeuristic(userId, count: 2);
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, ProductScorePrediction>(_model);

            // Get products user has already purchased
            var purchasedProductIds = _context.OrderItems
                .Include(oi => oi.Order)
                .Where(oi => oi.Order.UserId == userId && oi.Order.IsActive)
                .Select(oi => oi.ProductId)
                .Distinct()
                .ToHashSet();

            // Get manufacturers and categories from user's previous purchases
            var purchasedProducts = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Manufacturer)
                .Where(p => purchasedProductIds.Contains(p.Id))
                .ToList();

            var preferredManufacturerIds = purchasedProducts
                .Select(p => p.ManufacturerId)
                .Distinct()
                .ToHashSet();

            var preferredCategoryIds = purchasedProducts
                .Select(p => p.CategoryId)
                .Distinct()
                .ToHashSet();

            // Get candidate products (active, not purchased)
            var candidateProducts = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Manufacturer)
                .Where(p => p.IsActive && !purchasedProductIds.Contains(p.Id))
                .ToList();

            if (!candidateProducts.Any())
            {
                // If all products have been purchased, include them but still prioritize preferred categories/manufacturers
                candidateProducts = _context.Products
                    .Include(p => p.Category)
                    .Include(p => p.Manufacturer)
                    .Where(p => p.IsActive)
                    .ToList();
            }

            if (!candidateProducts.Any())
            {
                return RecommendHeuristic(userId, count: 2);
            }

            // Score all candidates and apply category/manufacturer boost
            var scored = candidateProducts
                .Select(p => new
                {
                    Product = p,
                    MLScore = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        ProductId = (uint)p.Id
                    }).Score,
                    ManufacturerBoost = preferredManufacturerIds.Contains(p.ManufacturerId) ? 0.3f : 0f,
                    CategoryBoost = preferredCategoryIds.Contains(p.CategoryId) ? 0.3f : 0f
                })
                .Select(x => new
                {
                    x.Product,
                    FinalScore = x.MLScore + x.ManufacturerBoost + x.CategoryBoost
                })
                .OrderByDescending(x => x.FinalScore)
                .Take(2)
                .Select(x => MapToResponse(x.Product))
                .ToList();

            return scored;
        }

        private List<ProductResponse> RecommendHeuristic(int userId, int count = 2)
        {
            // Get products the user has purchased
            var purchasedProductIds = _context.OrderItems
                .Include(oi => oi.Order)
                .Where(oi => oi.Order.UserId == userId && oi.Order.IsActive)
                .Select(oi => oi.ProductId)
                .Distinct()
                .ToHashSet();

            // Get manufacturers and categories from purchased products
            var purchasedProducts = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Manufacturer)
                .Where(p => purchasedProductIds.Contains(p.Id))
                .ToList();

            var preferredManufacturerIds = purchasedProducts
                .Select(p => p.ManufacturerId)
                .Distinct()
                .ToList();

            var preferredCategoryIds = purchasedProducts
                .Select(p => p.CategoryId)
                .Distinct()
                .ToList();

            // If user has no purchases, return random active products
            if (!preferredManufacturerIds.Any() && !preferredCategoryIds.Any())
            {
                var activeProducts = _context.Products
                    .Include(p => p.Category)
                    .Include(p => p.Manufacturer)
                    .Where(p => p.IsActive)
                    .ToList();

                if (!activeProducts.Any())
                    throw new InvalidOperationException("No products available for recommendation.");

                var random = new Random();
                return activeProducts
                    .OrderBy(x => random.Next())
                    .Take(count)
                    .Select(p => MapToResponse(p))
                    .ToList();
            }

            // Prioritize products from preferred manufacturers and categories
            var candidateProducts = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Manufacturer)
                .Where(p => p.IsActive && 
                    (preferredManufacturerIds.Contains(p.ManufacturerId) || 
                     preferredCategoryIds.Contains(p.CategoryId)))
                .ToList();

            // Filter out already purchased products
            var newCandidates = candidateProducts
                .Where(p => !purchasedProductIds.Contains(p.Id))
                .ToList();

            // If no new products in preferred categories/manufacturers, include all active products
            if (!newCandidates.Any())
            {
                newCandidates = _context.Products
                    .Include(p => p.Category)
                    .Include(p => p.Manufacturer)
                    .Where(p => p.IsActive)
                    .ToList();
            }

            if (!newCandidates.Any())
                throw new InvalidOperationException("No products available for recommendation.");

            // Prioritize products matching both manufacturer and category
            var recommendations = newCandidates
                .OrderByDescending(p => 
                    (preferredManufacturerIds.Contains(p.ManufacturerId) ? 2 : 0) +
                    (preferredCategoryIds.Contains(p.CategoryId) ? 2 : 0))
                .ThenBy(x => Guid.NewGuid()) // Add some randomness for variety
                .Take(count)
                .Select(p => MapToResponse(p))
                .ToList();

            return recommendations;
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint ProductId { get; set; }
            public float Label { get; set; }
        }

        private class ProductScorePrediction
        {
            public float Score { get; set; }
        }
    }
}
