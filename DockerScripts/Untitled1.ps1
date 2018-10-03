$Response = Invoke-WebRequest -Uri "http://172.23.23.143:8050/XMLWebServiceResponse.xml" -UseBasicParsing
$Response.ToString();
$Stream = [System.IO.StreamWriter]::new('C:/temp/docspage.xml')
try {
    $Stream.Write($Response.Content)
}
finally {
    $Stream.Dispose()
}