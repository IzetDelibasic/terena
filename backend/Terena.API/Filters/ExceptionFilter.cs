using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Terena.Models.Exceptions;

namespace Terena.API.Filters;

public class ExceptionFilter : ExceptionFilterAttribute
{
    public override void OnException(ExceptionContext context)
    {
        if (context.Exception is UserException)
        {
            context.ModelState.AddModelError("userException", context.Exception.Message);
            context.HttpContext.Response.StatusCode = 400;
        }
        else
        {
            context.ModelState.AddModelError("generalException", "An error occurred!");
            context.HttpContext.Response.StatusCode = 500;
        }

        var list = context.ModelState.Where(x => x.Value?.Errors.Count > 0)
            .ToDictionary(
                x => x.Key,
                x => x.Value?.Errors.Select(e => e.ErrorMessage).ToArray()
            );

        context.Result = new JsonResult(new { errors = list });
        base.OnException(context);
    }
}
