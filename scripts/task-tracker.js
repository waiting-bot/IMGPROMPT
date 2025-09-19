#!/usr/bin/env node

/**
 * 任务状态自动更新脚本
 * 用于自动更新 TASK_LIST.md 中的任务状态
 */

const fs = require('fs');
const path = require('path');

class TaskTracker {
  constructor() {
    this.taskListPath = path.join(__dirname, '..', 'docs', 'TASK_LIST.md');
    this.taskList = this.loadTaskList();
  }

  loadTaskList() {
    try {
      const content = fs.readFileSync(this.taskListPath, 'utf8');
      return content;
    } catch (error) {
      console.error('无法读取任务清单文件:', error);
      return null;
    }
  }

  saveTaskList() {
    try {
      fs.writeFileSync(this.taskListPath, this.taskList, 'utf8');
      console.log('✅ 任务清单已更新');
    } catch (error) {
      console.error('无法保存任务清单文件:', error);
    }
  }

  // 更新任务状态
  updateTaskStatus(taskId, status, notes = '') {
    const taskPattern = new RegExp(`(\\| ${taskId} \\| .*? \\| )(.*?)( \\| .*? \\| )(.*?)( \\| .*? \\|)`);
    const match = this.taskList.match(taskPattern);
    
    if (match) {
      const statusMap = {
        'completed': '✅ 已完成',
        'in_progress': '🔄 进行中',
        'pending': '⏳ 待开始',
        'verified': '✅ 已验证',
        'failed': '❌ 验证失败'
      };
      
      const newStatus = statusMap[status] || match[2];
      let newNotes = match[4];
      
      if (notes) {
        const now = new Date().toLocaleString('zh-CN');
        newNotes = `${match[4]} ${notes} (${now})`;
      }
      
      this.taskList = this.taskList.replace(taskPattern, `$1${newStatus}$3${newNotes}$5`);
      this.saveTaskList();
      return true;
    }
    
    return false;
  }

  // 验证任务
  verifyTask(taskId, success = true, notes = '') {
    const status = success ? 'verified' : 'failed';
    const verificationNotes = success ? '✅ 验证通过' : '❌ 验证失败';
    const fullNotes = notes ? `${verificationNotes}: ${notes}` : verificationNotes;
    
    return this.updateTaskStatus(taskId, status, fullNotes);
  }

  // 完成任务
  completeTask(taskId, notes = '') {
    const now = new Date().toLocaleDateString('zh-CN');
    const completionNotes = notes ? `✅ 完成 (${now}): ${notes}` : `✅ 完成 (${now})`;
    
    return this.updateTaskStatus(taskId, 'completed', completionNotes);
  }

  // 开始任务
  startTask(taskId, notes = '') {
    const startNotes = notes ? `🔄 开始: ${notes}` : '🔄 开始开发';
    
    return this.updateTaskStatus(taskId, 'in_progress', startNotes);
  }

  // 获取任务统计
  getStatistics() {
    const lines = this.taskList.split('\n');
    const stats = {
      total: 0,
      completed: 0,
      in_progress: 0,
      pending: 0,
      verified: 0,
      failed: 0
    };

    lines.forEach(line => {
      if (line.includes('✅ 已完成')) stats.completed++;
      if (line.includes('🔄 进行中')) stats.in_progress++;
      if (line.includes('⏳ 待开始')) stats.pending++;
      if (line.includes('✅ 已验证')) stats.verified++;
      if (line.includes('❌ 验证失败')) stats.failed++;
      if (line.match(/^\| \d+\.\d+ \|/)) stats.total++;
    });

    return stats;
  }

