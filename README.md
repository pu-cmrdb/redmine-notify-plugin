# Redmine 通知插件

此插件可以讓使用者訂閱 Redmine 議題的到期日通知，支援電子郵件通知功能。

## 目錄

- [系統需求](#系統需求)
- [安裝步驟](#安裝步驟)
- [環境設定](#環境設定)
- [使用說明](#使用說明)
- [問題排查](#問題排查)
- [開發指南](#開發指南)

## 系統需求

- Docker 與 Docker Compose
- Git
- 硬體需求：
  - CPU: 2核心以上
  - 記憶體: 4GB以上
  - 硬碟空間: 10GB以上

## 安裝步驟

### 1. 下載插件

```bash
cd {REDMINE_ROOT}/plugins
git clone https://github.com/pu-cmrdb/redmine-notify-plugin.git
```

### 2. 設定 Docker 環境

1. 複製專案中的 docker-compose.yml：

   ```bash
   cp docker-compose.yml.example docker-compose.yml
   ```

2. 修改 docker-compose.yml 中的環境變數（如有需要）：

```yaml
REDMINE_DB_USERNAME: redmine
REDMINE_DB_PASSWORD: redminepass
REDMINE_DB_DATABASE: redmine
```

### 3. 啟動 Docker 容器

```bash
# 啟動所有服務
docker-compose up -d

# 確認服務狀態
docker-compose ps
```

### 4. 初始化資料庫

```bash
# 執行資料庫遷移
docker exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

### 5. 重啟 Redmine

```bash
docker restart redmine
```

## 環境設定

### 插件設定

1. 登入 Redmine 管理員帳號
2. 前往「管理」→「插件」
3. 找到「Redmine 通知插件」並點擊「設定」
4. 可設定項目：
   - 提前通知天數
   - 啟用/停用電子郵件通知
   - 設定通知時間

### 電子郵件設定

在 Redmine 的設定中設定 SMTP：

1. 前往「管理」→「設定」→「電子郵件通知」
2. 填寫 SMTP 設定：
   - SMTP 伺服器
   - SMTP 埠號
   - SMTP 驗證方式
   - 帳號密碼

## 使用說明

### 訂閱通知

1. 開啟任何具有到期日的議題
2. 在議題詳細資訊下方可以看到訂閱按鈕
3. 點擊「訂閱」即可接收該議題的到期通知

### 取消訂閱

1. 開啟已訂閱的議題
2. 點擊「取消訂閱」按鈕

### 查看訂閱列表

1. 在專案選單中點擊「通知訂閱」
2. 可查看當前專案中已訂閱的所有議題

## 問題排查

### Q1: 為什麼沒收到通知郵件？

- 檢查 SMTP 設定是否正確
- 確認使用者的電子郵件地址是否正確
- 檢查議題是否有設定到期日

### Q2: 如何修改通知時間？

- 在插件設定中可以調整提前通知的天數
- 系統預設為到期日前 7 天發送通知

### Q3: Docker 容器無法啟動？

- 檢查 ports 是否被占用
- 確認 Docker 服務是否正在運行
- 檢查 docker-compose.yml 的設定是否正確

## 開發指南

### 本地開發環境設置

1. 安裝開發依賴：

   ```bash
   bundle install
   ```

2. 設定開發環境：

```bash
# 建立開發用資料庫
docker exec redmine bundle exec rake db:create RAILS_ENV=development

# 執行遷移
docker exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=development
```

### 測試

執行測試：

```bash
# 執行所有測試
docker exec redmine bundle exec rake redmine:plugins:test NAME=redmine_notify_plugin

# 執行特定測試
docker exec redmine bundle exec rake redmine:plugins:test:units NAME=redmine_notify_plugin
```

### 程式碼規範

- 遵循 Ruby 標準程式碼風格
- 使用兩個空格作為縮排
- 方法和類別需要添加註解
- 變更需要編寫對應的測試

### 實用指令

以下是一些實用的管理和測試指令：

#### 通知相關

```bash
# 手動執行到期日通知檢查
docker exec redmine bundle exec rake redmine_notify_plugin:notify_due_dates RAILS_ENV=production

# 檢視目前的排程任務狀態
docker exec redmine bundle exec rake redmine:scheduler:info RAILS_ENV=production

# 重新啟動排程系統（如果需要）
docker exec redmine bundle exec rake redmine:scheduler:restart RAILS_ENV=production
```

#### 插件管理

```bash
# 安裝插件依賴
docker exec redmine bundle install

# 更新插件資料庫
docker exec redmine bundle exec rake redmine:plugins:migrate NAME=redmine_notify_plugin RAILS_ENV=production

# 回復插件資料庫
docker exec redmine bundle exec rake redmine:plugins:migrate NAME=redmine_notify_plugin VERSION=0 RAILS_ENV=production

# 重新載入插件（開發時使用）
docker exec redmine touch tmp/restart.txt
```

#### 日誌查看

```bash
# 查看 Redmine 日誌（包含通知相關訊息）
docker exec redmine tail -f log/production.log

# 只查看錯誤訊息
docker exec redmine grep "ERROR" log/production.log
```
