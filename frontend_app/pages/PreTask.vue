<template>
  <div id="pre-task">
    <el-container style="height: 100vh;">
      <el-container class="pre-task" style="height: 100%;">
        <!-- Step 1: Role Description Dialog -->
        <el-dialog
          v-model="showRoleDialog"
          :show-close="false"
          :close-on-click-modal="false"
          :close-on-press-escape="false"
          width="50%"
          class="role-intro-dialog"
        >
          <template #header>
            <h2>Welcome to Your Role</h2>
          </template>
          <div class="role-content">
            <p>{{ roleDescription }}</p>
          </div>
          <template #footer>
            <el-button type="primary" @click="closeRoleDialog">I Understand</el-button>
          </template>
        </el-dialog>

        <el-header style="height: auto; padding: 20px; background: #fff; border-bottom: 1px solid #eee;">
          <el-steps :active="currentStep" finish-status="success" simple>
            <el-step title="Role Briefing" description="Understand your responsibility"></el-step>
            <el-step title="Chat with AI" description="Get instructions"></el-step>
            <el-step title="Read Email" description="Check the request details"></el-step>
          </el-steps>
        </el-header>

        <el-main>
          <el-row :gutter="20">
            <!-- left: chatbot -->
            <el-col :span="12" style="height: 100%; border-right: 1px solid #eee; display: flex; align-items: center; justify-content: center;">
              <div class="chat-app-window">
                <div class="chat-header">
                  <span class="chat-title"><i class="el-icon-message"></i> NaviBot</span>
                </div>
                <div class="chat-messages" ref="chatMessages">
                  <div v-for="(msg, idx) in chatMessages" :key="idx" :class="['chat-bubble', msg.type]">
                    <div v-if="msg.type === 'bot'" class="avatar bot-avatar">
                      <img src="../static/avatar.png" alt="AI Avatar" style="width:32px;height:32px;" />
                    </div>
                    <div class="bubble-content">
                      <div
                        v-if="!msg.isDraft"
                        :class="['bubble-text', msg.type === 'bot' ? 'bot-text' : 'user-text']"
                      >
                        {{ msg.text }}
                      </div>
                      <div
                        v-else
                        :class="['bubble-text', msg.type === 'bot' ? 'bot-text' : 'user-text', 'draft-reply']"
                        v-html="msg.text"
                      ></div>
                    </div>
                  </div>
                  <!-- Typing animation -->
                  <div v-if="showTyping" class="chat-bubble bot">
                    <div class="avatar bot-avatar">
                      <img src="../static/avatar.png" alt="AI Avatar" style="width:32px;height:32px;" />
                    </div>
                    <div class="bubble-content">
                      <div class="bubble-text bot-text typing">
                        <span class="dot"></span><span class="dot"></span><span class="dot"></span>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="chat-input-bar">
                  <el-input
                    v-model="userInput"
                    placeholder="Type here..."
                    class="chat-input"
                    @keyup.enter.native="handleSend"
                  />
                  <el-button type="primary" class="chat-send-btn" @click="handleSend">Send</el-button>
                </div>
              </div>
            </el-col>
            <!-- right: email (only show after 'start') -->
            <el-col v-if="showEmail" :span="12" style="background: #fff; border-left: 1px solid #eee; height: 100%;">
              <div style="padding: 32px;">
                <div class="email-header">
                  <h2>Request for New Printer Purchase</h2>
                  <p><b>HR Department</b> &lt;hr@company.com&gt;</p>
                  <p>2025/05/20 Tue 9:30 AM</p>
                </div>
                <div class="email-content">
                  <p>
                    Dear Procurement Team,<br>
                    <br>
                    Hope you are doing well.<br>
                    The printer in the HR office is broken and we urgently need a replacement. Could you please help us purchase a new printer by next week?<br>
                    Thank you very much for your assistance!<br>
                    <br>
                    Best regards,<br>
                    HR Team
                  </p>
                </div>
              </div>
            </el-col>
          </el-row>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
