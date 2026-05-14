# Cấu Trúc Frontend - Ứng Dụng Web Next.js 16

## Thiết Lập Dự Án

```
frontend/
├── app/
│   ├── layout.tsx               # Bố cục gốc
│   ├── page.tsx                 # Chuyển hướng Home/Landing
│   ├── globals.css              # Global Tailwind + Apple Music gradients
│   │
│   ├── (auth)/                  # Nhóm bố cục Auth
│   │   ├── layout.tsx           # Bố cục Auth
│   │   ├── login/page.tsx       # Trang Đăng Nhập
│   │   └── register/page.tsx    # Trang Đăng Ký
│   │
│   └── (app)/                   # Nhóm bố cục ứng dụng chính
│       ├── layout.tsx           # Bố cục ứng dụng với Sidebar + Navbar
│       ├── home/page.tsx        # Home/Duyệt nhạc
│       ├── player/page.tsx      # Chế độ xem trình phát toàn màn hình
│       ├── playlist/page.tsx    # Quản lý danh sách phát
│       ├── search/page.tsx      # Kết quả tìm kiếm
│       └── profile/page.tsx     # Hồ sơ người dùng
│
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx           # Thanh điều hướng trên cùng
│   │   ├── Sidebar.tsx          # Điều hướng thanh bên trái
│   │   └── MobileNav.tsx        # Điều hướng di động
│   │
│   ├── player/
│   │   ├── MusicPlayer.tsx      # Thành phần trình phát chính
│   │   ├── PlayerControls.tsx   # Nút Play/Pause/Next/Prev
│   │   ├── ProgressBar.tsx      # Thanh tìm kiếm với tiến trình
│   │   ├── VolumeControl.tsx    # Thanh trượt âm lượng
│   │   └── PlaylistDisplay.tsx  # Chế độ xem hàng đợi hiện tại
│   │
│   ├── song/
│   │   ├── SongCard.tsx         # Thẻ bài hát (chế độ xem lưới/danh sách)
│   │   ├── SongList.tsx         # Danh sách bài hát
│   │   ├── SongListItem.tsx     # Mục danh sách bài hát duy nhất
│   │   └── SongActions.tsx      # Thích/thêm vào danh sách phát
│   │
│   ├── playlist/
│   │   ├── PlaylistCard.tsx     # Thẻ danh sách phát
│   │   ├── PlaylistGrid.tsx     # Lưới danh sách phát
│   │   ├── PlaylistForm.tsx     # Tạo/Chỉnh sửa danh sách phát
│   │   └── PlaylistSongsList.tsx# Bài hát trong danh sách phát
│   │
│   ├── search/
│   │   ├── SearchInput.tsx      # Thanh tìm kiếm với gợi ý
│   │   ├── SearchResults.tsx    # Hiển thị kết quả tìm kiếm
│   │   └── FilterTabs.tsx       # Bộ lọc theo loại
│   │
│   ├── upload/
│   │   ├── UploadForm.tsx       # Biểu mẫu tải lên tệp
│   │   └── UploadProgress.tsx   # Thanh tiến trình tải lên
│   │
│   ├── ui/
│   │   ├── Button.tsx           # Nút tùy chỉnh
│   │   ├── Input.tsx            # Đầu vào tùy chỉnh
│   │   ├── Modal.tsx            # Hộp thoại Modal
│   │   ├── Spinner.tsx          # Spinner tải
│   │   └── Toast.tsx            # Thông báo
│   │
│   └── shared/
│       ├── Header.tsx           # Thành phần tiêu đề trang
│       ├── ErrorBoundary.tsx    # Xử lý lỗi
│       └── LoadingState.tsx     # Bộ xương tải
│
├── hooks/
│   ├── usePlayer.ts             # Quản lý trạng thái trình phát
│   ├── useAuth.ts               # Trạng thái auth và phương thức
│   ├── usePlaylist.ts           # Hoạt động danh sách phát
│   ├── useFavorites.ts          # Quản lý yêu thích
│   ├── useSearch.ts             # Chức năng tìm kiếm
│   └── useAudio.ts              # Điều khiển phát âm thanh
│
├── lib/
│   ├── api.ts                   # Khách hàng API với quản lý token
│   ├── supabase.ts              # Khởi tạo khách hàng Supabase
│   ├── constants.ts             # Hằng số và enums
│   ├── types.ts                 # Các loại TypeScript
│   ├── utils.ts                 # Hàm tiện ích
│   ├── formatters.ts            # Định dạng chuỗi/số
│   └── validators.ts            # Xác nhân đầu vào
│
├── context/
│   ├── PlayerContext.tsx        # Nhà cung cấp trạng thái trình phát
│   ├── AuthContext.tsx          # Nhà cung cấp trạng thái auth
│   └── AppContext.tsx           # Trạng thái ứng dụng toàn cầu
│
├── styles/
│   ├── globals.css              # Kiểu toàn cầu
│   ├── tailwind.css             # Cấu hình Tailwind
│   └── apple-music-theme.css    # Apple Music cụ thể
│
├── public/
│   ├── images/
│   │   ├── logo.svg
│   │   ├── placeholder.png
│   │   └── icons/
│   └── audio/
│       └── placeholder.mp3      # Âm thanh dự phòng
│
├── .env.example
├── .env.local                   # Biến môi trường cục bộ
├── .gitignore
├── package.json
├── tsconfig.json
├── next.config.mjs
├── tailwind.config.ts
└── README.md
```

