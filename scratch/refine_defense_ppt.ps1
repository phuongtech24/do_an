param(
    [Parameter(Mandatory = $true)] [string] $Source,
    [Parameter(Mandatory = $true)] [string] $Output
)

$ErrorActionPreference = 'Stop'

function Rgb([int]$r, [int]$g, [int]$b) {
    return $r + (256 * $g) + (65536 * $b)
}

$script:Blue = Rgb 43 91 145
$script:Navy = Rgb 21 45 75
$script:LightBlue = Rgb 235 246 252
$script:Border = Rgb 190 209 224
$script:White = Rgb 255 255 255
$script:Green = Rgb 34 139 94
$script:Red = Rgb 205 71 74
$script:Amber = Rgb 226 151 45
$script:Gray = Rgb 78 91 105

function Clear-Slide($slide) {
    for ($i = $slide.Shapes.Count; $i -ge 1; $i--) {
        $slide.Shapes.Item($i).Delete()
    }
}

function Add-Text($slide, [string]$text, [double]$left, [double]$top, [double]$width, [double]$height,
                  [double]$size = 22, [int]$color = $script:Navy, [bool]$bold = $false,
                  [int]$align = 1, [string]$font = 'Aptos') {
    $shape = $slide.Shapes.AddTextbox(1, $left, $top, $width, $height)
    $shape.TextFrame2.TextRange.Text = $text
    $shape.TextFrame2.TextRange.Font.Name = $font
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

function Add-Title($slide, [string]$title, [string]$subtitle = '') {
    Add-Text $slide $title 70 38 1140 62 31 $script:Blue $true 1 | Out-Null
    if ($subtitle) {
        Add-Text $slide $subtitle 72 105 1120 48 16 $script:Gray $false 1 | Out-Null
    }
}

function Add-Card($slide, [string]$heading, [string]$body, [double]$left, [double]$top,
                  [double]$width, [double]$height, [int]$accent = $script:Blue) {
    $card = $slide.Shapes.AddShape(5, $left, $top, $width, $height)
    $card.Fill.ForeColor.RGB = $script:White
    $card.Line.ForeColor.RGB = $script:Border
    $card.Line.Weight = 1.25
    $bar = $slide.Shapes.AddShape(1, $left, $top, 10, $height)
    $bar.Fill.ForeColor.RGB = $accent
    $bar.Line.Visible = 0
    Add-Text $slide $heading ($left + 28) ($top + 18) ($width - 48) 34 19 $accent $true 1 | Out-Null
    Add-Text $slide $body ($left + 28) ($top + 62) ($width - 48) ($height - 78) 15 $script:Navy $false 1 | Out-Null
}

function Add-Pill($slide, [string]$text, [double]$left, [double]$top, [double]$width,
                  [int]$fill, [int]$fontColor = $script:White) {
    $pill = $slide.Shapes.AddShape(5, $left, $top, $width, 42)
    $pill.Fill.ForeColor.RGB = $fill
    $pill.Line.Visible = 0
    $pill.TextFrame2.TextRange.Text = $text
    $pill.TextFrame2.TextRange.Font.Name = 'Aptos'
    $pill.TextFrame2.TextRange.Font.Size = 15
    $pill.TextFrame2.TextRange.Font.Bold = -1
    $pill.TextFrame2.TextRange.Font.Fill.ForeColor.RGB = $fontColor
    $pill.TextFrame2.TextRange.ParagraphFormat.Alignment = 2
    $pill.TextFrame2.VerticalAnchor = 3
}

function Replace-Text($slide, [string]$old, [string]$new) {
    foreach ($shape in $slide.Shapes) {
        if ($shape.HasTextFrame -and $shape.TextFrame.HasText) {
            $current = $shape.TextFrame.TextRange.Text
            if ($current.Contains($old)) {
                $shape.TextFrame.TextRange.Text = $current.Replace($old, $new)
            }
        }
    }
}

function Remove-Text-Shapes($slide, [string[]]$patterns) {
    for ($i = $slide.Shapes.Count; $i -ge 1; $i--) {
        $shape = $slide.Shapes.Item($i)
        if ($shape.HasTextFrame -and $shape.TextFrame.HasText) {
            $text = $shape.TextFrame.TextRange.Text
            foreach ($pattern in $patterns) {
                if ($text -like "*$pattern*") {
                    $shape.Delete()
                    break
                }
            }
        }
    }
}

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Copy-Item -LiteralPath $Source -Destination $Output -Force

$ppt = New-Object -ComObject PowerPoint.Application
$presentation = $ppt.Presentations.Open($Output, $false, $false, $false)

# Slide 1: title accuracy and student metadata.
Replace-Text $presentation.Slides.Item(1) 'Phát triển hệ thống quản lý và hỗ trợ trị liệu rối loạn lo âu tích hợp Trí tuệ nhân tạo' 'Phát triển hệ thống hỗ trợ trị liệu lo âu xã hội tích hợp Trí tuệ nhân tạo'
Add-Text $presentation.Slides.Item(1) 'MSSV: 2251172459  |  Lớp: 64KTPM5' 58 634 500 30 13 $script:Gray $false 1 | Out-Null

# Slides 2–4: remove template author residue and soften unsupported claims.
Replace-Text $presentation.Slides.Item(2) 'Tỷ lệ rối loạn lo âu xã hội (SAD) và xu hướng tự cô lập (Hikikomori) tăng nhanh ở giới trẻ toàn cầu.' 'Lo âu xã hội gây né tránh, tự cô lập và làm suy giảm khả năng học tập, làm việc và kết nối xã hội.'
Remove-Text-Shapes $presentation.Slides.Item(3) @('Nhà nghiên cứu', 'Yael Amari')
Remove-Text-Shapes $presentation.Slides.Item(4) @('Nghiên cứu viên', 'Yael Amari')

# Slide 5: scope and limitations.
$slide = $presentation.Slides.Item(5)
Clear-Slide $slide
Add-Title $slide 'PHẠM VI ĐỀ TÀI VÀ GIỚI HẠN' 'Xác định rõ phần hệ thống đã hiện thực và các nội dung chưa thuộc phạm vi đồ án.'
Add-Card $slide 'PHẠM VI ĐÃ HIỆN THỰC' "• Hồ sơ ẩn danh và tài khoản bệnh nhân`r• LSAS, Goal Setting và lộ trình CBT`r• Thought Record, Daily Check-in và Safety Gate`r• Đặt lịch, Web CMS và điều phối Cờ đỏ`r• Gemini AI kết hợp vector RAG trên Qdrant" 75 175 540 390 $script:Blue
Add-Card $slide 'GIỚI HẠN VÀ LOẠI TRỪ' "• Chưa tích hợp video call trực tiếp; sử dụng liên kết họp`r• AI là mô hình tổng quát, không thay thế bác sĩ`r• Chưa thực hiện thử nghiệm lâm sàng trên người bệnh thật`r• Chưa công bố độ chính xác khi thiếu tập nhãn chuyên gia`r• Dữ liệu nhạy cảm cần tiếp tục tăng cường quản trị khi triển khai thật" 665 175 540 390 $script:Amber

# Slide 6: replace inaccurate AI accuracy claim.
Replace-Text $presentation.Slides.Item(6) 'Kiểm thử hồi quy hệ thống, đo lường độ chính xác dán nhãn AI và thử nghiệm tải tương tranh đặt lịch' 'Kiểm thử các luồng nghiệp vụ, đánh giá định tính phản hồi AI và xác minh cơ chế chống đặt lịch trùng'

# Slide 7: system functions.
$slide = $presentation.Slides.Item(7)
Clear-Slide $slide
Add-Title $slide 'CHỨC NĂNG CHÍNH CỦA HỆ THỐNG' 'Ba nhóm người dùng phối hợp trên cùng một nền tảng dữ liệu.'
Add-Card $slide 'BỆNH NHÂN – FLUTTER APP' "• Hồ sơ ẩn danh và hồ sơ chính thức`r• LSAS và mục tiêu trị liệu`r• Fear Ladder và Behavioral Experiment`r• Daily Check-in, Thought Record và AI`r• Đặt lịch tư vấn từ xa" 55 175 370 410 $script:Blue
Add-Card $slide 'BÁC SĨ – WEB CMS' "• Danh sách bệnh nhân phụ trách`r• Xem trước phiên tư vấn`r• Theo dõi LSAS và tiến trình trị liệu`r• Quản lý lịch làm việc, lịch hẹn`r• Ghi chú lâm sàng" 455 175 370 410 (Rgb 50 133 140)
Add-Card $slide 'QUẢN TRỊ VIÊN' "• Quản lý tài khoản và bác sĩ`r• Duyệt hồ sơ chuyên môn`r• Theo dõi dashboard ưu tiên`r• Điều phối và gán bác sĩ`r• Xử lý hàng chờ Cờ đỏ" 855 175 370 410 $script:Amber

# Slide 10: personalization aligned with code (no fictional W=1.5 coefficient).
$slide = $presentation.Slides.Item(10)
Clear-Slide $slide
Add-Title $slide 'CÁ NHÂN HÓA LỘ TRÌNH TRỊ LIỆU' 'LSAS baseline quyết định mức độ; goalType là tín hiệu ưu tiên, không thay thế đánh giá lâm sàng.'
Add-Card $slide '1. DỮ LIỆU NỀN LSAS' "24 tình huống được chấm theo hai chiều: Sợ hãi và Né tránh. Hệ thống chỉ lấy các tình huống có điểm lớn hơn 0 để tạo Fear Ladder." 65 190 350 250 $script:Blue
Add-Card $slide '2. ƯU TIÊN THEO MỤC TIÊU' "SOCIAL ưu tiên nhóm tương tác xã hội. BEHAVIORAL ưu tiên nhóm hiệu suất/biểu diễn. EMOTIONAL giữ thứ tự trung tính và bổ sung hướng dẫn điều hòa cảm xúc." 465 190 350 250 (Rgb 110 79 170)
Add-Card $slide '3. SẮP XẾP VÀ MỞ KHÓA' "Thứ tự: goalMatch giảm dần → tổng điểm tăng dần → số tình huống. Các nấc được mở dần theo trạng thái hoàn thành." 865 190 350 250 $script:Green
Add-Text $slide 'LSAS baseline' 90 500 210 35 18 $script:Navy $true 2 | Out-Null
Add-Text $slide '→' 320 494 55 40 26 $script:Blue $true 2 | Out-Null
Add-Text $slide 'Goal priority' 390 500 210 35 18 $script:Navy $true 2 | Out-Null
Add-Text $slide '→' 620 494 55 40 26 $script:Blue $true 2 | Out-Null
Add-Text $slide 'Fear Ladder' 690 500 210 35 18 $script:Navy $true 2 | Out-Null
Add-Text $slide '→' 920 494 55 40 26 $script:Blue $true 2 | Out-Null
Add-Text $slide 'Behavioral Experiment' 980 500 240 35 18 $script:Navy $true 2 | Out-Null

# Slide 12: consolidated outcomes.
$slide = $presentation.Slides.Item(12)
Clear-Slide $slide
Add-Title $slide 'KẾT QUẢ NGHIÊN CỨU VÀ KỸ THUẬT' 'Các kết quả đã hiện thực và có thể chứng minh bằng code, API hoặc dữ liệu kiểm thử.'
Add-Card $slide 'SẢN PHẨM ĐA VAI TRÒ' "Flutter App cho bệnh nhân; Web CMS cho bác sĩ và quản trị viên; Spring Boot API kết nối dữ liệu xuyên suốt." 70 175 530 185 $script:Blue
Add-Card $slide 'SỐ HÓA NGHIỆP VỤ CBT' "Ánh xạ LSAS, Thought Record, Fear Ladder và Behavioral Experiment từ cơ sở lý thuyết thành luồng phần mềm." 650 175 530 185 (Rgb 50 133 140)
Add-Card $slide 'AN TOÀN VÀ TOÀN VẸN' "JWT, AES-128 cho dữ liệu nhạy cảm, transaction và unique constraint chống trùng lịch; Safety Gate và Red Flag." 70 400 530 185 $script:Amber
Add-Card $slide 'AI, RAG VÀ KIỂM THỬ' "Gemini + Qdrant, index 26 knowledge chunks; API có schema và fallback; kiểm thử sáu kịch bản nghiệp vụ trọng tâm." 650 400 530 185 (Rgb 110 79 170)

# Slide 13: concurrency case study.
$slide = $presentation.Slides.Item(13)
Clear-Slide $slide
Add-Title $slide 'KIỂM SOÁT TƯƠNG TRANH KHI ĐẶT LỊCH' 'Hai request cùng chọn một khung giờ – hệ thống bảo vệ dữ liệu qua hai lớp.'
Add-Card $slide 'REQUEST ĐỒNG THỜI' "Request A và Request B cùng gửi yêu cầu đặt một slot của bác sĩ." 65 210 300 205 $script:Gray
Add-Text $slide '→' 380 280 55 55 30 $script:Blue $true 2 | Out-Null
Add-Card $slide 'SPRING BOOT' "Kiểm tra nghiệp vụ và lịch tồn tại. Toàn bộ thao tác chạy trong @Transactional." 445 210 340 205 $script:Blue
Add-Text $slide '→' 800 280 55 55 30 $script:Blue $true 2 | Out-Null
Add-Card $slide 'MYSQL – LỚP BẢO VỆ CUỐI' "UNIQUE (therapist_id, start_at)`rUNIQUE (patient_id, start_at)" 865 210 350 205 (Rgb 110 79 170)
Add-Pill $slide '200 OK – Lịch được tạo' 250 500 330 $script:Green
Add-Pill $slide '409 Conflict – Từ chối lịch trùng' 700 500 380 $script:Red

# Slide 16: honest AI evaluation.
$slide = $presentation.Slides.Item(16)
Clear-Slide $slide
Add-Title $slide 'KẾT QUẢ ĐÁNH GIÁ AI' 'Đánh giá ở mức chức năng phần mềm; chưa phải thử nghiệm lâm sàng.'
Add-Card $slide 'KẾT QUẢ ĐẠT' "✓ API và JSON contract`r✓ Qdrant RAG – 26 chunks`r✓ Fallback khi Gemini/Qdrant lỗi`r✓ Thought Record lưu AI metadata" 70 185 520 300 $script:Green
Add-Card $slide 'KẾT QUẢ CẦN HIỆU CHỈNH' "△ Nhận diện distortion: đạt một phần`r△ Corpus tri thức còn nhỏ`r○ Chưa có tập nhãn chuyên gia đủ lớn`r○ Chưa đánh giá lâm sàng" 650 185 520 300 $script:Amber
Add-Text $slide 'AI hỗ trợ nhận thức và điều hướng an toàn; không chẩn đoán hoặc thay thế quyết định của bác sĩ.' 125 535 1030 62 20 $script:Navy $true 2 | Out-Null

# Slide 18: conclusion consistent with current implementation.
$slide = $presentation.Slides.Item(18)
Clear-Slide $slide
Add-Title $slide 'KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN'
Add-Card $slide 'KẾT LUẬN' "• Hoàn thiện hệ thống đa vai trò App – CMS – Backend`r• Số hóa các luồng CBT cốt lõi cho lo âu xã hội`r• Tích hợp vector RAG và cơ chế fallback an toàn`r• Bảo vệ toàn vẹn lịch hẹn bằng transaction và constraint" 70 170 540 390 $script:Blue
Add-Card $slide 'HƯỚNG PHÁT TRIỂN' "• Mở rộng và thẩm định corpus tri thức với chuyên gia`r• Đánh giá AI trên tập dữ liệu được gán nhãn`r• Bổ sung video call và thông báo thời gian thực`r• Tăng cường audit, bảo mật khóa và triển khai production" 660 170 540 390 (Rgb 50 133 140)

# Delete redundant/template slides, descending to keep original indices stable.
foreach ($index in @(17, 15, 14, 11, 8)) {
    $presentation.Slides.Item($index).Delete()
}

$presentation.Save()
$pdf = [System.IO.Path]::ChangeExtension($Output, '.pdf')
$presentation.SaveAs($pdf, 32)
$presentation.Close()
$ppt.Quit()

[System.Runtime.InteropServices.Marshal]::ReleaseComObject($presentation) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Write-Output "PPTX=$Output"
Write-Output "PDF=$pdf"
