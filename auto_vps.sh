#!/bin/bash

# Hàm hiển thị menu
show_menu() {
    read -p 'Enter để tiếp tục...' ent
    echo "===== QUẢN LÝ WEBSITE ====="
    echo "1. Thêm website PHP"
    echo "2. Thêm website NodeJs/NestJs"
    echo "3. Thêm website React"
    echo "4. Liệt kê danh sách website"
    echo "0. Thoát"
    echo "=========================="
}

add_php_website() {
    echo "===== THÊM WEBSITE PHP ====="
    # Prompt user for domain name
    read -p "Nhập domain name: " domain_name

    # Set up NGINX configuration file
    nginx_config="/etc/nginx/sites-available/$domain_name"

    # Check if the domain configuration file already exists
    if [ -f "$nginx_config" ]; then
        echo "Domain đã tồn tại!"
        exit 1
    fi

    # Create NGINX configuration file
    cat > "$nginx_config" <<EOF
    server {
        listen 80;
        server_name $domain_name;

        root /var/www/$domain_name/public;
        index index.php index.html index.htm;

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }
    }
EOF

    # Create web root directory
    web_root="/var/www/$domain_name/public"
    mkdir -p "$web_root"
    chown -R huukhuong:huukhuong "$web_root"
    chmod -R 755 "$web_root"

    index_file="$web_root/index.php"
    touch "$index_file"
    echo "Welcome to $domain_name" > "$index_file"

    # Enable the domain by creating a symbolic link
    nginx_enabled="/etc/nginx/sites-enabled/$domain_name"
    ln -s "$nginx_config" "$nginx_enabled"

    # Test NGINX configuration
    nginx -t

    # If the configuration test passes, reload NGINX to apply changes
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        echo "Domain $domain_name được tạo thành công!"
    else
        echo "There was an error in the NGINX configuration. Aborting."
        exit 1
    fi
}

add_nodejs_website() {
    echo "===== THÊM WEBSITE NODE.JS ====="
    # Prompt user for domain name and port
    read -p "Nhập domain name: " domain_name
    read -p "Nhập port: " port

    # Set up NGINX configuration file
    nginx_config="/etc/nginx/sites-available/$domain_name"

    # Check if the domain configuration file already exists
    if [ -f "$nginx_config" ]; then
        echo "Domain đã tồn tại!"
        exit 1
    fi

    # Create NGINX configuration file
    cat > "$nginx_config" <<EOF
    server {
      listen 80;
      server_name $domain_name;
      location / {
        proxy_pass http://localhost:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
       }
    }
EOF

    # Enable the domain by creating a symbolic link
    nginx_enabled="/etc/nginx/sites-enabled/$domain_name"
    ln -s "$nginx_config" "$nginx_enabled"

    # Test NGINX configuration
    nginx -t

    # If the configuration test passes, reload NGINX to apply changes
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        echo "Domain $domain_name được tạo thành công!"
    else
        echo "There was an error in the NGINX configuration. Aborting."
        exit 1
    fi
}

add_react_website() {
    echo "===== THÊM WEBSITE REACTJS ====="
    read -p "Nhập domain name: " domain_name
    # Set up NGINX configuration file
    nginx_config="/etc/nginx/sites-available/$domain_name"

    # Check if the domain configuration file already exists
    if [ -f "$nginx_config" ]; then
        echo "Domain đã tồn tại!"
        exit 1
    fi

    # Create NGINX configuration file
    cat > "$nginx_config" <<EOF
    server {
        listen 80;
        server_name $domain_name;

        root /var/www/$domain_name;
        index index.html index.htm;

        location / {
            try_files \$uri /index.html;
        }
    }
EOF

    # Enable the domain by creating a symbolic link
    nginx_enabled="/etc/nginx/sites-enabled/$domain_name"
    ln -s "$nginx_config" "$nginx_enabled"

    # Test NGINX configuration
    nginx -t

    # If the configuration test passes, reload NGINX to apply changes
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        read -p "Domain $domain_name được tạo thành công!" domain_name
    else
        read -p "There was an error in the NGINX configuration. Aborting."
        exit 1
    fi
}

get_domain_list() {
    grep server_name /etc/nginx/sites-enabled/* -RiI | grep -oP '(?<=server_name\s)[^\s;]+'
}

# Vòng lặp chính
while true; do
    show_menu
    read -p "Nhập lựa chọn của bạn: " choice

    case $choice in
        0)
            echo "Cảm ơn bạn đã sử dụng script. Tạm biệt!"
            break
            ;;
        1)
            add_php_website
            ;;
        2)
            add_nodejs_website
            ;;
        3)
            add_react_website
            ;;
        4)
            get_domain_list
            ;;
        *)
            echo "Lựa chọn không hợp lệ. Vui lòng thử lại."
            ;;
    esac
done
