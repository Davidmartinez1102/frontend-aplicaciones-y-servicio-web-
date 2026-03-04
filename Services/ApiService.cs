using System.Net.Http.Json;
using System.Text.Json;

namespace FrontBlazor_AppiGenericaCsharp.Services
{
    public class ApiService
    {
        private readonly HttpClient _http;
        private readonly JsonSerializerOptions _jsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

        public ApiService(HttpClient http)
        {
            _http = http;
        }

        public async Task<List<Dictionary<string, object?>>> ListarAsync(string tabla, int? limite = null)
        {
            try
            {
                string url = $"/api/{tabla}";
                if (limite.HasValue)
                    url += $"?limite={limite.Value}";

                var response = await _http.GetAsync(url);

                if (response.StatusCode == System.Net.HttpStatusCode.NoContent || !response.IsSuccessStatusCode)
                    return new List<Dictionary<string, object?>>();

                var content = await response.Content.ReadAsStringAsync();

                if (string.IsNullOrWhiteSpace(content))
                    return new List<Dictionary<string, object?>>();

                var respuesta = JsonSerializer.Deserialize<JsonElement>(content, _jsonOptions);

                if (respuesta.TryGetProperty("datos", out JsonElement datos))
                    return ConvertirDatos(datos);

                return new List<Dictionary<string, object?>>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al listar {tabla}: {ex.Message}");
                return new List<Dictionary<string, object?>>();
            }
        }

        public async Task<(bool exito, string mensaje)> CrearAsync(string tabla, Dictionary<string, object?> datos, string? camposEncriptar = null)
        {
            try
            {
                string url = $"/api/{tabla}";
                if (!string.IsNullOrEmpty(camposEncriptar))
                    url += $"?camposEncriptar={camposEncriptar}";

                var respuesta = await _http.PostAsJsonAsync(url, datos);
                var content = await respuesta.Content.ReadAsStringAsync();

                if (string.IsNullOrWhiteSpace(content))
                    return (respuesta.IsSuccessStatusCode, respuesta.IsSuccessStatusCode ? "Operación completada." : "Error al procesar la solicitud.");

                var contenido = JsonSerializer.Deserialize<JsonElement>(content, _jsonOptions);
                string mensaje = contenido.TryGetProperty("mensaje", out JsonElement msg) ? msg.GetString() ?? "Operación completada." : "Operación completada.";

                return (respuesta.IsSuccessStatusCode, mensaje);
            }
            catch (Exception ex)
            {
                return (false, $"Error de conexión: {ex.Message}");
            }
        }

        public async Task<(bool exito, string mensaje)> ActualizarAsync(string tabla, string nombreClave, string valorClave, Dictionary<string, object?> datos, string? camposEncriptar = null)
        {
            try
            {
                string url = $"/api/{tabla}/{nombreClave}/{valorClave}";
                if (!string.IsNullOrEmpty(camposEncriptar))
                    url += $"?camposEncriptar={camposEncriptar}";

                var respuesta = await _http.PutAsJsonAsync(url, datos);
                var content = await respuesta.Content.ReadAsStringAsync();

                if (string.IsNullOrWhiteSpace(content))
                    return (respuesta.IsSuccessStatusCode, respuesta.IsSuccessStatusCode ? "Operación completada." : "Error al procesar la solicitud.");

                var contenido = JsonSerializer.Deserialize<JsonElement>(content, _jsonOptions);
                string mensaje = contenido.TryGetProperty("mensaje", out JsonElement msg) ? msg.GetString() ?? "Operación completada." : "Operación completada.";

                return (respuesta.IsSuccessStatusCode, mensaje);
            }
            catch (Exception ex)
            {
                return (false, $"Error de conexión: {ex.Message}");
            }
        }

        public async Task<(bool exito, string mensaje)> EliminarAsync(string tabla, string nombreClave, string valorClave)
        {
            try
            {
                var respuesta = await _http.DeleteAsync($"/api/{tabla}/{nombreClave}/{valorClave}");
                var content = await respuesta.Content.ReadAsStringAsync();

                if (string.IsNullOrWhiteSpace(content))
                    return (respuesta.IsSuccessStatusCode, respuesta.IsSuccessStatusCode ? "Operación completada." : "Error al procesar la solicitud.");

                var contenido = JsonSerializer.Deserialize<JsonElement>(content, _jsonOptions);
                string mensaje = contenido.TryGetProperty("mensaje", out JsonElement msg) ? msg.GetString() ?? "Operación completada." : "Operación completada.";

                return (respuesta.IsSuccessStatusCode, mensaje);
            }
            catch (Exception ex)
            {
                return (false, $"Error de conexión: {ex.Message}");
            }
        }

        public async Task<Dictionary<string, string>?> ObtenerDiagnosticoAsync()
        {
            try
            {
                var response = await _http.GetAsync("/api/diagnostico/conexion");
                if (!response.IsSuccessStatusCode) return null;

                var content = await response.Content.ReadAsStringAsync();
                if (string.IsNullOrWhiteSpace(content)) return null;

                var respuesta = JsonSerializer.Deserialize<JsonElement>(content, _jsonOptions);

                if (respuesta.TryGetProperty("servidor", out JsonElement servidor))
                {
                    var info = new Dictionary<string, string>();
                    foreach (var prop in servidor.EnumerateObject())
                    {
                        info[prop.Name] = prop.Value.ToString();
                    }
                    return info;
                }
                return null;
            }
            catch { return null; }
        }

        private List<Dictionary<string, object?>> ConvertirDatos(JsonElement datos)
        {
            var lista = new List<Dictionary<string, object?>>();
            foreach (var fila in datos.EnumerateArray())
            {
                var diccionario = new Dictionary<string, object?>();
                foreach (var propiedad in fila.EnumerateObject())
                {
                    diccionario[propiedad.Name] = propiedad.Value.ValueKind switch
                    {
                        JsonValueKind.String => propiedad.Value.GetString(),
                        JsonValueKind.Number => propiedad.Value.TryGetInt32(out int i) ? i : propiedad.Value.GetDouble(),
                        JsonValueKind.True => true,
                        JsonValueKind.False => false,
                        JsonValueKind.Null => null,
                        _ => propiedad.Value.GetRawText()
                    };
                }
                lista.Add(diccionario);
            }
            return lista;
        }
    }
}