## Mô Tả Chi Tiết Thành Phần

### Thành Phần Bố Cục

#### Navbar.tsx
- Thanh điều hướng trên cùng
- Logo và thương hiệu
- Đầu vào tìm kiếm
- Dropdown hồ sơ người dùng
- Chủ đề Apple Music tối

#### Sidebar.tsx
- Điều hướng thanh bên trái
- Liên kết: Home, Tìm kiếm, Danh sách phát, Bài hát Yêu thích, Hồ sơ
- Danh sách danh sách phát của người dùng
- Nút tạo danh sách phát mới
- Đáp ứng (ẩn trên di động)

### Thành Phần Trình Phát

#### MusicPlayer.tsx
- Trình phát nhạc chính (toàn màn hình hoặc trình phát dưới cùng)
- Tác phẩm album với gradient
- Thông tin đang phát (tiêu đề, nghệ sĩ)
- Điều khiển trình phát

#### PlayerControls.tsx
- Nút Play/Pause
- Nút Previous/Next
- Chuyển đổi xáo trộn
- Chuyển đổi chế độ lặp lại
- Nút Thích/Yêu thích
- Nút Âm lượng

#### ProgressBar.tsx
- Thanh tiến trình tương tác
- Hiển thị thời gian hiện tại và thời lượng
- Có thể tìm kiếm (kéo để thay đổi vị trí)
- Chỉ báo bộ đệm

### Thành Phần Bài Hát

#### SongCard.tsx
- Thẻ chế độ xem lưới có:
  - Tác phẩm album
  - Tiêu đề bài hát
  - Tên nghệ sĩ
  - Nút phát hiệu ứng di chuột
- Nhấp để phát hoặc mở chi tiết

#### SongList.tsx
- Chế độ xem danh sách bài hát
- Hiển thị: Tên bài, Nghệ sĩ, Thời lượng, Thêm vào danh sách phát
- Menu ngữ cảnh bấm phải
- Hoạt động di chuột (phát, thích, v.v.)

### Thành Phần Danh Sách Phát

#### PlaylistCard.tsx
- Thẻ lưới danh sách phát
- Ảnh bìa (gradient nếu không có)
- Tên danh sách phát
- Số bài hát
- Nhấp để mở/xem bài hát

#### PlaylistForm.tsx
- Tạo hộp thoại danh sách phát mới
- Chỉnh sửa tên/mô tả danh sách phát
- Tải lên ảnh bìa
- Chuyển đổi công khai/riêng tư
- Nút Lưu

### Thành Phần Tìm Kiếm

#### SearchInput.tsx
- Đầu vào tìm kiếm được khử trùng
- Gợi ý tự động hoàn thành
- Tìm kiếm gần đây
- Danh mục tìm kiếm (tất cả, bài hát, nghệ sĩ, danh sách phát)

#### SearchResults.tsx
- Hiển thị kết quả tìm kiếm
- Lọc theo danh mục
- Hiển thị kết quả hàng đầu
- Phân trang

## Cấu Trúc Trang

### /home
- Tiêu đề: "Khám Phá Nhạc"
- Bộ trục nhạc nổi bật
- Phần Phát gần đây
- Lưới bài hát phổ biến
- Danh sách phát được đề xuất
- Thanh tìm kiếm ở trên cùng

### /player
- Chế độ xem trình phát toàn màn hình
- Tác phẩm album lớn
- Thông tin bài hát (tiêu đề, nghệ sĩ, album)
- Thanh tiến trình có tìm kiếm
- Điều khiển trình phát (phát, tiếp theo, trước)
- Điều khiển âm lượng
- Nút Thích
- Panel hàng đợi danh sách phát (bên phải)

### /playlist
- Phần Danh Sách Phát Của Bạn
- Nút Tạo mới
- Lưới danh sách phát
- Nhấp để xem nội dung danh sách phát
- Tùy chọn chỉnh sửa/xóa

