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
            <p v-html="roleDescription"></p>
          </div>
          <template #footer>
            <el-button type="success" @click="closeRoleDialog">I Understand</el-button>
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
                    <div class="bubble-content-with-timestamp" :class="msg.type">
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
                      <span class="bubble-timestamp-outside">
                        {{ formatTimestamp(msg.timestamp) }}
                      </span>
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
                  <p v-html="emailLongRequirement"></p>
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
      roleDescription: `You are the <span style="color: #ff6600; font-weight: bold;">Senior Procurement Manager</span> at your company.<br>
In this role, you oversee purchasing decisions and manage important vendor communications on behalf of the procurement department.
The company recently introduced a new internal AI assistant called NaviBot, designed to help you work more efficiently.<br><br>
<strong>Please give the agent instructions and feedback to ensure the message reflects your intent before it is finalized.</strong>`,
      emailLongRequirement: `
The HR department has requested a new printer for their office with the following requirements:<br><br>
<ul>
  <li>The printer should have a print speed of at least 20 pages per minute to efficiently handle daily HR paperwork and urgent tasks.</li>
  <li>The input tray should hold at least 200 sheets of paper to minimize the need for frequent refilling and support continuous office operations.</li>
  <li>Automatic duplex (double-sided) printing is required to save paper and streamline document handling.</li>
</ul>
Please help us purchase a printer that meets these requirements by next week. Thank you for your assistance!<br><br>
Best regards,<br>
HR Team
`,
      navibotIntro: `Good morning!<br>This morning, HR sent you an email regarding their printer purchase request (see the message on the right). Below is a summary of the key requirements.<br><br><span style="color:#d72660;">📌</span> Summary of HR's requirements:<ul style="margin-top: 4px; margin-bottom: 12px;"><li>Print speed of at least 20 ppm for efficient document handling.</li><li>Paper tray capacity of at least 200 sheets to reduce refills.</li><li>Automatic duplex printing to save paper and improve workflow.</li></ul>Type \"DRAFT\" when you are ready to see the draft reply email.`,
      draftEmail: `I've prepared an initial draft of the reply email for your review.<br><br><div style='background: #fff; color: #222; border-radius: 10px; padding: 16px; margin: 8px 0;'><b>Subject:</b> Re: Request for New Printer Purchase<br><br>Dear HR Team,<br><br>Thank you for letting us know about your printer needs. We will do our best to help you purchase a new printer that meets your requirements by next week.<br><br>Best regards,<br>Procurement Team</div>`,
      draftFeedback: `If you'd like me to make any changes, clarifications, or improvements, please let me know—your suggestions are always welcome, and I'll adjust the draft as needed.<br>Type \"SEND\" when you are ready to send the email out.`
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
        text,
        timestamp: new Date()
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
      await this.botSendMessage(`Hello! I'm NaviBot, an AI agent here to help you with your task. Please type 'START' to get the task started.`);
    },
    async handleSend() {
      if (!this.userInput.trim()) return;
      this.chatMessages.push({ type: 'user', text: this.userInput, timestamp: new Date() });
      this.scrollToBottom();

      const input = this.userInput.trim().toUpperCase();

      if (input === 'START') {
        this.currentStep = 3;
        await this.botSendMessage(this.navibotIntro, { isDraft: true });
        this.showEmail = true;
      } else if (input === 'DRAFT') {
        this.currentStep = 4;
        await this.botSendMessage(this.draftEmail, { isDraft: true });
        await this.botSendMessage(this.draftFeedback, { isDraft: true });
      } else if (input === 'SEND') {
        await this.botSendMessage(`No problem, moving to the main task...`);
        setTimeout(() => {
          this.$router.push('/main-task');
        }, 1200);
      }

      this.userInput = '';
    },
    formatTimestamp(ts) {
      if (!ts) return '';
      const date = typeof ts === 'string' ? new Date(ts) : ts;
      return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }
  }
}
</script>

<style scoped>
#pre-task {
  background: #fff;
  min-height: 100vh;
}
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
  background: #232323;
  border-radius: 18px;
  box-shadow: 0 4px 24px 0 rgba(0,0,0,0.10);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.chat-header {
  height: 54px;
  background: #2A2A2A;
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
  background: #2A2A2A;
  color: #fff;
}
.user-text {
  background: #232323;
  color: #fff;
  border: 1px solid #444;
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
  background: #2A2A2A;
  border: none;
  border-radius: 18px;
  color: #fff;
}
.chat-send-btn:hover {
  background: #444;
}
.el-header {
  background: #232323;
  border-bottom: 1px solid #333;
  color: #fff;
}
.email-content {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  color: #222;
}
.bubble-content-with-timestamp {
  display: flex;
  flex-direction: row;
  align-items: flex-end;
  gap: 6px;
  position: relative;
}
.bubble-content-with-timestamp.bot {
  flex-direction: row;
}
.bubble-content-with-timestamp.user {
  flex-direction: row-reverse;
}
.bubble-timestamp-outside {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 2px;
  min-width: 60px;
  text-align: right;
  white-space: nowrap;
  padding: 0 2px;
}
.bubble-content-with-timestamp.user .bubble-timestamp-outside {
  text-align: left;
}
</style>