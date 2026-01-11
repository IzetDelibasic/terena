using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Terena.API.Controllers.BaseControllers;
using Terena.Models.DTOs;
using Terena.Models.Enums;
using Terena.Models.Requests;
using Terena.Models.SearchObjects;
using Terena.Services.Interfaces;

namespace Terena.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : BaseCRUDController<UserModel, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;

        public UserController(IUserService service) : base(service)
        {
            _userService = service;
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserModel>> Login([FromBody] LoginRequest request)
        {
            try
            {
                var result = await _userService.LoginAsync(request.Username, request.Password);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("register")]
        public ActionResult<UserModel> Register([FromBody] UserInsertRequest request)
        {
            try
            {
                request.Role = UserRole.Customer; 
                var result = _userService.Insert(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/block")]
        public async Task<ActionResult<UserModel>> BlockUser(int id, [FromBody] BlockUserRequest request)
        {
            var result = await _userService.BlockUserAsync(id, request.Reason);
            return Ok(result);
        }

        [HttpPost("{id}/unblock")]
        public async Task<ActionResult<UserModel>> UnblockUser(int id)
        {
            var result = await _userService.UnblockUserAsync(id);
            return Ok(result);
        }

        [HttpGet("{id}/statistics")]
        public async Task<ActionResult<UserStatistics>> GetUserStatistics(int id)
        {
            var result = await _userService.GetUserStatistics(id);
            return Ok(result);
        }
    }
}