### /search
- Đầu vào tìm kiếm ở trên cùng
- Lưới kết quả tìm kiếm
- Tab bộ lọc (Tất cả, Bài hát, Nghệ sĩ, Danh sách phát)
- Thông báo "Không có kết quả"
- Tìm kiếm gần đây

### /profile
- Thông tin hồ sơ người dùng
- Ảnh hồ sơ
- Tên người dùng, email
- Bài hát tải lên của bạn
- Danh sách phát của bạn
- Cài đặt
- Nút Đăng Xuất

## Quản Lý Trạng Thái

### Hook usePlayer
```typescript
{
  currentSong: Song | null,
  isPlaying: boolean,
  duration: number,
  currentTime: number,
  playlist: Song[],
  currentIndex: number,
  volume: number,
  shuffle: boolean,
  repeat: 'off' | 'one' | 'all',
  play: (song: Song) => void,
  pause: () => void,
  next: () => void,
  previous: () => void,
  seek: (time: number) => void,
  setVolume: (vol: number) => void
}
```

### Hook useAuth
```typescript
{
  user: User | null,
  isLoading: boolean,
  error: string | null,
  login: (email, password) => Promise<void>,
  register: (email, password, username) => Promise<void>,
  logout: () => Promise<void>,
  isAuthenticated: boolean
}
```

### Hook usePlaylist
```typescript
{
  playlists: Playlist[],
  isLoading: boolean,
  createPlaylist: (name, description) => Promise<Playlist>,
  updatePlaylist: (id, data) => Promise<void>,
  deletePlaylist: (id) => Promise<void>,
  addSongToPlaylist: (playlistId, songId) => Promise<void>,
  removeSongFromPlaylist: (playlistId, songId) => Promise<void>
}
```

## Chiến Lược Tạo Kiểu

### Cấu Hình Tailwind
- Bảng màu lấy cảm hứng từ Apple Music
- Gradient tùy chỉnh cho nền
- Chủ đề tối làm mặc định
- Họ phông tùy chỉnh (phong cách SF Pro Display)

### Lược Đồ Màu
```
Nền: #000000 - #1a1a1a (gradient tối)
Văn bản Chính: #ffffff
Văn bản Phụ: #b3b3b3
Nhấn: #FA243C hoặc vàng để làm nổi bật
Nền Thẻ: rgba(255,255,255,0.05)
Trạng thái Di Chuột: rgba(255,255,255,0.1)
```

### Các Lớp CSS Chính
```
.player-gradient - Nền gradient cho trình phát
.song-card-hover - Hiệu ứng di chuột cho thẻ bài hát
.playlist-cover - Gradient dự phòng cho bìa
.blur-effect - Hiệu ứng Glassmorphism
.text-balance - Ngắt dòng văn bản tối ưu
```

## Tích Hợp API

Tất cả các cuộc gọi API thông qua `lib/api.ts`:

```typescript
export const api = {
  songs: {
    getAll: () => GET('/api/songs'),
    getById: (id) => GET(`/api/songs/${id}`),
    search: (q) => GET(`/api/songs/search?q=${q}`),
    upload: (file) => POST('/api/songs', formData),
  },
  playlists: {
    getAll: () => GET('/api/playlists'),
    create: (data) => POST('/api/playlists', data),
    addSong: (playlistId, songId) => POST(`/api/playlists/${playlistId}/songs`, {songId}),
  },
  favorites: {
    getAll: () => GET('/api/favorites'),
    add: (songId) => POST(`/api/favorites/${songId}`),
    remove: (songId) => DELETE(`/api/favorites/${songId}`),
  },
  auth: {
    login: (email, password) => POST('/api/auth/login', {email, password}),
    register: (data) => POST('/api/auth/register', data),
  }
}
```

## Tối Ưu Hóa Hiệu Suất

1. **Tối Ưu Hóa Ảnh**: Sử dụng thành phần Next.js Image với placeholder mờ
2. **Phân Chia Mã**: Nhập động cho các thành phần lớn
3. **Tải Lối Biếng**: Cuộn vô hạn cho danh sách bài hát
4. **Lưu Trữ**: SWR để tải dữ liệu với bộ đệm
5. **Ghi Nhớ**: React.memo cho các thành phần nặng
6. **CSS-in-JS**: CSS quan trọng nội tuyến

## Khả Năng Đáp Ứng Của Thiết Bị Di Động

- Thanh bên ẩn trên di động (sử dụng ngăn kéo/menu hamburger)
- Bố cục một cột cho danh sách
- Nút thân thiện với cảm ứng (tối thiểu 44px)
- Được tối ưu hóa cho hướng ngang
- Giao diện trình phát đáp ứng
