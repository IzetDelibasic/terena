FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY backend/ .

WORKDIR /src/Terena.API
RUN dotnet restore "Terena.API.csproj"

RUN dotnet build "Terena.API.csproj" -c Release -o /app/build

FROM build AS publish
WORKDIR /src/Terena.API
RUN dotnet publish "Terena.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "Terena.API.dll"]
