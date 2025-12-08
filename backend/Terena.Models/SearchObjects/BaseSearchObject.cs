namespace Terena.Models.SearchObjects;

public class BaseSearchObject
{
    public int? Page { get; set; }
    public int? PageSize { get; set; }
    public string? IncludeTables { get; set; }
    public string? OrderBy { get; set; }
    public string? SortDirection { get; set; }
    public bool? IsDeleted { get; set; }
}
