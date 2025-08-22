#!/usr/bin/env bash
# 判断是否需要发行新版本 | Checking for a Newer Version

# 设置定量 | Quantities
## 当前脚本所在目录 | Current Script Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
## 仓库目录 | Repository Directory
REPO_DIR="$(dirname "$SCRIPT_DIR")"
## 当前语言 | Current Language
CURRENT_LANG=0 ### 0: en-US, 1: zh-Hans-CN

# 语言检测 | Language Detection
if [ $(echo ${LANG/_/-} | grep -Ei "\b(zh|cn)\b") ]; then CURRENT_LANG=1;  fi

# 本地化 | Localization
recho() {
  if [ $CURRENT_LANG == 1 ]; then
    ## zh-Hans-CN
    echo -e "$1";
  else
    ## en-US
    echo -e "$2";
  fi
}

# 颜色定义 | Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计 | Test result statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数 | Test function
run_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_result="$3"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  recho "${BLUE}正在运行测试: $test_name${NC}" "${BLUE}Running test: $test_name${NC}"
  
  # 执行测试命令 | Execute test command
  if eval "$test_command" >/dev/null 2>&1; then
    if [ "$expected_result" = "success" ]; then
      recho "${GREEN}✓ 测试通过: $test_name${NC}" "${GREEN}✓ Test passed: $test_name${NC}"
      PASSED_TESTS=$((PASSED_TESTS + 1))
      return 0
    else
      recho "${RED}✗ 测试失败: $test_name (预期失败但实际成功)${NC}" "${RED}✗ Test failed: $test_name (expected failure but actually succeeded)${NC}"
      FAILED_TESTS=$((FAILED_TESTS + 1))
      return 1
    fi
  else
    if [ "$expected_result" = "failure" ]; then
      recho "${GREEN}✓ 测试通过: $test_name${NC}" "${GREEN}✓ Test passed: $test_name${NC}"
      PASSED_TESTS=$((PASSED_TESTS + 1))
      return 0
    else
      recho "${RED}✗ 测试失败: $test_name${NC}" "${RED}✗ Test failed: $test_name${NC}"
      FAILED_TESTS=$((FAILED_TESTS + 1))
      return 1
    fi
  fi
}

# 测试脚本语法 | Test script syntax
test_syntax() {
  recho "${YELLOW}测试脚本语法...${NC}" "${YELLOW}Testing script syntax...${NC}"
  
  run_test "serv00_alive 语法检查" "bash -n '$REPO_DIR/serv00_alive'" "success"
  run_test "serv00_alive_runner 语法检查" "bash -n '$REPO_DIR/serv00_alive_runner'" "success"
}

# 测试 serv00_alive 脚本 | Test serv00_alive script
test_serv00_alive() {
  recho "${YELLOW}测试 serv00_alive 脚本...${NC}" "${YELLOW}Testing serv00_alive script...${NC}"
  
  # 创建临时测试服务器文件 | Create temporary test server file
  local test_servers_file="/tmp/test_servers.txt"
  echo "testuser@test.serv00.com:testpassword" > "$test_servers_file"
  
  # 测试帮助信息 | Test help information
  run_test "serv00_alive 帮助信息" "'$REPO_DIR/serv00_alive' --help | grep -q '用法\\|Usage'" "success"
  
  # 测试版本信息 | Test version information
  run_test "serv00_alive 版本信息" "'$REPO_DIR/serv00_alive' --version | grep -q 'serv00'" "success"
  
  # 测试服务器文件不存在的情况 | Test case when server file doesn't exist
  run_test "serv00_alive 服务器文件不存在" "'$REPO_DIR/serv00_alive' -f /nonexistent/file 2>&1 | grep -q '错误\\|Error'" "success"
  
  # 测试空服务器文件 | Test empty server file
  local empty_file="/tmp/empty_servers.txt"
  touch "$empty_file"
  run_test "serv00_alive 空服务器文件" "'$REPO_DIR/serv00_alive' -f '$empty_file' 2>&1 | grep -q '错误\\|Error'" "success"
  
  # 测试无效的服务器格式 | Test invalid server format
  local invalid_file="/tmp/invalid_servers.txt"
  echo "invalid_server_format" > "$invalid_file"
  run_test "serv00_alive 无效服务器格式" "'$REPO_DIR/serv00_alive' -f '$invalid_file' 2>&1 | grep -q 'Hello'" "failure"
  
  # 清理临时文件 | Clean up temporary files
  rm -f "$test_servers_file" "$empty_file" "$invalid_file"
}

