# SIP实验测试场景规划

基于当前网络拓扑和4个B2BUA终端，规划了以下几个实验测试场景：

## 测试环境概览

**终端配置**：
- b2bua_internal_01 (172.16.254.100:5091) - 内部终端1
- b2bua_internal_02 (172.16.254.101:5092) - 内部终端2
- b2bua_external_01 (192.168.254.100:5093) - 外部终端1
- b2bua_external_02 (192.168.254.101:5094) - 外部终端2

## 实验场景一：内部网络终端间呼叫

### 测试目标
验证内部网络终端之间通过Kamailio代理的呼叫流程

### 操作步骤
1. **启动服务**
   ```bash
   cd /root/src/kamailio-course
   docker compose up -d
   ```

2. **检查服务状态**
   ```bash
   docker compose ps
   ```

3. **访问内部终端2**
   ```bash
   docker attach b2bua_internal_02
   ```

4. **在内部终端2中发起呼叫**
   ```
   # 呼叫内部终端2
   sip:b2bua_internal_01@172.16.254.100
   ```

5. **接听呼叫**
   在终端2中输入 `a` 接听呼叫

6. **验证通话**
   双方可以进行通话测试

7. **结束通话**
   任一方输入 `h` 挂断

8. **退出终端**
   `Ctrl+C` 退出，然后 `docker start b2bua_internal_01` 重启容器

## 实验场景二：外部网络终端间呼叫

### 测试目标
验证外部网络终端之间通过Kamailio代理的呼叫流程

### 操作步骤
1. **访问外部终端1**
   ```bash
   docker attach b2bua_external_01
   ```

2. **在外部终端1中发起呼叫**
   ```
   # 呼叫外部终端2
   sip:b2bua_external_02@192.168.254.101:5094
   ```

3. **接听呼叫**
   在外部终端2中输入 `a` 接听呼叫

4. **验证通话**
   双方进行通话测试

5. **结束通话**
   任一方输入 `h` 挂断

## 实验场景三：跨网络呼叫（外部到内部）

### 测试目标
验证外部网络终端呼叫内部网络终端的路由功能

### 操作步骤
1. **访问外部终端1**
   ```bash
   docker attach b2bua_external_01
   ```

2. **发起跨网络呼叫**
   ```
   # 呼叫内部终端1（通过Kamailio路由）
   sip:b2bua_internal_01@172.16.254.100:5091
   ```

3. **接听呼叫**
   在内部终端1中输入 `a` 接听

4. **验证媒体流**
   检查RTP媒体流是否正确建立

5. **结束通话**
   任一方输入 `h` 挂断

## 实验场景四：ENUM查询与路由

### 测试目标
验证ENUM查询和DNS路由功能

### 操作步骤
1. **查看ENUM配置**
   ```bash
   cat /root/src/kamailio-course/bind/db.e164.arpa
   ```
   确认NAPTR记录存在：+31201234567 映射到 SIP URI

2. **访问任一终端**
   ```bash
   docker attach b2bua_external_01
   ```

3. **使用ENUM号码呼叫**
   ```
   # 使用配置中的ENUM号码呼叫
   sip:+31201234567@kamailio-edge
   ```

4. **验证路由**
   Kamailio应通过BIND DNS服务器查询ENUM记录，并路由到正确的SIP地址

5. **接听呼叫**
   目标终端输入 `a` 接听

6. **结束通话**
   任一方输入 `h` 挂断

## 实验场景五：安全功能测试

### 测试目标
验证黑名单和洪水攻击防护功能

### 操作步骤
1. **添加黑名单条目**
   ```bash
   docker exec kamailio-edge kamctl secfilter add ip 192.168.254.100
   ```

2. **尝试从黑名单IP呼叫**
   ```bash
   docker attach b2bua_external_01
   # 尝试呼叫任意终端
   ```

3. **验证拦截**
   呼叫应被拦截，无法建立连接

4. **移除黑名单**
   ```bash
   docker exec kamailio-edge kamctl secfilter delete ip 192.168.254.100
   ```

5. **再次尝试呼叫**
   呼叫应能正常建立

## 实验场景六：媒体流分析

### 测试目标
使用sngrep分析SIP信令和RTP媒体流

### 操作步骤
1. **启动sngrep**
   ```bash
   docker exec -it sngrep sngrep
   ```

2. **在另一终端发起呼叫**
   按前面场景中的步骤发起任意呼叫

3. **观察sngrep界面**
   - 查看SIP信令流程
   - 检查SDP协商过程
   - 验证RTP媒体流建立

4. **过滤特定呼叫**
   在sngrep中使用 `/` 进行搜索，按 `q` 退出

## 监控和日志检查

### 查看Kamailio日志
```bash
docker compose logs kamailio-edge
```

### 查看数据库内容
```bash
docker exec -it db01 mysql -u kamailio -pkamailiorw kamailio
# 查看注册用户
SELECT * FROM location;
# 查看dispatcher配置
SELECT * FROM dispatcher;
```

### 查看RTPEngine日志
```bash
docker compose logs rtpengine-edge
```

这些实验场景涵盖了SIP代理的核心功能，包括基本呼叫、跨网络路由、ENUM查询、安全防护和媒体流分析，能够全面验证系统的功能和性能。