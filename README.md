# Ứng Dụng Streaming Nhạc - Hướng Dẫn Triển Khai Full Stack

Một ứng dụng streaming nhạc hoàn chỉnh, sẵn sàng cho sản xuất được xây dựng bằng backend Node.js/Express, frontend Next.js 16 và cơ sở dữ liệu Supabase.

## 📚 Tài Liệu

Tất cả tài liệu dự án được tổ chức trong các tệp markdown riêng biệt để dễ tham khảo:

### Bắt Đầu Từ Đây
1. **[PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** ⭐
   - Tổng quan dự án cấp cao
   - Sơ đồ kiến trúc
   - Danh sách tính năng
   - Tóm tắt công nghệ
   - Hướng dẫn bắt đầu nhanh

2. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** 🚀
   - Các lệnh thiết yếu
   - Vị trí tệp
   - Các tác vụ phổ biến
   - Mẹo gỡ lỗi
   - Danh sách kiểm tra triển khai

### Hướng Dẫn Triển Khai
3. **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** 📖
   - Hướng dẫn thiết lập từng bước (5 giai đoạn)
   - Giai đoạn 1: Thiết lập backend
   - Giai đoạn 2: Thiết lập cơ sở dữ liệu
   - Giai đoạn 3: Thiết lập frontend
   - Giai đoạn 4: Tích hợp & kiểm tra
   - Giai đoạn 5: Triển khai
   - Phần khắc phục sự cố

### Kiến Trúc & Thiết Kế
4. **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** 🗄️
   - Lược đồ cơ sở dữ liệu hoàn chỉnh
   - 6 bảng chính
   - Các chính sách Row Level Security (RLS)
   - Chỉ số và hiệu suất
   - Script di chuyển

5. **[BACKEND_STRUCTURE.md](./BACKEND_STRUCTURE.md)** 🔧
   - Cấu trúc dự án backend
   - Tổ chức thư mục
   - Chi tiết tệp
   - Phụ thuộc
   - Biến môi trường

6. **[FRONTEND_STRUCTURE.md](./FRONTEND_STRUCTURE.md)** 🎨
   - Cấu trúc dự án frontend
   - Tổ chức thành phần
   - Bố cục trang
   - Hook quản lý trạng thái
   - Chiến lược tạo kiểu
   - Hệ thống thiết kế Apple Music

### Tài Liệu Tham Khảo API
7. **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** 🔌
   - Tất cả các điểm cuối API (22 tổng cộng)
   - Các điểm cuối xác thực (5)
   - Các điểm cuối bài hát (5)
   - Các điểm cuối danh sách phát (7)
   - Các điểm cuối yêu thích (3)
   - Tích hợp API công khai (2)
   - Ví dụ về yêu cầu/phản hồi
   - Xử lý lỗi

### Triển Khai
8. **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** 🚢
   - Các tùy chọn triển khai backend
   - Triển khai frontend sang Vercel
   - Thiết lập miền
   - Biến môi trường cho sản xuất
   - Giám sát & nhật ký
   - Khả năng mở rộng
   - Danh sách kiểm tra bảo mật

---

## 🎵 Tổng Quan Dự Án

### Cái Này Là Gì
Một ứng dụng web streaming nhạc full-stack tương tự Spotify hoặc Apple Music, có các tính năng:

- **Xác thực người dùng**: Đăng ký, đăng nhập, hồ sơ
- **Duyệt nhạc**: Duyệt, tìm kiếm, khám phá bài hát
- **Phát nhạc**: Phát trực tuyến với các điều khiển người chơi
- **Danh sách phát**: Tạo, quản lý, chia sẻ danh sách phát
- **Yêu thích**: Thích/không thích bài hát để truy cập nhanh
- **Nhạc Hybrid**: API công khai (Deezer) + tải lên người dùng
- **Thiết kế Lấy cảm hứng từ Apple Music**: Giao diện hiện đại, dựa trên gradient

### Kiến Trúc
```
Frontend (Next.js) → Backend (Express) → Database (Supabase)
```

- **Backend**: Node.js/Express REST API
- **Frontend**: Next.js 16 với TypeScript & Tailwind CSS
- **Cơ sở dữ liệu**: Supabase PostgreSQL với RLS
- **Lưu trữ**: Supabase Storage cho tải lên MP3
- **Auth**: JWT tokens + Supabase Auth

### Tính Năng Chính
✅ Xác thực người dùng & hồ sơ  
✅ Streaming nhạc (không cần tải xuống)  
✅ Quản lý danh sách phát  
✅ Tìm kiếm & khám phá  
✅ Thích/bỏ thích bài hát  
✅ Tải lên nhạc cá nhân  
✅ Tích hợp API công khai (Deezer)  
✅ Giao diện toàn màn hình chuyên dụng  
✅ Giao diện lấy cảm hứng từ Apple Music  

---

## 🚀 Bắt Đầu Nhanh (5 phút)

### 1. Thiết lập Supabase
1. Tạo tài khoản tại [supabase.com](https://supabase.com)
2. Tạo dự án mới
3. Sao chép URL và khóa API
4. Tạo nhóm lưu trữ có tên `uploads`

### 2. Thiết lập Backend
```bash
cd backend
npm install
cp .env.example .env
# Điền thông tin xác thực Supabase vào .env
npm start  # Chạy trên http://localhost:5000
```

### 3. Thiết lập Frontend
```bash
cd frontend
npm install
cp .env.example .env.local
# Điền URL API và thông tin xác thực Supabase
npm run dev  # Chạy trên http://localhost:3000
```

### 4. Kiểm Tra
- Đi đến http://localhost:3000
- Đăng ký tài khoản mới
- Duyệt nhạc và tạo danh sách phát

**Xem [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) để biết hướng dẫn chi tiết**

---

## 📁 Cấu Trúc Tệp

```
project-root/
├── backend/                     # Node.js/Express API
│   ├── src/
│   │   ├── config/             # Supabase & cấu hình env
│   │   ├── middleware/         # Auth, xử lý lỗi
│   │   ├── controllers/        # Trình xử lý yêu cầu
│   │   ├── services/           # Logic kinh doanh
│   │   ├── routes/             # Tuyến API
│   │   └── utils/              # Hàm trợ giúp
│   ├── migrations/             # Tệp lược đồ SQL
│   └── package.json
│
├── frontend/                    # Ứng dụng Next.js 16
│   ├── app/
│   │   ├── (auth)/             # Login/Đăng ký
│   │   ├── (app)/              # Trang ứng dụng chính
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── layout/
│   │   ├── player/
│   │   ├── song/
│   │   └── ui/
│   ├── hooks/                  # Custom hooks
│   ├── lib/                    # Utils & API client
│   └── package.json
│
├── README.md                   # Tệp này
├── PROJECT_SUMMARY.md          # Tổng quan dự án
├── QUICK_REFERENCE.md          # Lệnh nhanh
├── IMPLEMENTATION_GUIDE.md     # Hướng dẫn thiết lập
├── DATABASE_SCHEMA.md          # Thiết kế DB
├── BACKEND_STRUCTURE.md        # Chi tiết backend
├── FRONTEND_STRUCTURE.md       # Chi tiết frontend
├── API_DOCUMENTATION.md        # Tài liệu tham khảo API
└── DEPLOYMENT_GUIDE.md         # Hướng dẫn triển khai
```

---

## 🏗️ Stack Công Nghệ

### Backend
- **Node.js 20+** - Runtime
- **Express 4.18+** - Framework
- **Supabase** - Cơ sở dữ liệu & Auth
- **PostgreSQL** - Cơ sở dữ liệu SQL
- **JWT** - Xác thực
- **bcryptjs** - Hashing mật khẩu
- **Joi** - Xác nhận

### Frontend
- **Next.js 16** - React framework
- **TypeScript** - An toàn kiểu
- **Tailwind CSS** - Tạo kiểu
- **shadcn/ui** - Thành phần UI
- **SWR** - Tải dữ liệu
- **Supabase Client** - Truy cập cơ sở dữ liệu
- **React Context** - Quản lý trạng thái

### Cơ Sở Dữ Liệu
- **PostgreSQL** - Cơ sở dữ liệu quan hệ
- **Row Level Security (RLS)** - Phân quyền
- **Chỉ số** - Tối ưu hóa hiệu suất

---

## 📊 Các Điểm Cuối API

### Xác Thực (5 điểm cuối)
- `POST /api/auth/register` - Đăng ký người dùng
- `POST /api/auth/login` - Đăng nhập người dùng
- `GET /api/auth/me` - Lấy người dùng hiện tại
- `POST /api/auth/logout` - Đăng xuất
- `POST /api/auth/refresh` - Làm mới token

### Bài Hát (5 điểm cuối)
- `GET /api/songs` - Liệt kê tất cả bài hát (có phân trang)
- `GET /api/songs/:id` - Lấy chi tiết bài hát
- `GET /api/songs/search?q=query` - Tìm kiếm bài hát
- `POST /api/songs` - Tải lên bài hát
- `GET /api/songs/stream/:id` - Phát trực tuyến bài hát

### Danh Sách Phát (7 điểm cuối)
- `GET /api/playlists` - Lấy danh sách phát của người dùng
- `POST /api/playlists` - Tạo danh sách phát
- `GET /api/playlists/:id` - Lấy chi tiết danh sách phát
- `PUT /api/playlists/:id` - Cập nhật danh sách phát
- `DELETE /api/playlists/:id` - Xóa danh sách phát
- `POST /api/playlists/:id/songs` - Thêm bài hát vào danh sách phát
- `DELETE /api/playlists/:id/songs/:songId` - Xóa bài hát khỏi danh sách phát

### Yêu Thích (3 điểm cuối)
- `GET /api/favorites` - Lấy yêu thích của người dùng
- `POST /api/favorites/:songId` - Thích bài hát
- `DELETE /api/favorites/:songId` - Bỏ thích bài hát

### API Công Khai (2 điểm cuối)
- `GET /api/public/deezer/search?q=query` - Tìm kiếm Deezer
- `GET /api/public/spotify/search?q=query` - Tìm kiếm Spotify (tùy chọn)

**Tổng cộng: 22 điểm cuối API**

Xem [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) để biết chi tiết đầy đủ với ví dụ yêu cầu/phản hồi.

---

## 🛠️ Hướng Dẫn Thiết Lập

### Điều Kiện Tiên Quyết
- Node.js 20+ 
- npm/pnpm/yarn
- Tài khoản Supabase (miễn phí)
- Trình soạn thảo văn bản (VS Code được khuyến nghị)

### Cài Đặt

**Bước 1: Chuẩn Bị Supabase**
```bash
# Tạo dự án Supabase tại supabase.com
# Nhận thông tin xác thực của bạn:
# - SUPABASE_URL
# - SUPABASE_ANON_KEY
# - SUPABASE_SERVICE_ROLE_KEY
```

**Bước 2: Thiết Lập Backend**
```bash
cd backend
npm install
cp .env.example .env

# Chỉnh sửa .env bằng thông tin xác thực Supabase
# Sau đó chạy di chuyển cơ sở dữ liệu (xem IMPLEMENTATION_GUIDE.md)

npm start  # Server chạy trên http://localhost:5000
```

**Bước 3: Thiết Lập Frontend**
```bash
cd frontend
npm install
cp .env.example .env.local

# Chỉnh sửa .env.local bằng URL API và thông tin xác thực Supabase

npm run dev  # Ứng dụng chạy trên http://localhost:3000
```

**Bước 4: Tạo Lược Đồ Cơ Sở Dữ Liệu**
- Xem [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)
- Chạy di chuyển SQL trong bảng điều khiển Supabase
- Hoặc xem [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) để biết từng bước

**Bước 5: Kiểm Tra Ứng Dụng**
- Mở http://localhost:3000
- Đăng ký tài khoản mới
- Duyệt và phát nhạc
- Tạo danh sách phát
- Kiểm tra tất cả tính năng

Xem [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) để biết hướng dẫn chi tiết với tất cả 5 giai đoạn.

---

## 🚀 Triển Khai

### Triển Khai Backend
```bash
# Tùy chọn 1: Vercel
# Push sang GitHub → Kết nối với Vercel → Thêm biến env → Triển khai

# Tùy chọn 2: Railway.app
# Đăng ký → Kết nối GitHub → Cấu hình → Triển khai

# Tùy chọn 3: Render.com
# Đăng ký → Tạo web service → Cấu hình → Triển khai
```

### Triển Khai Frontend
```bash
# Vercel (Khuyến nghị)
# Push sang GitHub → Kết nối với Vercel → Thêm biến env → Triển khai

# Cập nhật NEXT_PUBLIC_API_URL thành URL backend của bạn
```

**Xem [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) để biết các bước chi tiết với nhiều tùy chọn triển khai.**

---

## 📖 Bản Đồ Tài Liệu

| Tài Liệu | Mục Đích | Khi Nào Đọc |
|----------|---------|-----------|
| [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) | Tổng quan & tính năng dự án | Trước khi bắt đầu |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | Lệnh & tác vụ phổ biến | Trong quá trình phát triển |
| [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) | Hướng dẫn thiết lập từng bước | Bắt đầu |
| [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) | Thiết kế cơ sở dữ liệu | Trước khi viết backend |
| [BACKEND_STRUCTURE.md](./BACKEND_STRUCTURE.md) | Kiến trúc backend | Xây dựng backend |
| [FRONTEND_STRUCTURE.md](./FRONTEND_STRUCTURE.md) | Kiến trúc frontend | Xây dựng frontend |
| [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) | Các điểm cuối API & ví dụ | Phát triển/kiểm tra |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | Triển khai sản xuất | Sẵn sàng triển khai |

---

## 🔒 Bảo Mật

### Xác Thực
- Xác thực dựa trên JWT
- Hashing mật khẩu an toàn bằng bcryptjs
- Cơ chế làm mới token
- Tích hợp Supabase Auth

### Phân Quyền
- Row Level Security (RLS) trên cơ sở dữ liệu
- Người dùng chỉ có thể truy cập dữ liệu của họ
- Dữ liệu công khai được phân phối hợp lý

### Bảo Mật API
- CORS được cấu hình cho miền của bạn
- Xác nhận đầu vào trên tất cả các điểm cuối
- Hỗ trợ giới hạn tỷ lệ
- Xử lý lỗi không làm lộ thông tin

### Bảo Mật Cơ Sở Dữ Liệu
- RLS được bật trên tất cả các bảng
- Ràng buộc khóa ngoài
- Xóa tự động dữ liệu liên quan
- Không có truy cập admin trực tiếp từ frontend

Xem [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) để biết danh sách kiểm tra bảo mật.

---

## 🐛 Gỡ Lỗi

### Vấn Đề Backend
```bash
# Kiểm tra xem backend có đang chạy không
curl http://localhost:5000/health

# Xem nhật ký
tail -f backend.log

# Kiểm tra kết nối cơ sở dữ liệu
# Xác minh SUPABASE_URL và SUPABASE_KEY trong .env
```

### Vấn Đề Frontend
```bash
# Mở DevTools của trình duyệt (F12)
# Kiểm tra tab Console để xem lỗi
# Kiểm tra tab Network cho các lệnh gọi API

# Xác minh .env.local được cấu hình
cat .env.local
```

### Vấn Đề Cơ Sở Dữ Liệu
- Đi đến bảng điều khiển Supabase
- Kiểm tra Trình chỉnh sửa SQL để thực hiện các truy vấn
- Xác minh các chính sách RLS

Xem [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) để biết thêm mẹo gỡ lỗi.

---

## 📝 Ví Dụ Sử Dụng

### Đăng Ký & Đăng Nhập
```bash
# Đăng ký
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword",
    "username": "johndoe"
  }'

# Đăng nhập
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword"
  }'
```

### Lấy Bài Hát
```bash
# Liệt kê bài hát
curl http://localhost:5000/api/songs?page=1&limit=20

# Tìm kiếm bài hát
curl "http://localhost:5000/api/songs/search?q=beatles"
```

### Tạo Danh Sách Phát
```bash
curl -X POST http://localhost:5000/api/playlists \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Danh Sách Phát Của Tôi"}'
```

Xem [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) để biết tất cả các ví dụ điểm cuối.

---

## 🎯 Bước Tiếp Theo

1. **Đọc [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** để biết tổng quan
2. **Làm theo [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** để thiết lập
3. **Tham khảo [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** khi viết mã
4. **Sử dụng [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** cho các lệnh phổ biến
5. **Làm theo [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** khi triển khai

---

## 🤝 Đóng Góp

Đây là một dự án học tập. Thoải mái:
- Triển khai các tính năng bổ sung
- Cải thiện UI/UX
- Tối ưu hóa hiệu suất
- Thêm kiểm tra
- Triển khai và chia sẻ

---

## 📚 Tài Nguyên Bổ Sung

### Tài Liệu Chính Thức
- [Tài Liệu Next.js 16](https://nextjs.org/docs)
- [Tài Liệu Express.js](https://expressjs.com)
- [Tài Liệu Supabase](https://supabase.com/docs)
- [Tailwind CSS](https://tailwindcss.com)
- [Tài Liệu PostgreSQL](https://www.postgresql.org/docs)

### Hướng Dẫn Video
- Hướng dẫn Next.js 16
- Express.js REST API
- Thiết lập Supabase
- Tailwind CSS Cơ Bản

### Cộng Đồng
- [Discord Vercel](https://discord.gg/vercel)
- [Discord Supabase](https://discord.supabase.com)
- [Stack Overflow](https://stackoverflow.com)

---

## 📄 Giấy Phép

Đây là một dự án học tập. Sử dụng tự do cho các mục đích giáo dục.

---

## ✨ Tính Năng

### Tính Năng Hiện Tại
- ✅ Xác thực người dùng & hồ sơ
- ✅ Duyệt & khám phá nhạc
- ✅ Trình phát nhạc toàn màn hình
- ✅ Quản lý danh sách phát
- ✅ Hệ thống yêu thích/thích
- ✅ Tìm kiếm nhạc
- ✅ Tích hợp API công khai (Deezer)
- ✅ Tải lên nhạc của người dùng
- ✅ Thiết kế lấy cảm hứng từ Apple Music
- ✅ REST API hoàn chỉnh (22 điểm cuối)
- ✅ Lược đồ cơ sở dữ liệu sẵn sàng cho sản xuất
- ✅ Tài liệu toàn diện

### Tính Năng Tương Lai
- 🔄 Tính năng xã hội (theo dõi, chia sẻ)
- 🔄 Bộ lọc tìm kiếm nâng cao
- 🔄 Khuyến nghị dựa trên lịch sử nghe
- 🔄 Trực quan hóa nhạc
- 🔄 Chế độ ngoại tuyến với service worker
- 🔄 Ứng dụng di động (Flutter theo yêu cầu)
- 🔄 Hệ thống bình luận/xếp hạng
- 🔄 Tải xuống để nghe ngoại tuyến

---

## 🎉 Bắt Đầu Ngay Bây Giờ

```bash
# Clone và thiết lập (giả sử backend và frontend tồn tại)
cd backend && npm install && npm start

# Trong terminal khác
cd frontend && npm install && npm run dev

# Mở http://localhost:3000 trong trình duyệt của bạn
# Đăng ký, duyệt nhạc và thưởng thức!
```

**Để thiết lập hoàn chỉnh với cơ sở dữ liệu: Xem [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)**

---

## 📞 Hỗ Trợ

### Cần Trợ Giúp?
1. Kiểm tra tệp tài liệu phù hợp
2. Tìm lỗi trong [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
3. Xem xét khắc phục sự cố [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
4. Kiểm tra tài liệu chính thức của các công nghệ được sử dụng
5. Hỏi trong các diễn đàn cộng đồng/Discord

### Tìm Thấy Vấn Đề?
- Kiểm tra tài liệu trước
- Tìm kiếm vấn đề GitHub
- Tạo báo cáo lỗi chi tiết với:
  - Bạn đã thử gì
  - Điều gì đã xảy ra
  - Thông báo lỗi
  - Thông tin hệ thống (phiên bản Node, v.v.)

---

**Chúc bạn viết mã vui vẻ! Xây dựng một cái gì đó tuyệt vời với ứng dụng streaming nhạc này! 🎵**
