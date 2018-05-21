vcl 4.0;

# Default backend definition. Points to Apache, normally.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
    .first_byte_timeout = 30s;
}

sub vcl_recv {
  if (req.http.X-Forwarded-For) {
     set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
  } else {
     set req.http.X-Forwarded-For = client.ip;
  }
  if (req.method != "GET" && req.method != "HEAD") {
     return(pass);
  }
  if(req.url ~ "^/cron.php") {
     return(pass);
  }
  if(req.url ~ "^/xmlrpc.php") {
     return(pass);
  }
  if (req.http.Authorization) {
     return(pass);
  }
  if(req.http.cookie ~ "(^|;\s*)(SESS=)") {
     return(pass);
  }
  if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
    return (pass);
  }
  return(hash);
}
