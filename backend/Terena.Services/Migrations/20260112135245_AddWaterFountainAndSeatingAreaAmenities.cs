using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Terena.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddWaterFountainAndSeatingAreaAmenities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "HasSeatingArea",
                table: "Venues",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "HasWaterFountain",
                table: "Venues",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "HasSeatingArea",
                table: "Venues");

            migrationBuilder.DropColumn(
                name: "HasWaterFountain",
                table: "Venues");
        }
    }
}
