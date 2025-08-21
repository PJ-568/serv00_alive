# serv00 保活 脚本

> 简体中文 | [ENGLISH](README.en.md)

此脚本用于通过定期 SSH 连接来保持 serv00.com 免费账户的活跃状态，防止因长时间不活动而被停用。

## 使用方法

### 1. 准备服务器列表文件

在 `$HOME/.serv00_alive_servers` 中写入用户名、服务器和密码。

格式:

```text
username@hostname:password
```

示例:

```text
user1@s1.serv00.com:password1
user2@s2.serv00.com:password2
```

> **注意：** 请确保服务器文件权限设置正确以保护密码安全。

### 2. 运行脚本

#### 使用 `pm2` 运行

```bash
pm2 start bash --name serv00_alive -- -c "curl -sS https://raw.githubusercontent.com/PJ-568/serv00_alive/refs/heads/master/serv00_alive_runner | bash"
```

#### 直接运行

```bash
# 下载脚本
curl -sS https://raw.githubusercontent.com/PJ-568/serv00_alive/refs/heads/master/serv00_alive -o serv00_alive
chmod +x serv00_alive

# 运行脚本
./serv00_alive
```

## 功能

- 支持多服务器配置
- 支持中英文双语输出
- 自动检测系统语言并显示对应语言信息
- 易于配置的服务器列表文件
- 可通过命令行参数自定义配置
- 可通过 `pm2` 等进程管理工具运行

## 命令行参数

```text
-h, --help     显示帮助信息
-v, --version  显示版本信息
-f, --file     指定包含服务器列表的文件 (默认: $HOME/.serv00_alive_servers)
```

## 脚本说明

- `serv00_alive`: 主脚本，负责读取服务器列表并执行 SSH 连接测试。
- `serv00_alive_runner`: 运行器脚本，负责定期执行主脚本。它会从 GitHub 获取最新版本的 `serv00_alive` 脚本并执行。

## 附录

安装 pm2：`bash <(curl -s https://raw.githubusercontent.com/k0baya/alist_repl/main/serv00/install-pm2.sh)`

[Node.js 优雅保活](https://forum.naixi.net/thread-2797-1-1.html)

## 许可证

[CC Attribution-ShareAlike 4.0 International](LICENSE)
