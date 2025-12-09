namespace Terena.Models.SearchObjects;

public class VenueSearchObject : BaseSearchObject
{
    public string? SearchTerm { get; set; }
    public string? SportType { get; set; }
    public string? Location { get; set; }
    public string? SurfaceType { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public bool? HasParking { get; set; }
    public bool? HasLighting { get; set; }
    public bool? HasShowers { get; set; }
    public bool? HasChangingRooms { get; set; }
    public bool? HasEquipmentRental { get; set; }
    public bool? HasCafeBar { get; set; }
}
