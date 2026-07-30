const imgProxy = "https://img-proxy.easonproject106.workers.dev/?url=";

String addImgProxy(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith(imgProxy)) return url;
  return "$imgProxy$url";
}

List<String> addImgProxyList(List<String> urls) {
  return urls.map(addImgProxy).toList();
}
