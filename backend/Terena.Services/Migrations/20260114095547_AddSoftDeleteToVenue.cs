using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Terena.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddSoftDeleteToVenue : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DeleteTime",
                table: "Venues",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Venues",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeleteTime",
                table: "Venues");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Venues");
        }
    }
}
