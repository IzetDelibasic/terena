using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Terena.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddVenueIsOpenStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsOpen",
                table: "Venues",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsOpen",
                table: "Venues");
        }
    }
}
