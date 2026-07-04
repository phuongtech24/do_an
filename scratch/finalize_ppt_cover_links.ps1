param(
    [Parameter(Mandatory = $true)] [string] $PresentationPath,
    [Parameter(Mandatory = $true)] [string] $PdfPath
)

$ErrorActionPreference = 'Stop'

function Rgb([int]$r, [int]$g, [int]$b) { $r + 256 * $g + 65536 * $b }

$navy = Rgb 14 48 104
$blue = Rgb 28 78 170
$light = Rgb 241 248 253
$white = Rgb 255 255 255
$gray = Rgb 73 88 105
$border = Rgb 188 209 226

function Add-Text($slide, [string]$text, [double]$left, [double]$top, [double]$width, [double]$height,
                  [double]$size, [int]$color, [bool]$bold = $false, [int]$align = 1) {
    $shape = $slide.Shapes.AddTextbox(1, $left, $top, $width, $height)
    $shape.TextFrame2.TextRange.Text = $text
    $shape.TextFrame2.TextRange.Font.Name = 'Aptos'
    $shape.TextFrame2.TextRange.Font.Size = $size
    $shape.TextFrame2.TextRange.Font.Bold = $(if ($bold) { -1 } else { 0 })
    $shape.TextFrame2.TextRange.Font.Fill.ForeColor.RGB = $color
    $shape.TextFrame2.TextRange.ParagraphFormat.Alignment = $align
    $shape.TextFrame2.WordWrap = -1
    $shape.TextFrame2.MarginLeft = 0
    $shape.TextFrame2.MarginRight = 0
    $shape.TextFrame2.MarginTop = 0
    $shape.TextFrame2.MarginBottom = 0
    return $shape
}

function Add-LinkButton($slide, [string]$label, [string]$url, [double]$left, [double]$top, [double]$width) {
    $button = $slide.Shapes.AddShape(5, $left, $top, $width, 42)
    $button.Fill.ForeColor.RGB = $blue
    $button.Line.Visible = 0
    $button.TextFrame2.TextRange.Text = "↗  $label"
    $button.TextFrame2.TextRange.Font.Name = 'Aptos'
    $button.TextFrame2.TextRange.Font.Size = 13
    $button.TextFrame2.TextRange.Font.Bold = -1
    $button.TextFrame2.TextRange.Font.Fill.ForeColor.RGB = $white
    $button.TextFrame2.TextRange.ParagraphFormat.Alignment = 2
    $button.TextFrame2.VerticalAnchor = 3
    $button.ActionSettings.Item(1).Hyperlink.Address = $url
    return $button
}

$scientificUrl = 'https://github.com/phuongtech24/do_an/blob/develop/docs/submission/05_co_so_khoa_hoc_va_anh_xa_nghiep_vu.md'
$aiReportUrl = 'https://github.com/phuongtech24/do_an/blob/develop/docs/submission/04_bao_cao_danh_gia_thu_nghiem_ai.md'

$app = New-Object -ComObject PowerPoint.Application
$app.Visible = -1
$presentation = $app.Presentations.Open($PresentationPath, $false, $false, $false)

