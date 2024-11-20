function ESPSPIFFSuploadfile() {
    param (
        [Parameter(Mandatory = $true)][String] $UploadURL, 
        [Parameter(Mandatory = $true)][String] $Filename, 
        [Parameter(Mandatory = $false)][String] $Destinaionfilename 
    )
    if ([string]::IsNullOrWhiteSpace($Destinaionfilename)) { $Destinaionfilename = "/$(Split-Path $File -leaf)" }     
    
    $file = Get-Item $Filename;
    $fileStream = $file.OpenRead()
    $content = [System.Net.Http.MultipartFormDataContent]::new()
    $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
    $fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    # Your example had quotes in your literal form-data example so I kept them here
    $fileContent.Headers.ContentDisposition.Name = '"Filedata"'
    $fileContent.Headers.ContentDisposition.FileName = '"{0}"' -f $Destinaionfilename 
    $fileContent.Headers.ContentType = 'application/octet-stream'
    $content.Add($fileContent)
    # Content-Type is set automatically from the FormData to
    # multipart/form-data, Boundary: "..."
    Invoke-RestMethod -Uri $UploadURL -Method Post -Body $content
}
################################################################################################################################

$URI = "http://192.168.5.29"
# Dir 
Invoke-RestMethod -Uri "$URI/list?dir=/" -Method get
Invoke-RestMethod -Uri "$URI/test2.txt" -Method get
# Delete file
Invoke-RestMethod -Uri "$URI/test2.txt" -Method delete
Invoke-WebRequest -Uri "$URI/test2.txt" -Method delete
curl -XDELETE "$URI/test2.txt"
# Dir /test 
Invoke-RestMethod -Uri "$URI/list?dir=/" -Method get
Invoke-WebRequest -Uri "$URI/list?dir=/" -Method get
Invoke-RestMethod -Uri "$URI/edit?path=/test.txt" -Method delete
# Create dirctory is not supported on the SPIFFS
Invoke-RestMethod -Uri "$URI/edit?path=/test" -Method put
Invoke-RestMethod -Uri "$URI/list?dir=/test" -Method get
# create file
Invoke-RestMethod -Uri "$URI/edit?path=/test.txt" -Method put
# Upload a file 
# create a test file 
"Testing $(get-date) " + [System.Guid]::NewGuid().ToString() > 'test.txt'
# Upload a file
ESPSPIFFSuploadfile "$URI/edit" 'test.txt' '/test2.txt'

ESPSPIFFSuploadfile "$URI/edit" 'web\Mars.jpg' '/Mars2.jpg'
Invoke-WebRequest "$URI/Mars2.jpg" -OutFile 'web\Mars3.jpg'
compare-object (get-content 'web\Mars.jpg') (get-content 'web\Mars3.jpg')
Invoke-RestMethod -Uri "$URI/list?dir=/" -Method get
Invoke-RestMethod -Uri "$URI/edit?path=/Mars2.jpg" -Method delete
