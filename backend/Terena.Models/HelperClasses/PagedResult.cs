namespace Terena.Models.HelperClasses;

public class PagedResult<T>
{
    public int? Count { get; set; }
    public IList<T> ResultList { get; set; } = new List<T>();
}
