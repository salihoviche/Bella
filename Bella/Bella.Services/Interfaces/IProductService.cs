using Bella.Model.Requests;
using Bella.Model.Responses;
using Bella.Model.SearchObjects;
using System.Collections.Generic;

namespace Bella.Services.Interfaces
{
    public interface IProductService : ICRUDService<ProductResponse, ProductSearchObject, ProductUpsertRequest, ProductUpsertRequest>
    {
        List<ProductResponse> RecommendProductsForUser(int userId);
    }
}