try {
    $slide = $presentation.Slides.Item(1)
    for ($i = $slide.Shapes.Count; $i -ge 1; $i--) { $slide.Shapes.Item($i).Delete() }

    $background = $slide.Shapes.AddShape(1, 0, 0, 1280, 720)
    $background.Fill.ForeColor.RGB = $light
    $background.Line.Visible = 0

    $topBand = $slide.Shapes.AddShape(1, 0, 0, 1280, 76)
    $topBand.Fill.ForeColor.RGB = $white
    $topBand.Line.Visible = 0
    Add-Text $slide 'TRƯỜNG ĐẠI HỌC THỦY LỢI' 62 20 520 24 16 $navy $true | Out-Null
    Add-Text $slide 'KHOA CÔNG NGHỆ THÔNG TIN' 62 44 520 20 10 $gray $false | Out-Null

    $rightPanel = $slide.Shapes.AddShape(1, 790, 76, 490, 570)
    $rightPanel.Fill.ForeColor.RGB = $blue
    $rightPanel.Line.Visible = 0
    $accent = $slide.Shapes.AddShape(1, 1030, 76, 250, 570)
    $accent.Fill.ForeColor.RGB = $navy
    $accent.Fill.Transparency = 0.08
    $accent.Line.Visible = 0

    $circle1 = $slide.Shapes.AddShape(9, 850, 160, 245, 245)
    $circle1.Fill.ForeColor.RGB = $white
    $circle1.Fill.Transparency = 0.88
    $circle1.Line.ForeColor.RGB = $white
    $circle1.Line.Transparency = 0.65
    $circle2 = $slide.Shapes.AddShape(9, 980, 330, 180, 180)
    $circle2.Fill.ForeColor.RGB = $white
    $circle2.Fill.Transparency = 0.9
    $circle2.Line.ForeColor.RGB = $white
    $circle2.Line.Transparency = 0.7
    Add-Text $slide 'AI + CBT' 862 250 350 58 34 $white $true 2 | Out-Null
    Add-Text $slide 'Hỗ trợ • Theo dõi • An toàn' 850 315 370 30 15 $white $false 2 | Out-Null

    $card = $slide.Shapes.AddShape(5, 62, 120, 780, 430)
    $card.Fill.ForeColor.RGB = $white
    $card.Line.ForeColor.RGB = $border
    $card.Line.Weight = 1.2

    $tag = $slide.Shapes.AddShape(5, 96, 150, 210, 36)
    $tag.Fill.ForeColor.RGB = $navy
    $tag.Line.Visible = 0
    $tag.TextFrame2.TextRange.Text = 'ĐỒ ÁN TỐT NGHIỆP'
    $tag.TextFrame2.TextRange.Font.Name = 'Aptos'
    $tag.TextFrame2.TextRange.Font.Size = 13
    $tag.TextFrame2.TextRange.Font.Bold = -1
    $tag.TextFrame2.TextRange.Font.Fill.ForeColor.RGB = $white
    $tag.TextFrame2.TextRange.ParagraphFormat.Alignment = 2
    $tag.TextFrame2.VerticalAnchor = 3

    Add-Text $slide 'ĐỀ TÀI' 96 215 620 24 15 $blue $true | Out-Null
    Add-Text $slide 'RECONNECT MINDHEALTH' 96 252 650 55 31 $navy $true | Out-Null
    Add-Text $slide 'Hệ thống hỗ trợ trị liệu lo âu xã hội tích hợp AI' 96 315 650 92 27 $navy $true | Out-Null
    Add-Text $slide 'Ứng dụng CBT số hóa, RAG và điều phối lâm sàng an toàn' 96 420 650 34 15 $gray $false | Out-Null

    $info = $slide.Shapes.AddShape(5, 62, 575, 780, 86)
    $info.Fill.ForeColor.RGB = $white
    $info.Line.ForeColor.RGB = $border
    Add-Text $slide 'Sinh viên: Nguyễn Khắc Nam Phương  •  MSSV: 2251172459  •  Lớp: 64KTPM5' 84 593 730 24 13 $navy $true | Out-Null
    Add-Text $slide 'Giảng viên hướng dẫn: Lê Thị Tú Kiên' 84 624 730 22 13 $gray $false | Out-Null

    $footer = $slide.Shapes.AddShape(1, 0, 680, 1280, 40)
    $footer.Fill.ForeColor.RGB = $navy
    $footer.Line.Visible = 0
    Add-Text $slide 'HÀ NỘI, 2026' 62 691 300 20 12 $white $true | Out-Null

    $slide10 = $presentation.Slides.Item(10)
    $panel10 = $slide10.Shapes.AddShape(5, 914, 590, 292, 82)
    $panel10.Fill.ForeColor.RGB = $light
    $panel10.Line.ForeColor.RGB = $border
    Add-Text $slide10 'Minh chứng nghiên cứu' 934 602 250 20 12 $navy $true | Out-Null
    Add-LinkButton $slide10 'MỞ BÁO CÁO CƠ SỞ KHOA HỌC' $scientificUrl 934 628 250 | Out-Null

    $slide12 = $presentation.Slides.Item(12)
    $panel12 = $slide12.Shapes.AddShape(5, 914, 590, 292, 82)
    $panel12.Fill.ForeColor.RGB = $light
    $panel12.Line.ForeColor.RGB = $border
    Add-Text $slide12 'Minh chứng đánh giá' 934 602 250 20 12 $navy $true | Out-Null
    Add-LinkButton $slide12 'MỞ BÁO CÁO ĐÁNH GIÁ AI' $aiReportUrl 934 628 250 | Out-Null

    $presentation.Save()
    if (Test-Path $PdfPath) { Remove-Item -LiteralPath $PdfPath -Force }
    $presentation.SaveAs($PdfPath, 32)
}
finally {
    $presentation.Close()
    $app.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($presentation) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($app) | Out-Null
}

Write-Output "Finalized: $PresentationPath"
Write-Output "PDF: $PdfPath"