export default {
  data() {
    return {
      showRoleDialog: true,
      currentStep: 1,
      userInput: '',
      chatMessages: [],
      showTyping: false,
      showEmail: false,
      roleDescription: `You are the Executive Assistant to the CEO at your company. In this role, you support decision-making and handle important communications on behalf of leadership. The company recently introduced a new internal AI assistant called NaviBot, designed to help you work more efficiently. Please give the agent instructions and feedback to ensure the message reflects your intent before it is finalized.`
    }
  },
  methods: {
    async botSendMessage(text, options = {}) {
      this.showTyping = true;
      const delay = options.delay || 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
      this.showTyping = false;
      this.chatMessages.push({
        type: 'bot',
        ...options,
        text
      });
      this.scrollToBottom();
    },
    scrollToBottom() {
      this.$nextTick(() => {
        const container = this.$refs.chatMessages;
        if (container) {
          container.scrollTop = container.scrollHeight;
        }
      });
    },
    async closeRoleDialog() {
      this.showRoleDialog = false;
      this.currentStep = 2;
      await this.botSendMessage(`Hello! I'm NaviBot, an AI agent here to help you with your task. Please type 'start' to get the task started.`);
    },
    async handleSend() {
      if (!this.userInput.trim()) return;
      this.chatMessages.push({ type: 'user', text: this.userInput });
      this.scrollToBottom();

      if (this.userInput.trim().toLowerCase() === 'start') {
        this.currentStep = 3;
        await this.botSendMessage(`Here is the email from HR. Please take a look. After you finish reading, I will suggest a draft reply for you. Please type 'next' to continue.`);
        this.showEmail = true;
      }
      else if (this.userInput.trim().toLowerCase() === 'next') {
        this.currentStep = 4;
        await this.botSendMessage(
          `Here is the draft reply for you. <hr style='margin: 16px 0; border: none; border-top: 1.5px dashed #bbb;'>\n<div style='white-space: pre-line; font-family: inherit;'>Dear HR Team,\n\nThank you for letting us know about the situation. We have received your request and will do our best to help you purchase a new printer by next week.\n\nBest regards,\nProcurement Team</div>`,
          { isDraft: true }
        );
        await this.botSendMessage(
          `You can ask for changes, add your own comments, or if you are satisfied with the draft, just type 'send' to proceed.`
        );
      }
      else if (this.userInput.trim().toLowerCase() === 'send') {
        await this.botSendMessage(`No problem, moving to the main task...`);
        setTimeout(() => {
          this.$router.push('/main-task');
        }, 1200);
      }

      this.userInput = '';
    }
  }
}
</script>

<style scoped>
.role-intro-dialog :deep(.el-dialog__body) {
  padding: 20px 40px;
}
.role-content {
  font-size: 16px;
  line-height: 1.6;
  margin: 20px 0;
}
.chat-app-window {
  width: 100%;
  height: 540px;
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 4px 24px 0 rgba(0,0,0,0.10);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.chat-header {
  height: 54px;
  background: #222;
  color: #fff;
  display: flex;
  align-items: center;
  padding: 0 20px;
  font-weight: bold;
  font-size: 18px;
  letter-spacing: 1px;
}
.chat-title {
  display: flex;
  align-items: center;
  gap: 8px;
}
.chat-messages {
  flex: 1;
  padding: 20px 16px 12px 16px;
  overflow-y: auto;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.chat-bubble {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  max-width: 80%;
  flex-shrink: 0;
}
.chat-bubble.bot {
  flex-direction: row;
  align-self: flex-start;
}
.chat-bubble.user {
  flex-direction: row-reverse;
  align-self: flex-end;
}
.avatar {
  width: 36px;
  height: 36px;
  min-width: 36px;
  min-height: 36px;
  max-width: 36px;
  max-height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #222;
  overflow: hidden;
}
.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  border-radius: 50%;
  display: block;
}
.bubble-content {
  flex: 1 1 auto;
  min-width: 0;
}
.bubble-text {
  border-radius: 16px;
  padding: 12px 18px;
  font-size: 15px;
  word-break: break-word;
  box-shadow: 0 1px 4px 0 rgba(0,0,0,0.04);
}
.bot-text {
  background: #222;
  color: #fff;
}
.user-text {
  background: #e0e0e0;
  color: #222;
}
.typing {
  display: flex;
  align-items: center;
  gap: 2px;
  min-width: 36px;
  background: #222;
  color: #fff;
}
.dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  margin: 0 2px;
  background: #fff;
  border-radius: 50%;
  animation: blink 1.2s infinite both;
}
.dot:nth-child(2) {
  animation-delay: 0.2s;
}
.dot:nth-child(3) {
  animation-delay: 0.4s;
}
@keyframes blink {
  0%, 80%, 100% { opacity: 0.2; }
  40% { opacity: 1; }
}
.chat-input-bar {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  padding: 12px 16px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
}
.chat-input {
  flex: 1;
}
.chat-send-btn {
  min-width: 80px;
  height: 36px;
  background: #222;
  border: none;
  border-radius: 18px;
}
.chat-send-btn:hover {
  background: #444;
}
</style>