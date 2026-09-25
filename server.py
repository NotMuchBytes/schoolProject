"""Local static server with headers suitable for Godot Web exports."""

from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import mimetypes


HOST = "127.0.0.1"
PORT = 8000

mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("application/octet-stream", ".pck")


class GodotRequestHandler(SimpleHTTPRequestHandler):
    def guess_type(self, path):
        """Handle the export's unusual extension-only runtime filenames."""
        normalized = path.replace("\\", "/")
        special_types = {
            "/.html": "text/html",
            "/.js": "text/javascript",
            "/.wasm": "application/wasm",
            "/.pck": "application/octet-stream",
            "/.png": "image/png",
        }
        for suffix, content_type in special_types.items():
            if normalized.endswith(suffix):
                return content_type
        return super().guess_type(path)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        self.send_header("X-Content-Type-Options", "nosniff")
        # Godot's runtime filenames stay stable between exports. Revalidate them
        # so a browser cannot keep an older PCK with broken fonts or settings.
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    print(f"Serving {root}")
    print(f"Open http://{HOST}:{PORT}")
    server = ThreadingHTTPServer((HOST, PORT), GodotRequestHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server.")
    finally:
        server.server_close()
