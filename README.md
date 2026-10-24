# 图记 · Mac 版（Electron）

这是「图记 · 图片备注板」的 macOS 包装版。界面和功能和 Windows 版一致，使用 Electron + Chromium 内核，数据保存在 Mac 本地。

> 目录：`E:\tjmac`  
> 应用名：`图记.app`  
> 数据目录：`~/Library/Application Support/图记/`

## 快速开始

1. 把整个 `tjmac` 文件夹复制到 Mac（**不要复制 Windows 的 `node_modules`**，它在 Mac 上不能用）。
2. 在 Mac 上安装 Node.js 22.12 或更新版本（建议 LTS）。
3. 打开终端：

```bash
cd /路径/tjmac
npm install
npm start
```

要直接打包成 `.app` / `.dmg`：

```bash
npm run dist:mac
```

不想敲命令也可以：安装 Node.js 后，直接双击项目里的 **`构建图记.command`**。  
它会自动执行 `npm install` 和 `npm run dist:mac`，完成后打开 `dist` 文件夹。

> 如果 macOS 提示“无法打开”，右键 `构建图记.command` → **打开**。  
> 这个脚本默认使用国内 Electron 镜像，网络正常时也可以不管。

如果完全不想在 Mac 上装 Node，也可以看下面的 **GitHub 自动打包**。

---

## 图片编辑 / 裁剪

1. 点图片打开大图预览，点 **编辑 / 裁剪**；也可以右键图片 → **编辑 / 裁剪…**。
2. 拖动裁剪框移动位置，拖边框或四角调整大小。
3. 工具栏支持 **左转 / 右转 / 水平翻转 / 重置**，右侧实时显示裁剪后的像素尺寸。
4. 点 **保存裁剪** 替换当前图片；图片名称、备注、分组、完成状态都不会变。
5. 点 **取消** 或按 **Esc** 放弃本次编辑，不会修改原图。

保存时会尽量保持原格式：PNG / JPEG / WebP 按原格式输出，其他格式（包括 GIF）输出为 PNG。裁剪会替换当前图片本身，重要图片建议先导出备份。

---

## 1. 在 Mac 上运行开发版

需要先安装 **Node.js 22.12 或更新版本**（建议 LTS）。

> 如果这个目录是从 Windows 复制过来的，先删除 `node_modules` 再安装。Windows 的 Electron 二进制在 Mac 上不能用。

```bash
cd /路径/tjmac
rm -rf node_modules
npm install
npm start
```

第一次 `npm install` 会下载 Electron，约 100～200MB，需要联网。

如果下载 Electron 很慢或卡住，可以先设置国内镜像：

```bash
export ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/"
export ELECTRON_BUILDER_BINARIES_MIRROR="https://npmmirror.com/mirrors/electron-builder-binaries/"
npm install
```

开发模式带开发者工具菜单；打包后的正式版不显示开发者工具。

---

## 2. 打包成 Mac `.app` / `.dmg`

在 Mac 上执行：

```bash
cd /路径/tjmac
npm install
npm run dist:mac
```

或者直接双击 `构建图记.command`，效果一样。

产物在 `dist/`：

- `图记-1.0.0-arm64.dmg`
- `图记-1.0.0-arm64.zip`
- `dist/mac-arm64/图记.app`

`npm run dist:mac` 只打 Apple Silicon（arm64），适合 M5 MacBook Air。

如果需要同时支持 Intel Mac：

```bash
npm run dist:mac:universal
```

> 当前 `package.json` 里设置了 `"identity": null`，不做代码签名。自己用没问题；如果要发给别人，需要 Apple Developer 账号并配置签名和公证。

如果 macOS 提示“无法打开，因为无法验证开发者”：

1. 在 Finder 里右键 `图记.app` → **打开**；
2. 或执行：

```bash
xattr -dr com.apple.quarantine "/Applications/图记.app"
```

---

## GitHub 自动打包（可选，不用本地装 Node）

项目已经包含 `.github/workflows/build-mac.yml`。GitHub 会在一台 **macOS 机器**上执行 `npm ci` 和 `npm run dist:mac`，生成 arm64 的 DMG/ZIP，然后作为 artifact（构建产物压缩包）提供下载。

### 第一次设置

1. 注册/登录 GitHub：<https://github.com>
2. 新建一个仓库（建议 Private），例如 `tuji-mac`。
3. 把 `E:\tjmac` 里的**内容**上传到仓库根目录。推荐用 GitHub Desktop：Add local repository → 选择 `E:\tjmac` → Publish repository。  
   不要上传 `node_modules`、`dist`，`.gitignore` 已经排除。
4. 打开仓库的 **Actions** 页，左侧选 **Build macOS App**，点 **Run workflow**。
   - 如果上传到了 `main` 或 `master` 分支，推送后也会自动运行。
5. 等 3～8 分钟。构建完成后，在运行记录页面底部下载 **tuji-mac-arm64**。
6. 解压下载的 artifact，得到：
   - `图记-1.0.0-arm64.dmg`
   - `图记-1.0.0-arm64.zip`
   - `SHA256SUMS.txt`
7. 双击 DMG，把 `图记.app` 拖到“应用程序”。

> 这是未签名版本，第一次打开仍需右键 → 打开。  
> 想要双击无警告，需要 Apple Developer 账号做签名和公证。

---

## 3. 数据存在哪里

Electron 版的数据目录是：

```text
~/Library/Application Support/图记/
```

里面有 Chromium 的 IndexedDB / Local Storage，图片和备注都在这里。应用菜单里有：

