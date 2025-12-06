using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Bella.WebAPI.Controllers
{
    public class ProductController : BaseCRUDController<ProductResponse, ProductSearchObject, ProductUpsertRequest, ProductUpsertRequest>
    {
        private readonly IProductService _productService;

        public ProductController(IProductService service) : base(service)
        {
            _productService = service;
        }

        /// <summary>
        /// Get recommended products for a specific user based on their purchase history
        /// </summary>
        /// <param name="userId">The ID of the user to get recommendations for</param>
        /// <returns>List of 2 recommended products</returns>
        [HttpGet("recommend/{userId}")]
        public ActionResult<List<ProductResponse>> GetRecommendations(int userId)
        {
            try
            {
                var recommendations = _productService.RecommendProductsForUser(userId);
                return Ok(recommendations);
            }
            catch (System.InvalidOperationException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (System.Exception)
            {
                return StatusCode(500, new { message = "An error occurred while generating recommendations." });
            }
        }
    }
}