  // 更新统计信息
  updateStatistics() {
    const stats = this.getStatistics();
    const completionRate = ((stats.completed / stats.total) * 100).toFixed(1);
    
    // 更新统计表格
    const statsPattern = /(\| \*\*总任务数\*\*: )(.*?)(\s*\|\s*\*\*已完成\*\*: )(.*?)(\s*\|\s*\*\*进行中\*\*: )(.*?)(\s*\|\s*\*\*待开始\*\*: )(.*?)(\s*\|)/;
    const replacement = `$1${stats.total}$3${stats.completed}$5${stats.in_progress}$7${stats.pending}$9`;
    
    this.taskList = this.taskList.replace(statsPattern, replacement);
    
    // 更新完成率
    const ratePattern = /(\- \*\*已完成\*\*: )(.*?)( \()/;
    this.taskList = this.taskList.replace(ratePattern, `$1${stats.completed} ($3`);
    
    // 更新百分比
    const percentPattern = /(\(.*?\) \()(.*?)(%\))/;
    this.taskList = this.taskList.replace(percentPattern, `$1${completionRate}$3`);
    
    // 更新最后更新时间
    const now = new Date().toLocaleString('zh-CN');
    const timePattern = /(\*此文档会随着项目进度自动更新，最后更新时间：)(.*?)(\*)/;
    this.taskList = this.taskList.replace(timePattern, `$1${now}$3`);
    
    this.saveTaskList();
    console.log('📊 统计信息已更新:', stats);
  }

  // 添加更新记录
  addUpdateRecord(action) {
    const now = new Date().toLocaleString('zh-CN');
    const recordPattern = /(\- \*\*\*更新历史\*\*\*\n)(.*?)(\n- \*\*最后更新\*\*:)/;
    const newRecord = `- **${now}**: ${action}`;
    
    if (this.taskList.match(recordPattern)) {
      this.taskList = this.taskList.replace(recordPattern, `$1$2\n${newRecord}$3`);
    } else {
      // 如果没有找到匹配的模式，添加新的记录部分
      const historyPattern = /(\n\#\# 🔄 \*\*自动更新记录\*\*\*\n)/;
      this.taskList = this.taskList.replace(historyPattern, `$1\n### **更新历史**\n${newRecord}\n`);
    }
    
    this.saveTaskList();
  }
}

// 命令行接口
if (require.main === module) {
  const args = process.argv.slice(2);
  const tracker = new TaskTracker();
  
  if (args.length === 0) {
    console.log('使用方法:');
    console.log('  node task-tracker.js complete <taskId> [notes]     # 完成任务');
    console.log('  node task-tracker.js start <taskId> [notes]       # 开始任务');
    console.log('  node task-tracker.js verify <taskId> [notes]      # 验证任务');
    console.log('  node task-tracker.js fail <taskId> [notes]        # 验证失败');
    console.log('  node task-tracker.js stats                         # 显示统计');
    console.log('');
    console.log('示例:');
    console.log('  node task-tracker.js complete 1.1');
    console.log('  node task-tracker.js verify 1.1 "功能测试通过"');
    console.log('  node task-tracker.js stats');
    return;
  }

  const command = args[0];
  const taskId = args[1];
  const notes = args.slice(2).join(' ');

  switch (command) {
    case 'complete':
      if (tracker.completeTask(taskId, notes)) {
        tracker.addUpdateRecord(`完成任务 ${taskId}`);
        tracker.updateStatistics();
        console.log(`✅ 任务 ${taskId} 已标记为完成`);
      } else {
        console.log(`❌ 未找到任务 ${taskId}`);
      }
      break;
      
    case 'start':
      if (tracker.startTask(taskId, notes)) {
        tracker.addUpdateRecord(`开始任务 ${taskId}`);
        tracker.updateStatistics();
        console.log(`🔄 任务 ${taskId} 已标记为进行中`);
      } else {
        console.log(`❌ 未找到任务 ${taskId}`);
      }
      break;
      
    case 'verify':
      if (tracker.verifyTask(taskId, true, notes)) {
        tracker.addUpdateRecord(`验证任务 ${taskId} 通过`);
        tracker.updateStatistics();
        console.log(`✅ 任务 ${taskId} 验证通过`);
      } else {
        console.log(`❌ 未找到任务 ${taskId}`);
      }
      break;
      
    case 'fail':
      if (tracker.verifyTask(taskId, false, notes)) {
        tracker.addUpdateRecord(`验证任务 ${taskId} 失败`);
        tracker.updateStatistics();
        console.log(`❌ 任务 ${taskId} 验证失败`);
      } else {
        console.log(`❌ 未找到任务 ${taskId}`);
      }
      break;
      
    case 'stats':
      const stats = tracker.getStatistics();
      console.log('📊 任务统计:');
      console.log(`  总任务数: ${stats.total}`);
      console.log(`  已完成: ${stats.completed}`);
      console.log(`  进行中: ${stats.in_progress}`);
      console.log(`  待开始: ${stats.pending}`);
      console.log(`  已验证: ${stats.verified}`);
      console.log(`  失败: ${stats.failed}`);
      break;
      
    default:
      console.log(`❌ 未知命令: ${command}`);
  }
}

module.exports = TaskTracker;