- **帮助 → 打开数据文件夹**
- **帮助 → 打开下载文件夹**

备份文件默认通过“保存文件”对话框保存到你选择的位置。

> 不要手动删除这个目录，否则图片和文件夹会丢失。  
> 清理浏览器数据不会影响它，因为这是独立 App，不是浏览器。

---

## 4. 从 Windows 迁移数据

Mac 版不能直接读取 Windows 的 `E:\OP\图记数据`，需要走备份 JSON。

### Windows 上

1. 打开 Windows 版图记。
2. 点 **备份 → 导出全部数据**。
3. 得到 `图记备份_日期.json`。
4. 把这个 JSON 发到 Mac。

### Mac 上

1. 打开 `图记.app`。
2. 点 **备份 → 导入备份（追加）**。
3. 选择从 Windows 发来的 JSON。

图片、备注、文件夹、分组、收藏、完成状态都会导入。

注意：导入是**追加**模式。如果 Mac 上已经有同名文件夹，会变成：

```text
默认文件夹（导入）
默认文件夹（导入 2）
```

如果 Mac 是全新安装，导入后可能会多出一个空的“默认文件夹”，可以手动删掉。

---

## 5. 关于“同步”

当前版本**没有自动云同步**。Windows 和 Mac 各自保存一份本地数据。

- 一次性迁移：用上面的备份 JSON。
- 日常备份：定期在 Mac 上导出 JSON。
- 两边同时编辑：目前不支持自动合并；重复导入会追加副本。

如果以后需要 Windows/Mac 自动同步，需要另外接云数据库（例如 Supabase）并处理冲突合并，这不是换一个壳能解决的。

---

## 6. 项目结构

```text
tjmac/
├─ package.json              # Electron / electron-builder 配置
├─ 构建图记.command           # Mac 上双击构建
├─ .github/workflows/        # GitHub Actions 自动打包
│  └─ build-mac.yml
├─ .gitattributes            # 保证 .command 使用 LF 换行
├─ src/
│  └─ main.js                # 主进程：窗口、菜单、协议、下载
├─ renderer/
│  └─ index.html             # 图记网页版（从 Windows 版复制）
├─ build/
│  ├─ icon.icns              # Mac 图标
│  ├─ icon.ico               # Windows 测试用图标
│  ├─ icon.png               # 1024px 图标
│  └─ icon.iconset/          # Mac iconutil 可用的图标集
├─ scripts/
│  └─ make-icons.ps1         # 在 Windows 上重新生成图标
└─ dist/                     # 打包输出，git 忽略
```

### 更新图记界面

Windows 版更新后，把新的 `index.html` 覆盖到：

```text
renderer/index.html
```

然后重新 `npm start` 或重新打包即可。数据不受影响，因为数据存在 `~/Library/Application Support/图记/`，不在 `index.html` 里。

### 关于 origin

应用通过自定义协议加载：

```text
app://tuji/index.html
```

这样 IndexedDB 和 localStorage 的 origin 固定为 `app://tuji`，移动 `.app` 或升级版本都不会丢数据。不要改成 `file://`，否则可能出现数据存储位置变化的问题。

---

## 7. 已知差异

- **分享按钮**：依赖 `navigator.share`。如果 Electron 当前平台不支持，图记会自动隐藏分享按钮；其他功能不受影响。
- **代码签名**：默认不签名。自己用右键打开即可。
- **包体积**：Electron 包约 100～200MB，这是换取 Chromium 兼容性的代价。
- **自动同步**：不支持，仍然需要导出/导入 JSON。

---

## 8. 常见问题

### GitHub Actions 里没有 `Run workflow` 按钮

先把项目 push 到 GitHub，并确认 `.github/workflows/build-mac.yml` 在默认分支上。  
workflow 文件不在默认分支时，Actions 页面不会显示这个工作流。

### GitHub Actions 打包失败

先看运行日志。常见原因是 `package-lock.json` 和 `package.json` 不同步：在项目目录执行一次 `npm install`，把更新后的 `package-lock.json` 一起提交。

### 双击 `构建图记.command` 没反应

可能是解压工具丢了执行权限。打开终端，进入项目目录执行一次：

```bash
chmod +x 构建图记.command
```

### `npm start` 提示 Electron failed to install correctly

说明 Electron 二进制没有下载完整。在项目目录执行：

```bash
export ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/"
node node_modules/electron/install.js
```

然后再 `npm start`。

### 打开后是空白页

用开发模式看控制台：

```bash
npm run start:debug
```

### 下载没有弹出保存框

检查 `~/Downloads`，或在菜单里打开“下载文件夹”。应用已经为下载设置了保存对话框。

### 粘贴图片没反应

确认当前是图记窗口，并且系统没有限制剪贴板权限。应用已允许 `clipboard-read` / `clipboard-sanitized-write`。

### 数据会跟着 `.app` 一起被删吗？

不会。`.app` 只是程序，数据在 `~/Library/Application Support/图记/`。删除 `.app` 不会删除数据；要彻底删除需手动删除该数据目录。

---

## 9. 在 Mac 上重新生成图标（可选）

`build/icon.icns` 已经生成好。如果需要修改 `build/icon.iconset` 后重新生成：

```bash
iconutil -c icns build/icon.iconset -o build/icon.icns
```

在 Windows 上重新生成整套图标：

```powershell
npm run icon
```

（需要 Windows PowerShell 和 .NET Framework，macOS 上不需要执行。）
