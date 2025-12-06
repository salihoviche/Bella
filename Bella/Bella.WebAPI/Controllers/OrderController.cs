using Bella.Model.Requests;
using Bella.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Bella.Model.SearchObjects;
using Bella.Services.Interfaces;

namespace Bella.WebAPI.Controllers
{
    public class OrderController : BaseCRUDController<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService service) : base(service)
        {
            _orderService = service;
        }

        [HttpPost("user/{userId}/create-from-cart")]
        public async Task<ActionResult<OrderResponse>> CreateOrderFromCart(int userId)
        {
            try
            {
                var order = await _orderService.CreateOrderFromCartAsync(userId);
                return Ok(order);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<OrderResponse>>> GetOrdersByUser(int userId)
        {
            var orders = await _orderService.GetOrdersByUserAsync(userId);
            return Ok(orders);
        }
    }
}
