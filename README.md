# NGINX_Script_Ubuntu
Script quản lý server NGINX trên Ubuntu, hỗ trợ tạo các website chạy PHP, NodeJs, NestJs, ReactJs

### Sau khi thêm website NodeJs/NestJs
Chạy NodeJs sau khi thêm domain
cd /var/www/domain
PORT=3001
pm2 start ./bin/www --name domain:3001
----------
cd /var/www/domain
Với NestJs thì cần sửa port trong main.ts
pm2 start ./dist --name domain:3001 -- --port 3001