# 测试 serv00_alive_runner 脚本 | Test serv00_alive_runner script
test_serv00_alive_runner() {
  recho "${YELLOW}测试 serv00_alive_runner 脚本...${NC}" "${YELLOW}Testing serv00_alive_runner script...${NC}"
  
  # 测试版本信息 | Test version information
  run_test "serv00_alive_runner 版本信息" "timeout 5 '$REPO_DIR/serv00_alive_runner' 2>&1 | grep -q '当前版本\\|Current version'" "success"
}

# 模拟连接测试 | Mock connection test
test_mock_connection() {
  recho "${YELLOW}测试模拟连接...${NC}" "${YELLOW}Testing mock connection...${NC}"
  
  # 创建模拟的 sshpass 命令 | Create mock sshpass command
  local mock_sshpass="/tmp/mock_sshpass"
  cat > "$mock_sshpass" << 'EOF'
#!/bin/bash
# 模拟 sshpass 命令 | Mock sshpass command
# Extract the ssh command and execute it
if [ "$1" = "-p" ]; then
  shift 2  # Skip -p and password
  "$@"     # Execute the ssh command
else
  "$@"     # Execute the ssh command directly
fi
exit 0
EOF
  chmod +x "$mock_sshpass"
  
  # 创建模拟的 ssh 命令 | Create mock ssh command
  local mock_ssh="/tmp/mock_ssh"
  cat > "$mock_ssh" << 'EOF'
#!/bin/bash
# 模拟 ssh 命令 | Mock ssh command
echo "Hello from $USER"
date
sleep 3
exit 0
EOF
  chmod +x "$mock_ssh"
  
  # 创建测试服务器文件 | Create test server file
  local test_servers_file="/tmp/mock_test_servers.txt"
  echo "mockuser@mock.serv00.com:mockpassword" > "$test_servers_file"
  
  # 修改 PATH 以使用模拟命令 | Modify PATH to use mock commands
  local original_path="$PATH"
  export PATH="/tmp:$PATH"
  
  # 测试模拟连接 | Test mock connection
  run_test "模拟 SSH 连接" "timeout 10 '$REPO_DIR/serv00_alive' -f '$test_servers_file' | grep -q '连接成功！\\|connection successful!'" "success"
  
  # 恢复原始 PATH | Restore original PATH
  export PATH="$original_path"
  
  # 清理临时文件 | Clean up temporary files
  rm -f "$mock_sshpass" "$mock_ssh" "$test_servers_file"
}

# 显示测试结果 | Show test results
show_results() {
  recho "${YELLOW}====================${NC}" "${YELLOW}====================${NC}"
  recho "${BLUE}测试结果汇总${NC}" "${BLUE}Test Results Summary${NC}"
  recho "${YELLOW}====================${NC}" "${YELLOW}====================${NC}"
  recho "${BLUE}总测试数: $TOTAL_TESTS${NC}" "${BLUE}Total tests: $TOTAL_TESTS${NC}"
  recho "${GREEN}通过: $PASSED_TESTS${NC}" "${GREEN}Passed: $PASSED_TESTS${NC}"
  recho "${RED}失败: $FAILED_TESTS${NC}" "${RED}Failed: $FAILED_TESTS${NC}"
  
  if [ $FAILED_TESTS -eq 0 ]; then
    recho "${GREEN}所有测试通过！${NC}" "${GREEN}All tests passed!${NC}"
    exit 0
  else
    recho "${RED}有 $FAILED_TESTS 个测试失败！${NC}" "${RED}$FAILED_TESTS test(s) failed!${NC}"
    exit 1
  fi
}

# 主测试函数 | Main test function
main() {
  recho "${GREEN}开始运行 serv00_alive 项目测试...${NC}" "${GREEN}Starting serv00_alive project tests...${NC}"
  echo
  
  # 运行所有测试 | Run all tests
  test_syntax
  echo
  test_serv00_alive
  echo
  test_serv00_alive_runner
  echo
  # test_mock_connection
  echo
  
  # 显示测试结果 | Show test results
  show_results
}

# 执行主函数 | Execute main function
main "$@"
