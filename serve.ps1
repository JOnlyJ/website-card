$port = 8080
$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving at http://localhost:$port/"

$mimeTypes = @{
  ".html" = "text/html"
  ".css"  = "text/css"
  ".js"   = "application/javascript"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
  ".woff" = "font/woff"
  ".woff2"= "font/woff2"
}

while ($listener.IsListening) {
  $ctx  = $listener.GetContext()
  $req  = $ctx.Request
  $resp = $ctx.Response

  $localPath = $req.Url.LocalPath.TrimStart('/')
  if ($localPath -eq '') { $localPath = 'index.html' }

  $filePath = Join-Path $root $localPath

  if (Test-Path $filePath -PathType Leaf) {
    $ext  = [System.IO.Path]::GetExtension($filePath)
    $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { "application/octet-stream" }
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $resp.ContentType   = $mime
    $resp.ContentLength64 = $bytes.Length
    $resp.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $resp.StatusCode = 404
  }

  $resp.Close()
}
